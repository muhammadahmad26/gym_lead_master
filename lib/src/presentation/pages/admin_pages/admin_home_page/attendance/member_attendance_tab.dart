import 'package:flutter/material.dart';
import 'package:gym_lead_master/services/attendance_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/data/models/attendance_model.dart';

class MemberAttendanceTab extends StatefulWidget {
  final String gymId;
  final String memberId;
  final String memberName;

  const MemberAttendanceTab({
    super.key,
    required this.gymId,
    required this.memberId,
    required this.memberName,
  });

  @override
  State<MemberAttendanceTab> createState() => _MemberAttendanceTabState();
}

class _MemberAttendanceTabState extends State<MemberAttendanceTab> {
  final AttendanceService _attendanceService = AttendanceService();
  List<Map<String, dynamic>> _allAttendance = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var data = await _attendanceService.getMemberAllAttendance(
        widget.gymId,
        widget.memberId,
      );
      if (mounted) {
        setState(() {
          _allAttendance = data;
          _isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 8),
            Text(_errorMessage!,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: _loadAttendance, child: const Text("Retry")),
          ],
        ),
      );
    }

    if (_allAttendance.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_outlined,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Text("No Attendance Data Available",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey)),
            const SizedBox(height: 4),
            const Text("Attendance will appear after check-ins.",
                style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _allAttendance.length,
      itemBuilder: (context, index) {
        var item = _allAttendance[index];
        int year = item['year'] as int;
        int month = item['month'] as int;
        MemberAttendanceModel attendance =
            item['attendance'] as MemberAttendanceModel;
        String monthKey = item['monthKey'] as String;

        return _buildMonthCard(attendance, year, month, monthKey);
      },
    );
  }

  Widget _buildMonthCard(
    MemberAttendanceModel attendance,
    int year,
    int month,
    String monthKey,
  ) {
    int absentDays = attendance.totalAbsent(year, month);
    double percentage = attendance.attendancePercentage(year, month);
    int totalDays = attendance.totalDaysInMonth(year, month);
    Color percentColor = percentage >= 75
        ? Colors.green
        : percentage >= 50
            ? Colors.orange
            : Colors.red;

    const monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    String monthLabel = '${monthNames[month]} $year';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month header
            Row(
              children: [
                Expanded(
                  child: Text(
                    monthLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: AppColors.DarkBlueGrey,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: percentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: percentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Stats row
            Row(
              children: [
                _buildStatItem('Present', '${attendance.totalPresent}',
                    Colors.green, Icons.check_circle),
                const SizedBox(width: 16),
                _buildStatItem(
                    'Absent', '$absentDays', Colors.red, Icons.cancel),
                const SizedBox(width: 16),
                _buildStatItem(
                    'Total Days', '$totalDays', Colors.blue, Icons.calendar_today),
              ],
            ),

            const SizedBox(height: 12),

            // Day grid
            _buildDayGrid(attendance, year, month),

            const SizedBox(height: 8),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(percentColor),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildDayGrid(MemberAttendanceModel attendance, int year, int month) {
    int totalDays = attendance.totalDaysInMonth(year, month);
    DateTime now = DateTime.now();
    int upToDay = (year == now.year && month == now.month) ? now.day : totalDays;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(upToDay, (index) {
        int day = index + 1;
        DayAttendance? dayAtt = attendance.days[day];
        bool isPresent = dayAtt != null && dayAtt.status == 'present';

        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isPresent
                ? Colors.green.withOpacity(0.15)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isPresent
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.2),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isPresent ? Colors.green[700] : Colors.red[400],
                  ),
                ),
                Icon(
                  isPresent ? Icons.check : Icons.close,
                  size: 10,
                  color: isPresent ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}