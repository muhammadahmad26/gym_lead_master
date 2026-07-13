import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/services/attendance_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/data/models/attendance_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';
import 'package:intl/intl.dart';

class AttendanceDashboardScreen extends StatefulWidget {
  final String gymId;
  const AttendanceDashboardScreen({super.key, required this.gymId});

  @override
  State<AttendanceDashboardScreen> createState() =>
      _AttendanceDashboardScreenState();
}

class _AttendanceDashboardScreenState extends State<AttendanceDashboardScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  bool _isLoadingSummary = true;
  AttendanceDaySummary? _todaySummary;
  int _totalMembers = 0;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      // Get total members count
      QuerySnapshot membersSnap =
          await FirebaseFirestore.instance
              .collection('gyms')
              .doc(widget.gymId)
              .collection('members')
              .get();
      _totalMembers = membersSnap.docs.length;

      AttendanceDaySummary summary = await _attendanceService.getTodaySummary(
        widget.gymId,
        _totalMembers,
      );

      if (mounted) {
        setState(() {
          _todaySummary = summary;
          _isLoadingSummary = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading summary: $e");
      if (mounted) {
        setState(() => _isLoadingSummary = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Couldn't load today's summary: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.LightGrey,
      appBar: AppBar(
        title: const Text(
          "Attendance Management",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.DarkBlueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _isLoadingSummary = true);
          await _loadSummary();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTodaySummaryCards(),
              const SizedBox(height: 20),
              _buildMonthListHeader(),
              _buildMonthList(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TODAY'S SUMMARY CARDS
  // ==========================================
  Widget _buildTodaySummaryCards() {
    if (_isLoadingSummary) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    int present = _todaySummary?.presentCount ?? 0;
    int absent = _todaySummary?.absentCount ?? 0;
    double rate = _todaySummary?.attendanceRate ?? 0.0;
    String todayDate = DateFormat('dd MMM yyyy, EEEE').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.DarkBlueGrey, AppColors.BrightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Text(
            todayDate,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  Icons.people,
                  'Total',
                  _totalMembers.toString(),
                  Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  Icons.check_circle,
                  'Present',
                  present.toString(),
                  Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  Icons.cancel,
                  'Absent',
                  absent.toString(),
                  Colors.redAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  Icons.pie_chart,
                  'Rate',
                  '${rate.toStringAsFixed(0)}%',
                  Colors.amberAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    IconData icon,
    String label,
    String value,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MONTH LIST HEADER
  // ==========================================
  Widget _buildMonthListHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: AppColors.DarkBlueGrey),
          const SizedBox(width: 8),
          const Text(
            "Monthly Attendance",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.DarkBlueGrey,
            ),
          ),
          const Spacer(),
          Text(
            "Tap to view details",
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MONTH LIST
  // ==========================================
      Widget _buildMonthList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _attendanceService.getAttendanceMonths(widget.gymId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState("Error: ${snapshot.error}");
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        // CLIENT-SIDE: Parse and sort by year/month descending
        var months = snapshot.data!.docs
            .map((doc) => AttendanceMonthModel.fromFirestore(doc))
            .toList();

        // Sort: newest month first
        months.sort((a, b) {
          int yearComp = b.year.compareTo(a.year);
          if (yearComp != 0) return yearComp;
          return b.month.compareTo(a.month);
        });

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: months.map((month) => _buildMonthCard(month)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildMonthCard(AttendanceMonthModel month) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.attendanceMonthPage,
            arguments: {
              'gymId': widget.gymId,
              'monthKey': month.id,
              'monthLabel': month.monthLabel,
              'year': month.year,
              'monthNum': month.month,
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.blueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${month.month}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.blueColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      month.monthLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.DarkBlueGrey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${month.totalMembers} members tracked',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.event_busy_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "No Attendance Data Available",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Attendance will appear here once members start checking in.",
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
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.orange[300]),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
