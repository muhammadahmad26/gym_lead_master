import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gym_lead_master/services/attendance_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- STREAMS ---
  Stream<DocumentSnapshot> getUserStream() {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .snapshots();
  }

  Stream<DocumentSnapshot> getGymStatsStream(String gymId) {
    String todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('stats')
        .doc(todayKey)
        .snapshots();
  }

  Stream<QuerySnapshot> getMembersStream(String gymId) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('members')
        .orderBy('joinDate', descending: true)
        .snapshots();
  }

  // ==========================================
  // CHECK-IN LOGIC (FIXED: No transaction, Web-safe)
  // ==========================================
  Future<String> performCheckIn({
    required String gymId,
    required Map<String, bool> selectedExercises,
  }) async {
    try {
      String uid = _auth.currentUser!.uid;
      DateTime now = DateTime.now();
      String todayKey = DateFormat('yyyy-MM-dd').format(now);

      // ==========================================
      // STEP 1: Check if already checked in today
      // ==========================================
      DocumentSnapshot memberDoc =
          await _firestore
              .collection('gyms')
              .doc(gymId)
              .collection('members')
              .doc(uid)
              .get();

      if (memberDoc.exists) {
        var memberData = memberDoc.data() as Map<String, dynamic>;
        Timestamp? lastCheckIn = memberData['checkInTime'];

        if (lastCheckIn != null) {
          DateTime lastCheckInDate = lastCheckIn.toDate();
          String lastCheckInDay = DateFormat(
            'yyyy-MM-dd',
          ).format(lastCheckInDate);

          if (lastCheckInDay == todayKey) {
            return "already_checked_in";
          }
        }
      }

      // ==========================================
    
      // Uses FieldValue.increment which is ATOMIC in Firestore
      // ==========================================
      List<String> activeExercises =
          selectedExercises.entries
              .where((entry) => entry.value == true)
              .map((entry) => entry.key)
              .toList();

      Timestamp nowTimestamp = Timestamp.now();

      DocumentReference statRef = _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('stats')
          .doc(todayKey);

      // Atomic increment - no transaction needed!
      await statRef.set({
        'totalLiveMembers': FieldValue.increment(1),
        'chest': FieldValue.increment(
          activeExercises.contains('Chest') ? 1 : 0,
        ),
        'leg': FieldValue.increment(activeExercises.contains('Leg') ? 1 : 0),
        'triceps': FieldValue.increment(
          activeExercises.contains('Triceps') ? 1 : 0,
        ),
        'biceps': FieldValue.increment(
          activeExercises.contains('Biceps') ? 1 : 0,
        ),
        'cardio': FieldValue.increment(
          activeExercises.contains('Cardio') ? 1 : 0,
        ),
        'weightLoss': FieldValue.increment(
          activeExercises.contains('Weight loss') ? 1 : 0,
        ),
        'date': nowTimestamp,
      }, SetOptions(merge: true));

      // ==========================================
      // STEP 3: Update member record
      // ==========================================
      await _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('members')
          .doc(uid)
          .update({
            'lastVisit': nowTimestamp,
            'currentExercises': activeExercises,
            'checkInTime': nowTimestamp,
          });

      // ==========================================
      // STEP 4: Record attendance
      // ==========================================
      try {
        var memberData = memberDoc.data() as Map<String, dynamic>;
        String memberName = memberData['name'] ?? 'Unknown';
        String memberEmail = memberData['email'] ?? '';

        await AttendanceService().recordAttendance(
          gymId: gymId,
          memberId: uid,
          memberName: memberName,
          memberEmail: memberEmail,
        );
      } catch (e) {
        print("⚠️ Attendance recording failed (check-in still saved): $e");
      }

      return "success";
    } catch (e) {
      print("Check-in error: $e");
      rethrow;
    }
  }

  // ==========================================
  //  PAYMENT METHODS CRUD
  // ==========================================
  Stream<QuerySnapshot> getPaymentMethodsList(String gymId) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('payment_methods')
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  Future<void> addPaymentMethod(
    String gymId,
    Map<String, dynamic> method,
  ) async {
    await _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('payment_methods')
        .add({
          ...method,
          'gymId': gymId,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> updatePaymentMethod(
    String gymId,
    String methodId,
    Map<String, dynamic> method,
  ) async {
    await _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('payment_methods')
        .doc(methodId)
        .update(method);
  }

  Future<void> deletePaymentMethod(String gymId, String methodId) async {
    await _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('payment_methods')
        .doc(methodId)
        .update({'isActive': false});
  }

  // ==========================================
  // MEMBERSHIP PLANS CRUD
  // ==========================================
  Stream<QuerySnapshot> getMembershipPlans(String gymId) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('membership_plans')
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  Future<void> addMembershipPlan(
    String gymId,
    Map<String, dynamic> plan,
  ) async {
    await _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('membership_plans')
        .add({
          ...plan,
          'gymId': gymId,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> updateMembershipPlan(
    String gymId,
    String planId,
    Map<String, dynamic> plan,
  ) async {
    await _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('membership_plans')
        .doc(planId)
        .update(plan);
  }

  Future<void> deleteMembershipPlan(String gymId, String planId) async {
    await _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('membership_plans')
        .doc(planId)
        .update({'isActive': false});
  }

  // ==========================================
  // PAYMENT TRANSACTIONS (FIXED)
  // ==========================================

  ///  FIX: Single where clause to avoid composite index requirement
  /// Get all payments for a member, then filter client-side
  Future<QuerySnapshot> getMemberPayments(String gymId, String memberId) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('payments')
        .where('memberId', isEqualTo: memberId)
        .get();
  }

  ///  FIX: Find NOT_PAID transaction from already-fetched results
  /// Returns the DocumentReference of the NOT_PAID transaction, or null
  Future<DocumentReference?> findOrCreateNotPaidTransaction(
    String gymId,
    String memberId,
  ) async {
    try {
      print("STEP 1: Fetching member payments for memberId: $memberId");

      QuerySnapshot snapshot =
          await _firestore
              .collection('gyms')
              .doc(gymId)
              .collection('payments')
              .where('memberId', isEqualTo: memberId)
              .get();

      print("STEP 2: Found ${snapshot.docs.length} total payment docs");

      //  Client-side filter for NOT_PAID (avoids composite index)
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? '';
        print("Doc ${doc.id}: status = $status");

        if (status == 'not_paid') {
          print("STEP 3: Found existing NOT_PAID doc: ${doc.id}");
          return doc.reference;
        }
      }

      //  No NOT_PAID found → Check if member has PENDING (don't create duplicate)
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? '';
        if (status == 'pending') {
          print("Member has PENDING payment. Cannot create new.");
          return null; // Signal that payment is already pending
        }
      }

      // No NOT_PAID and no PENDING → Create new NOT_PAID transaction
      print("STEP 4: No NOT_PAID found. Creating new one...");

      // Get member details for denormalization
      String memberName = '';
      String memberEmail = '';
      try {
        var userDoc = await _firestore.collection('users').doc(memberId).get();
        if (userDoc.exists) {
          memberName = userDoc.data()?['name'] ?? '';
          memberEmail = userDoc.data()?['email'] ?? '';
        }
      } catch (e) {
        print("Could not fetch user details: $e");
      }

      DocumentReference newDocRef = await _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('payments')
          .add({
            'memberId': memberId,
            'memberName': memberName,
            'memberEmail': memberEmail,
            'gymId': gymId,
            'planId': '',
            'planName': 'No Plan Selected',
            'amount': 0.0,
            'duration': '',
            'paymentMethodId': '',
            'paymentMethodType': '',
            'paymentMethodLabel': '',
            'accountTitle': '',
            'accountNumber': '',
            'screenshotUrl': '',
            'status': 'not_paid',
            'createdAt': FieldValue.serverTimestamp(),
            'submittedAt': null,
            'approvedAt': null,
            'rejectedAt': null,
            'reviewedBy': '',
            'rejectionReason': '',
          });

      print("STEP 5: Created new NOT_PAID doc: ${newDocRef.id}");
      return newDocRef;
    } catch (e) {
      print("ERROR in findOrCreateNotPaidTransaction: $e");
      rethrow;
    }
  }

  /// Member Submits Payment
  /// Member Submits Payment (With Base64 Image)
  Future<String> submitPayment({
    required String gymId,
    required DocumentReference paymentDocRef,
    required String planId,
    required String planName,
    required double amount,
    required String duration,
    required String paymentMethodId,
    required String paymentMethodType,
    required String paymentMethodLabel,
    required String accountTitle,
    required String accountNumber,
    required String screenshotUrl,// Changed from URL to Base64
  }) async {
    try {
      print("STEP 6: Updating payment doc to PENDING...");

      await paymentDocRef.update({
        'planId': planId,
        'planName': planName,
        'amount': amount,
        'duration': duration,
        'paymentMethodId': paymentMethodId,
        'paymentMethodType': paymentMethodType,
        'paymentMethodLabel': paymentMethodLabel,
        'accountTitle': accountTitle,
        'accountNumber': accountNumber,
        'screenshotUrl': screenshotUrl, // Save Base64 string in Firestore
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      });

      print("STEP 7: Payment updated to PENDING successfully!");
      return "success";
    } catch (e) {
      print("ERROR in submitPayment: $e");
      rethrow;
    }
  }

  /// Get all payments for Admin (single where or no where)
  Stream<QuerySnapshot> getAllPayments(String gymId, {String? statusFilter}) {
    if (statusFilter != null && statusFilter.isNotEmpty) {
      return _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('payments')
          .where('status', isEqualTo: statusFilter)
          .snapshots();
    }
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('payments')
        .snapshots();
  }

  /// Member Payment History (single where only - no orderBy to avoid index)
  Stream<QuerySnapshot> getMemberPaymentHistory(String gymId, String memberId) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('payments')
        .where('memberId', isEqualTo: memberId)
        .snapshots();
  }

  /// Admin Approves Payment
  Future<void> approvePayment(
    String gymId,
    String paymentId,
    String memberId,
  ) async {
    String adminUid = FirebaseAuth.instance.currentUser!.uid;

    await _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('payments')
        .doc(paymentId)
        .update({
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
          'reviewedBy': adminUid,
        });

    await _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('members')
        .doc(memberId)
        .update({'membershipStatus': 'active'});
  }

  /// Admin Rejects Payment
  Future<void> rejectPayment(
    String gymId,
    String paymentId,
    String memberId, {
    String reason = '',
  }) async {
    String adminUid = FirebaseAuth.instance.currentUser!.uid;

    await _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('payments')
        .doc(paymentId)
        .update({
          'status': 'failed',
          'rejectedAt': FieldValue.serverTimestamp(),
          'reviewedBy': adminUid,
          'rejectionReason': reason,
        });

    // Create new NOT_PAID so member can retry
    String memberName = '';
    String memberEmail = '';
    try {
      var userDoc = await _firestore.collection('users').doc(memberId).get();
      if (userDoc.exists) {
        memberName = userDoc.data()?['name'] ?? '';
        memberEmail = userDoc.data()?['email'] ?? '';
      }
    // ignore: empty_catches
    } catch (e) {}

    await _firestore.collection('gyms').doc(gymId).collection('payments').add({
      'memberId': memberId,
      'memberName': memberName,
      'memberEmail': memberEmail,
      'gymId': gymId,
      'planId': '',
      'planName': 'No Plan Selected',
      'amount': 0.0,
      'duration': '',
      'paymentMethodId': '',
      'paymentMethodType': '',
      'paymentMethodLabel': '',
      'accountTitle': '',
      'accountNumber': '',
      'screenshotUrl': '',
      'status': 'not_paid',
      'createdAt': FieldValue.serverTimestamp(),
      'submittedAt': null,
      'approvedAt': null,
      'rejectedAt': null,
      'reviewedBy': '',
      'rejectionReason': '',
    });
  }

  // OLD METHOD - kept for profile page compatibility
  Future<void> updatePaymentSettings(
    String gymId,
    Map<String, dynamic> settings,
  ) async {
    await _firestore.collection('gyms').doc(gymId).set({
      'paymentMethods': settings,
    }, SetOptions(merge: true));
  }

  // ==========================================
  // CHAT LOGIC (kept as is)
  // ==========================================
  String getChatRoomId(String uid1, String uid2) {
    List<String> uids = [uid1, uid2];
    uids.sort();
    return '${uids[0]}_${uids[1]}';
  }

  Stream<QuerySnapshot> getGymUsers(String gymId) {
    return _firestore
        .collection('users')
        .where('gymId', isEqualTo: gymId)
        .snapshots();
  }

  Stream<QuerySnapshot> getChatMessages(String gymId, String chatRoomId) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage({
    required String gymId,
    required String chatRoomId,
    required String text,
    required String senderUid,
    required Map<String, dynamic> senderData,
    required Map<String, dynamic> receiverData,
  }) async {
    await _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
          'text': text,
          'senderId': senderUid,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });

    String receiverUid = receiverData['uid'];
    await _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('chat_rooms')
        .doc(chatRoomId)
        .set({
          'lastMessage': text,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'user1': senderData,
          'user2': receiverData,
          'unreadCount_$receiverUid': FieldValue.increment(1),
          'unreadCount_$senderUid': 0,
        }, SetOptions(merge: true));
  }

  Future<void> markMessagesAsRead(
    String gymId,
    String chatRoomId,
    String currentUserId,
  ) async {
    QuerySnapshot unreadMessages =
        await _firestore
            .collection('gyms')
            .doc(gymId)
            .collection('chat_rooms')
            .doc(chatRoomId)
            .collection('messages')
            .where('isRead', isEqualTo: false)
            .get();

    WriteBatch batch = _firestore.batch();
    int updateCount = 0;
    for (QueryDocumentSnapshot doc in unreadMessages.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data['senderId'] != currentUserId) {
        batch.update(doc.reference, {'isRead': true});
        updateCount++;
      }
    }
    if (updateCount > 0) {
      batch.set(
        _firestore
            .collection('gyms')
            .doc(gymId)
            .collection('chat_rooms')
            .doc(chatRoomId),
        {'unreadCount_$currentUserId': 0},
        SetOptions(merge: true),
      );
      await batch.commit();
    }
  }

  Stream<DocumentSnapshot> getChatRoomData(String gymId, String chatRoomId) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('chat_rooms')
        .doc(chatRoomId)
        .snapshots();
  }

  Future<void> deleteMessageForEveryone(
    String gymId,
    String chatRoomId,
    String messageId,
  ) async {
    await _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update({'deletedForEveryone': true});
  }

  Future<void> saveLocalDeletedMessages(
    String chatRoomId,
    List<String> messageIds,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedIds =
        prefs.getStringList('deleted_msgs_$chatRoomId') ?? [];
    savedIds.addAll(messageIds);
    await prefs.setStringList(
      'deleted_msgs_$chatRoomId',
      savedIds.toSet().toList(),
    );
  }
}
