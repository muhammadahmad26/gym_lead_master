import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/src/data/models/attendance_model.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<void> recordAttendance({
    required String gymId,
    required String memberId,
    required String memberName,
    required String memberEmail,
  }) async {
    try {
      DateTime now = DateTime.now();
      String monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      String dayKey = now.day.toString();

      DocumentReference monthRef = _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('attendance_months')
          .doc(monthKey);

      DocumentReference recordRef = monthRef
          .collection('records')
          .doc(memberId);

     
      DocumentSnapshot monthDoc = await monthRef.get();
      if (!monthDoc.exists) {
        await monthRef.set({
          'year': now.year,
          'month': now.month,
          'gymId': gymId,
          'totalMembers': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(), // Ensured
        });
      }

      // STEP 2: Check if already recorded today
      DocumentSnapshot recordDoc = await recordRef.get();

      if (recordDoc.exists) {
        Map<String, dynamic> data = recordDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> days = Map<String, dynamic>.from(
          data['days'] ?? {},
        );

        if (days.containsKey(dayKey)) {
          debugPrint("Already recorded present today for $memberName");
          return;
        }

        days[dayKey] = {'status': 'present', 'checkInTime': Timestamp.now()};

        int currentTotal = (data['totalPresent'] ?? 0) + 1;

        await recordRef.update({
          'days': days,
          'totalPresent': currentTotal,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await recordRef.set({
          'memberId': memberId,
          'memberName': memberName,
          'memberEmail': memberEmail,
          'days': {
            dayKey: {'status': 'present', 'checkInTime': Timestamp.now()},
          },
          'totalPresent': 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // STEP 3: Update month doc timestamp
      await monthRef.update({
        'updatedAt': FieldValue.serverTimestamp(), // Ensured
      });

      debugPrint("Attendance recorded: $memberName present on day $dayKey");
    } catch (e) {
      debugPrint("Error recording attendance: $e");
      rethrow;
    }
  }

  // ==========================================
  // GET ATTENDANCE MONTHS LIST
  // ==========================================

  Stream<QuerySnapshot> getAttendanceMonths(String gymId) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('attendance_months')
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

 

  Future<List<MemberAttendanceModel>> getMonthRecords(
    String gymId,
    String monthKey,
  ) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('gyms')
              .doc(gymId)
              .collection('attendance_months')
              .doc(monthKey)
              .collection('records')
              .get();

      return snapshot.docs
          .map((doc) => MemberAttendanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint("Error getting month records: $e");
      rethrow;
    }
  }

  // ==========================================
  // GET MEMBER ATTENDANCE FOR A MONTH
  // ==========================================

  Future<MemberAttendanceModel?> getMemberMonthAttendance(
    String gymId,
    String monthKey,
    String memberId,
  ) async {
    try {
      DocumentSnapshot doc =
          await _firestore
              .collection('gyms')
              .doc(gymId)
              .collection('attendance_months')
              .doc(monthKey)
              .collection('records')
              .doc(memberId)
              .get();

      if (doc.exists) {
        return MemberAttendanceModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint("Error getting member attendance: $e");
      rethrow;
    }
  }

  // ==========================================
  // GET MEMBER ATTENDANCE FOR ALL MONTHS
  // ==========================================

  Future<List<Map<String, dynamic>>> getMemberAllAttendance(
    String gymId,
    String memberId,
  ) async {
    try {
      QuerySnapshot monthsSnapshot =
          await _firestore
              .collection('gyms')
              .doc(gymId)
              .collection('attendance_months')
              .get();

      List<Map<String, dynamic>> result = [];

      for (var monthDoc in monthsSnapshot.docs) {
        DocumentSnapshot recordDoc =
            await _firestore
                .collection('gyms')
                .doc(gymId)
                .collection('attendance_months')
                .doc(monthDoc.id)
                .collection('records')
                .doc(memberId)
                .get();

        if (recordDoc.exists) {
          var attendance = MemberAttendanceModel.fromFirestore(recordDoc);
          var monthData = monthDoc.data() as Map<String, dynamic>;
          result.add({
            'monthKey': monthDoc.id,
            'year': monthData['year'] ?? 2026,
            'month': monthData['month'] ?? 1,
            'attendance': attendance,
          });
        }
      }

      // Sort by date descending
      result.sort((a, b) {
        int yearComp = (b['year'] as int).compareTo(a['year'] as int);
        if (yearComp != 0) return yearComp;
        return (b['month'] as int).compareTo(a['month'] as int);
      });

      return result;
    } catch (e) {
      debugPrint("Error getting member all attendance: $e");
      rethrow;
    }
  }

  // ==========================================
  // TODAY'S ATTENDANCE SUMMARY
  // ==========================================

  Future<AttendanceDaySummary> getTodaySummary(
    String gymId,
    int totalMembersCount,
  ) async {
    try {
      DateTime now = DateTime.now();
      String monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      String dayKey = now.day.toString();

      QuerySnapshot snapshot =
          await _firestore
              .collection('gyms')
              .doc(gymId)
              .collection('attendance_months')
              .doc(monthKey)
              .collection('records')
              .get();

      int presentCount = 0;
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        var days = data['days'] as Map<String, dynamic>?;
        if (days != null && days.containsKey(dayKey)) {
          var dayData = days[dayKey] as Map<String, dynamic>;
          if (dayData['status'] == 'present') {
            presentCount++;
          }
        }
      }

      int absentCount = totalMembersCount - presentCount;
      double rate =
          totalMembersCount > 0
              ? (presentCount / totalMembersCount) * 100
              : 0.0;

      return AttendanceDaySummary(
        totalMembers: totalMembersCount,
        presentCount: presentCount,
        absentCount: absentCount,
        attendanceRate: rate,
      );
    } catch (e) {
      debugPrint("Error getting today summary: $e");
      rethrow;
    }
  }

  // ==========================================
  // DELETE MONTH ATTENDANCE
  // ==========================================

  Future<void> deleteMonthAttendance(String gymId, String monthKey) async {
    try {
      WriteBatch batch = _firestore.batch();
      int opCount = 0;

      // Delete all records in the month
      QuerySnapshot records =
          await _firestore
              .collection('gyms')
              .doc(gymId)
              .collection('attendance_months')
              .doc(monthKey)
              .collection('records')
              .get();

      for (var doc in records.docs) {
        batch.delete(doc.reference);
        opCount++;
        if (opCount >= 490) {
          await batch.commit();
          batch = _firestore.batch();
          opCount = 0;
        }
      }

      if (opCount > 0) {
        await batch.commit();
      }

      // Delete the month document itself
      await _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('attendance_months')
          .doc(monthKey)
          .delete();

      debugPrint("Deleted attendance for month: $monthKey");
    } catch (e) {
      debugPrint("Error deleting month attendance: $e");
      rethrow;
    }
  }

  // ==========================================
  // MANUALLY MARK ABSENT (for admin corrections)
  // ==========================================

  Future<void> markMemberAbsent({
    required String gymId,
    required String monthKey,
    required String memberId,
    required int day,
  }) async {
    try {
      DocumentReference recordRef = _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('attendance_months')
          .doc(monthKey)
          .collection('records')
          .doc(memberId);

      DocumentSnapshot doc = await recordRef.get();
      if (!doc.exists) return;

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Map<String, dynamic> days = Map<String, dynamic>.from(data['days'] ?? {});

      String dayKey = day.toString();

      // If was present, decrement totalPresent
      int currentTotal = data['totalPresent'] ?? 0;
      if (days.containsKey(dayKey)) {
        var dayData = days[dayKey] as Map<String, dynamic>;
        if (dayData['status'] == 'present') {
          currentTotal--;
        }
      }

      days[dayKey] = {'status': 'absent', 'checkInTime': null};

      await recordRef.update({
        'days': days,
        'totalPresent': currentTotal,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error marking absent: $e");
      rethrow;
    }
  }

  // ==========================================
  // UPDATE MEMBER NAME IN ATTENDANCE RECORDS
  // (Call when member updates their profile)
  // ==========================================

  Future<void> updateMemberNameInAttendance({
    required String gymId,
    required String memberId,
    required String newName,
  }) async {
    try {
      QuerySnapshot monthsSnapshot =
          await _firestore
              .collection('gyms')
              .doc(gymId)
              .collection('attendance_months')
              .get();

      for (var monthDoc in monthsSnapshot.docs) {
        DocumentReference recordRef = _firestore
            .collection('gyms')
            .doc(gymId)
            .collection('attendance_months')
            .doc(monthDoc.id)
            .collection('records')
            .doc(memberId);

        DocumentSnapshot recordDoc = await recordRef.get();
        if (recordDoc.exists) {
          await recordRef.update({'memberName': newName});
        }
      }
    } catch (e) {
      debugPrint("Error updating member name in attendance: $e");
    }
  }
}
