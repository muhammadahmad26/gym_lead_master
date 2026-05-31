import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/services/attendance_service.dart';
import 'package:gym_lead_master/services/pdf_report_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/data/models/attendance_model.dart';


class AttendanceMonthScreen extends StatefulWidget {
  final String gymId;
  final String monthKey;
  final String monthLabel;
  final int year;
  final int monthNum;

  const AttendanceMonthScreen({
    super.key,
    required this.gymId,
    required this.monthKey,
    required this.monthLabel,
    required this.year,
    required this.monthNum,
  });

  @override
  State<AttendanceMonthScreen> createState() => _AttendanceMonthScreenState();
}

class _AttendanceMonthScreenState extends State<AttendanceMonthScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  List<MemberAttendanceModel> _records = [];
  List<MemberAttendanceModel> _filteredRecords = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _sortOption = 'name'; // name, present, absent, percentage
  bool _isExporting = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var records = await _attendanceService.getMonthRecords(
        widget.gymId,
        widget.monthKey,
      );
      if (mounted) {
        setState(() {
          _records = records;
          _filteredRecords = records;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    List<MemberAttendanceModel> result = List.from(_records);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((r) =>
              r.memberName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.memberEmail.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Sort
    switch (_sortOption) {
      case 'name':
        result.sort((a, b) => a.memberName.compareTo(b.memberName));
        break;
      case 'present':
        result.sort((a, b) => b.totalPresent.compareTo(a.totalPresent));
        break;
      case 'absent':
        result.sort((a, b) => b
            .totalAbsent(widget.year, widget.monthNum)
            .compareTo(a.totalAbsent(widget.year, widget.monthNum)));
        break;
      case 'percentage':
        result.sort((a, b) => b
            .attendancePercentage(widget.year, widget.monthNum)
            .compareTo(a.attendancePercentage(widget.year, widget.monthNum)));
        break;
    }

    setState(() => _filteredRecords = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.LightGrey,
      appBar: AppBar(
        title: Text(widget.monthLabel,
            style:
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.DarkBlueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            tooltip: "Export PDF",
            onPressed: _isExporting ? null : _exportPDF,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            tooltip: "Delete Month",
            onPressed: _isDeleting ? null : _confirmDeleteMonth,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndSort(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ==========================================
  // SEARCH & SORT
  // ==========================================
  Widget _buildSearchAndSort() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Search member...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (val) {
              _searchQuery = val;
              _applyFilters();
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildSortChip('name', 'Name'),
                _buildSortChip('present', 'Most Present'),
                _buildSortChip('absent', 'Most Absent'),
                _buildSortChip('percentage', 'Attendance %'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    bool isSelected = _sortOption == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: isSelected,
        onSelected: (_) {
          _sortOption = value;
          _applyFilters();
        },
        selectedColor: AppColors.blueColor.withOpacity(0.2),
      ),
    );
  }

  // ==========================================
  // BODY
  // ==========================================
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState(_errorMessage!);
    }

    if (_filteredRecords.isEmpty) {
      return _buildEmptyState();
    }

    // Summary row
    int totalPresent = 0;
    int totalAbsent = 0;
    for (var r in _filteredRecords) {
      totalPresent += r.totalPresent;
      totalAbsent += r.totalAbsent(widget.year, widget.monthNum);
    }

    return Column(
      children: [
        // Quick summary
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStat('Members', '${_filteredRecords.length}',
                  Icons.people, AppColors.blueColor),
              _buildQuickStat('Present', '$totalPresent',
                  Icons.check_circle, Colors.green),
              _buildQuickStat('Absent', '$totalAbsent',
                  Icons.cancel, Colors.redAccent),
            ],
          ),
        ),
        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _filteredRecords.length,
            itemBuilder: (context, index) {
              var record = _filteredRecords[index];
              return _buildMemberCard(record);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  // ==========================================
  // MEMBER CARD
  // ==========================================
  Widget _buildMemberCard(MemberAttendanceModel record) {
    int absentDays = record.totalAbsent(widget.year, widget.monthNum);
    double percentage =
        record.attendancePercentage(widget.year, widget.monthNum);
    Color percentColor = percentage >= 75
        ? Colors.green
        : percentage >= 50
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: percentColor.withOpacity(0.15),
              child: Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: percentColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.memberName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildBadge(
                          '✓ ${record.totalPresent}', Colors.green),
                      const SizedBox(width: 8),
                      _buildBadge('✗ $absentDays', Colors.redAccent),
                    ],
                  ),
                ],
              ),
            ),
            // Attendance bar
            SizedBox(
              width: 60,
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(percentColor),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ==========================================
  // EXPORT PDF
  // ==========================================
  Future<void> _exportPDF() async {
    setState(() => _isExporting = true);

    try {
      // Fetch gym name
      var gymDoc = await FirebaseFirestore.instance
          .collection('gyms')
          .doc(widget.gymId)
          .get();
      String gymName = gymDoc.data()?['gymName'] ?? 'Gym';

      await PdfReportService.generateAttendanceReport(
        gymName: gymName,
        monthLabel: widget.monthLabel,
        records: _filteredRecords,
        year: widget.year,
        monthNum: widget.monthNum,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("PDF Report Generated! ✅"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("PDF Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  // ==========================================
  // DELETE MONTH
  // ==========================================
  Future<void> _confirmDeleteMonth() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red[700], size: 28),
            const SizedBox(width: 10),
            const Text("Delete Attendance?"),
          ],
        ),
        content: Text(
            "Are you sure you want to delete the attendance report for ${widget.monthLabel}?\n\nThis action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      await _attendanceService.deleteMonthAttendance(
          widget.gymId, widget.monthKey);
      if (mounted) {
        Navigator.pop(context); // Go back to dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("${widget.monthLabel} attendance deleted"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Delete failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ==========================================
  // UI HELPERS
  // ==========================================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_outlined,
                size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "No Attendance Records Found",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "No members checked in during this month.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.orange[300]),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadRecords,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}