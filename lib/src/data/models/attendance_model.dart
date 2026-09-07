import 'package:cloud_firestore/cloud_firestore.dart';


class AttendanceMonthModel {
  final String id; 
  final int year;
  final int month;
  final String gymId;
  final int totalMembers;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AttendanceMonthModel({
    required this.id,
    required this.year,
    required this.month,
    required this.gymId,
    this.totalMembers = 0,
    this.createdAt,
    this.updatedAt,
  });

  String get monthLabel {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[month]} $year';
  }

  factory AttendanceMonthModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AttendanceMonthModel(
      id: doc.id,
      year: data['year'] ?? 2026,
      month: data['month'] ?? 1,
      gymId: data['gymId'] ?? '',
      totalMembers: data['totalMembers'] ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'gymId': gymId,
      'totalMembers': totalMembers,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Single day's attendance entry
class DayAttendance {
  final String status; 
  final DateTime? checkInTime;

  DayAttendance({required this.status, this.checkInTime});

  factory DayAttendance.fromMap(Map<String, dynamic> data) {
    return DayAttendance(
      status: data['status'] ?? 'absent',
      checkInTime: data['checkInTime'] != null
          ? (data['checkInTime'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'checkInTime': checkInTime != null
          ? Timestamp.fromDate(checkInTime!)
          : null,
    };
  }
}

/// Per-member attendance for a month
class MemberAttendanceModel {
  final String id; // memberId
  final String memberId;
  final String memberName;
  final String memberEmail;
  final Map<int, DayAttendance> days; 
  final int totalPresent;
  final DateTime? updatedAt;

  MemberAttendanceModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.memberEmail,
    required this.days,
    required this.totalPresent,
    this.updatedAt,
  });

  int totalDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int totalAbsent(int year, int month) {
    int totalDays = totalDaysInMonth(year, month);
   
    DateTime now = DateTime.now();
    int countableDays;
    if (year == now.year && month == now.month) {
      countableDays = now.day; 
    } else {
      countableDays = totalDays; 
    }
    return countableDays - totalPresent;
  }


  double attendancePercentage(int year, int month) {
    DateTime now = DateTime.now();
    int countableDays;
    if (year == now.year && month == now.month) {
      countableDays = now.day;
    } else {
      countableDays = totalDaysInMonth(year, month);
    }
    if (countableDays == 0) return 0.0;
    return (totalPresent / countableDays) * 100;
  }

  factory MemberAttendanceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    Map<int, DayAttendance> days = {};
    if (data['days'] != null) {
      var daysMap = data['days'] as Map<String, dynamic>;
      daysMap.forEach((key, value) {
        int? dayNum = int.tryParse(key);
        if (dayNum != null && value is Map<String, dynamic>) {
          days[dayNum] = DayAttendance.fromMap(value);
        }
      });
    }

    return MemberAttendanceModel(
      id: doc.id,
      memberId: data['memberId'] ?? '',
      memberName: data['memberName'] ?? 'Unknown',
      memberEmail: data['memberEmail'] ?? '',
      days: days,
      totalPresent: data['totalPresent'] ?? 0,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> daysMap = {};
    days.forEach((key, value) {
      daysMap[key.toString()] = value.toMap();
    });

    return {
      'memberId': memberId,
      'memberName': memberName,
      'memberEmail': memberEmail,
      'days': daysMap,
      'totalPresent': totalPresent,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class AttendanceDaySummary {
  final int totalMembers;
  final int presentCount;
  final int absentCount;
  final double attendanceRate;

  AttendanceDaySummary({
    required this.totalMembers,
    required this.presentCount,
    required this.absentCount,
    required this.attendanceRate,
  });
}