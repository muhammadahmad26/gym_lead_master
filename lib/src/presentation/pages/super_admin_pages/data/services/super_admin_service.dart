import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_lead_master/src/presentation/pages/super_admin_pages/data/model/admin_message_model.dart';
import 'package:gym_lead_master/src/presentation/pages/super_admin_pages/data/model/admin_payment_model.dart';
import 'package:gym_lead_master/src/presentation/pages/super_admin_pages/data/model/admin_user_model.dart';

class SuperAdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- AUTHENTICATION & ROLE MANAGEMENT ---

  /// Login as Super Admin with email, password, and secret key
  Future<AdminUser?> loginAsSuperAdmin({
    required String email,
    required String password,
    required String secretKey,
  }) async {
    try {
      // 1. Authenticate with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) return null;

      // 2. Fetch user data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        return null;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      
      // 3. Verify role is super_admin
      if (userData['role'] != 'super_admin') {
        await _auth.signOut();
        return null;
      }

      // 4. Verify secret key
      if (userData['secretKey'] != secretKey) {
        await _auth.signOut();
        return null;
      }

      return AdminUser(
        id: uid,
        email: email,
        name: userData['name'] ?? '',
        location: '',
        phone: '',
        gymName: 'Super Admin',
        status: AdminStatus.active,
        role: UserRole.superAdmin,
        createdAt: (userData['createdAt'] as Timestamp).toDate(),
      );
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  /// Initialize Super Admin account (one-time setup)
  /// FIXED: Replaced fetchSignInMethodsForEmail with try-catch on creation
  Future<void> initializeSuperAdmin({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Try to create the user directly
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) return;

      // Store in Firestore with role and secret key
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'name': name,
        'role': 'super_admin',
        'secretKey': 'SUPER_SECRET_KEY_2024',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Super Admin initialized successfully');
      
    } on FirebaseAuthException catch (e) {
      // This block handles the "User already exists" check
      if (e.code == 'email-already-in-use') {
        print('⚠️ Super Admin already exists (Email is taken)');
        return; 
      }
      
      // Rethrow other authentication errors
      print('❌ Firebase Auth Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ General Error initializing Super Admin: $e');
      rethrow;
    }
  }

  /// Get current Super Admin user
  Future<AdminUser?> getCurrentSuperAdmin() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final userDoc = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!userDoc.exists) return null;

    final userData = userDoc.data() as Map<String, dynamic>;
    if (userData['role'] != 'super_admin') return null;

    return AdminUser(
      id: currentUser.uid,
      email: currentUser.email ?? '',
      name: userData['name'] ?? '',
      location: '',
      phone: '',
      gymName: 'Super Admin',
      status: AdminStatus.active,
      role: UserRole.superAdmin,
      createdAt: (userData['createdAt'] as Timestamp).toDate(),
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  // --- ADMIN MANAGEMENT ---

  /// Get all admins (stream for real-time updates)
  Stream<List<AdminUser>> getAllAdmins() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AdminUser.fromFirestore(doc))
          .toList();
    });
  }

  /// Get admin statistics
  Future<Map<String, int>> getAdminStats() async {
    try {
      final adminsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      final membersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'member')
          .get();

      final activeAdmins = adminsSnapshot.docs
          .where((doc) => (doc.data())['status'] == 'active')
          .length;

      final pendingAdmins = adminsSnapshot.docs
          .where((doc) => (doc.data())['status'] == 'pending')
          .length;

      return {
        'totalAdmins': adminsSnapshot.docs.length,
        'activeAdmins': activeAdmins,
        'pendingAdmins': pendingAdmins,
        'totalMembers': membersSnapshot.docs.length,
      };
    } catch (e) {
      print('Error getting stats: $e');
      return {
        'totalAdmins': 0,
        'activeAdmins': 0,
        'pendingAdmins': 0,
        'totalMembers': 0,
      };
    }
  }

  /// Get admins grouped by gym
  Future<Map<String, List<AdminUser>>> getAdminsByGym() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      final Map<String, List<AdminUser>> grouped = {};

      for (var doc in snapshot.docs) {
        final admin = AdminUser.fromFirestore(doc);
        final gymName = admin.gymName;
        if (!grouped.containsKey(gymName)) {
          grouped[gymName] = [];
        }
        grouped[gymName]!.add(admin);
      }

      return grouped;
    } catch (e) {
      print('Error grouping admins by gym: $e');
      return {};
    }
  }

  /// Approve an admin
  Future<void> approveAdmin(String adminId, String superAdminId) async {
    try {
      await _firestore
          .collection('users')
          .doc(adminId)
          .update({
            'status': 'active',
            'approvedAt': FieldValue.serverTimestamp(),
            'approvedBy': superAdminId,
          });
      print('Admin approved: $adminId');
    } catch (e) {
      print('Error approving admin: $e');
      rethrow;
    }
  }

  /// Reject an admin
  Future<void> rejectAdmin(String adminId, String superAdminId, String reason) async {
    try {
      await _firestore
          .collection('users')
          .doc(adminId)
          .update({
            'status': 'rejected',
            'rejectionReason': reason,
            'blockedBy': superAdminId,
          });
      print('Admin rejected: $adminId');
    } catch (e) {
      print('Error rejecting admin: $e');
      rethrow;
    }
  }

  /// Block an admin
  Future<void> blockAdmin(String adminId, String superAdminId) async {
    try {
      await _firestore
          .collection('users')
          .doc(adminId)
          .update({
            'status': 'blocked',
            'blockedAt': FieldValue.serverTimestamp(),
            'blockedBy': superAdminId,
          });
      print('Admin blocked: $adminId');
    } catch (e) {
      print('Error blocking admin: $e');
      rethrow;
    }
  }

  /// Create new admin
  Future<String> createAdmin({
    required String email,
    required String password,
    required String name,
    required String gymName,
    required String phone,
    required String location,
    required String createdBy,
  }) async {
    try {
      // Create auth user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) throw Exception('Failed to create user');

      // Store admin data
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'name': name,
        'gymName': gymName,
        'phone': phone,
        'location': location,
        'role': 'admin',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': createdBy,
      });

      print('Admin created: $uid');
      return uid;
    } catch (e) {
      print('Error creating admin: $e');
      rethrow;
    }
  }

  // --- PAYMENT MANAGEMENT ---

  /// Get all payments (stream for real-time updates)
  Stream<List<AdminPayment>> getAllPayments() {
    return _firestore
        .collection('payments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AdminPayment.fromFirestore(doc))
          .toList();
    });
  }

  /// Get payments by status
  Stream<List<AdminPayment>> getPaymentsByStatus(PaymentStatus status) {
    return _firestore
        .collection('payments')
        .where('status', isEqualTo: status.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AdminPayment.fromFirestore(doc))
          .toList();
    });
  }

  /// Approve payment
  Future<void> approvePayment(String paymentId, String superAdminId) async {
    try {
      await _firestore.collection('payments').doc(paymentId).update({
        'status': 'approved',
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': superAdminId,
      });
      print('Payment approved: $paymentId');
    } catch (e) {
      print('Error approving payment: $e');
      rethrow;
    }
  }

  /// Reject payment
  Future<void> rejectPayment(
    String paymentId,
    String superAdminId,
    String reason,
  ) async {
    try {
      await _firestore.collection('payments').doc(paymentId).update({
        'status': 'failed',
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': superAdminId,
        'rejectionReason': reason,
      });
      print('Payment rejected: $paymentId');
    } catch (e) {
      print('Error rejecting payment: $e');
      rethrow;
    }
  }

  // --- MESSAGE MANAGEMENT ---

  /// Get all message threads (unique conversations)
  Stream<List<MessageThread>> getMessageThreads(String superAdminId) {
    return _firestore
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final allMessages = snapshot.docs
          .map((doc) => AdminMessage.fromFirestore(doc))
          .toList();

      // Group messages by participant
      final Map<String, List<AdminMessage>> grouped = {};
      final Map<String, String> lastMessageTexts = {};
      final Map<String, DateTime> lastMessageTimes = {};
      final Map<String, int> unreadCounts = {};

      for (var msg in allMessages) {
        // Only show messages between Super Admin and admins
        if (msg.senderRole != 'admin') continue;

        final key = msg.senderId;
        if (!grouped.containsKey(key)) {
          grouped[key] = [];
        }
        grouped[key]!.add(msg);

        if (!lastMessageTimes.containsKey(key) ||
            msg.timestamp.isAfter(lastMessageTimes[key]!)) {
          lastMessageTimes[key] = msg.timestamp;
          lastMessageTexts[key] = msg.text;
        }

        if (!msg.isRead) {
          unreadCounts[key] = (unreadCounts[key] ?? 0) + 1;
        }
      }

      // Convert to MessageThread objects
      return grouped.entries.map((entry) {
        return MessageThread(
          threadId: entry.key,
          participantId: entry.key,
          participantName: entry.value.first.senderName,
          participantEmail: entry.value.first.senderEmail,
          participantRole: entry.value.first.senderRole,
          messages: entry.value,
          lastMessageTime: lastMessageTimes[entry.key] ?? DateTime.now(),
          unreadCount: unreadCounts[entry.key] ?? 0,
          lastMessageText: lastMessageTexts[entry.key] ?? '',
        );
      }).toList();
    });
  }

  /// Get messages for a specific thread
  Stream<List<AdminMessage>> getThreadMessages(String participantId) {
    return _firestore
        .collection('messages')
        .where('senderId', isEqualTo: participantId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AdminMessage.fromFirestore(doc))
          .toList();
    });
  }

  /// Send message to admin
  Future<void> sendMessage({
    required String senderId,
    required String senderName,
    required String senderEmail,
    required String senderRole,
    required String text,
  }) async {
    try {
      await _firestore.collection('messages').add({
        'senderId': senderId,
        'senderName': senderName,
        'senderEmail': senderEmail,
        'senderRole': senderRole,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
      print('Message sent');
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  /// Mark messages as read
  Future<void> markAsRead(List<String> messageIds) async {
    final batch = _firestore.batch();
    for (final messageId in messageIds) {
      final docRef = _firestore.collection('messages').doc(messageId);
      batch.update(docRef, {'isRead': true});
    }
    await batch.commit();
    print('Messages marked as read');
  }
}