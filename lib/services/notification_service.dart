import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/src/data/models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================================
  // ADMIN: CRUD OPERATIONS
  // ==========================================


  Future<void> sendNotificationToMembers({
    required String gymId,
    required String title,
    required String message,
    required NotificationType type,
    required List<String> targetUserIds,
  }) async {
    try {
      String adminUid = _auth.currentUser!.uid;
      List<String> userIds = targetUserIds;

      // If broadcast, fetch all member UIDs of the gym
      if (targetUserIds.contains('all')) {
        QuerySnapshot membersSnap = await _firestore
            .collection('gyms')
            .doc(gymId)
            .collection('members')
            .get();
        userIds = membersSnap.docs.map((doc) => doc.id).toList();
      }

      // STEP 1: Create gym notification first to get its ID
      DocumentReference gymNotifRef = _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('notifications')
          .doc();

      String gymNotifDocId = gymNotifRef.id;

      WriteBatch batch = _firestore.batch();
      int opCount = 0;

      // STEP 2: Save to Gym Notifications (Admin log)
      batch.set(gymNotifRef, {
        'gymId': gymId,
        'title': title,
        'message': message,
        'type': type.name,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': adminUid,
        'isDeleted': false,
        'deletedAt': null,
        'gymNotifId': gymNotifDocId,
        'targetCount': userIds.length,
      });
      opCount++;

      // STEP 3: Save to each User's personal notifications WITH gymNotifId
      for (String uid in userIds) {
        if (opCount >= 490) {
          await batch.commit();
          batch = _firestore.batch();
          opCount = 0;
        }

        DocumentReference userNotifRef =
            _firestore.collection('users').doc(uid).collection('notifications').doc();
        batch.set(userNotifRef, {
          'gymId': gymId,
          'title': title,
          'message': message,
          'type': type.name,
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
          'readAt': null,
          'isDeleted': false,
          'deletedAt': null,
          'gymNotifId': gymNotifDocId,
        });
        opCount++;
      }

      await batch.commit();
    } catch (e) {
      debugPrint("Error sending notification: $e");
      rethrow;
    }
  }


  Stream<QuerySnapshot> getAdminNotifications(String gymId) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
  }

  /// Cascade Soft-Delete: Admin deletes → synced to all members
  Future<void> deleteAdminNotification(String gymId, String notifId) async {
    try {
      debugPrint("🗑️ Starting cascade soft-delete for notifId: $notifId");

      // STEP 1: Soft-delete the gym notification
      await _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('notifications')
          .doc(notifId)
          .update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
      });
      debugPrint("Gym notification soft-deleted: $notifId");

      // STEP 2: Get all member UIDs for this gym
      QuerySnapshot membersSnap = await _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('members')
          .get();

      List<String> memberUids = membersSnap.docs.map((doc) => doc.id).toList();
      debugPrint("👥 Found ${memberUids.length} members to cascade delete");

      // STEP 3: For each member, find and soft-delete matching notifications
      WriteBatch batch = _firestore.batch();
      int opCount = 0;
      int totalDeleted = 0;

      for (String uid in memberUids) {
        // FIX: Single where clause only — no composite index needed
        QuerySnapshot userNotifs = await _firestore
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .where('gymNotifId', isEqualTo: notifId)
            .get();

        for (var doc in userNotifs.docs) {
          var data = doc.data() as Map<String, dynamic>;
          if (data['isDeleted'] == true) continue;

          if (opCount >= 490) {
            await batch.commit();
            batch = _firestore.batch();
            opCount = 0;
          }

          batch.update(doc.reference, {
            'isDeleted': true,
            'deletedAt': FieldValue.serverTimestamp(),
          });
          opCount++;
          totalDeleted++;
        }
      }

      if (opCount > 0) {
        await batch.commit();
      }

      debugPrint("Cascade complete. Member notifications deleted: $totalDeleted");
    } catch (e) {
      debugPrint("Error in cascade soft-delete: $e");
      rethrow;
    }
  }

  // ==========================================
  // MEMBER: READ & MARK OPERATIONS
  // ==========================================

  // FIX: Only orderBy — NO where clause = NO composite index needed
  // Filter isDeleted CLIENT-SIDE
  Stream<QuerySnapshot> getMemberNotifications(String userId,
      {DocumentSnapshot? lastDocument, int limit = 20}) {
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    return query.snapshots();
  }

  // FIX: Single where clause only — NO composite index needed
  // Client-side filter for isDeleted is applied in the Bell widget
  Stream<QuerySnapshot> getUnreadCount(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots();
  }

  /// Mark as Read
  Future<void> markAsRead(String userId, String notifId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notifId)
        .update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark all as Read
  Future<void> markAllAsRead(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    WriteBatch batch = _firestore.batch();
    int count = 0;

    for (var doc in snapshot.docs) {
      // Client-side filter: skip deleted notifications
      var data = doc.data() as Map<String, dynamic>;
      if (data['isDeleted'] == true) continue;

      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
      count++;

      if (count >= 490) {
        await batch.commit();
        batch = _firestore.batch();
        count = 0;
      }
    }

    if (count > 0) {
      await batch.commit();
    }
  }

  /// Member personal delete (soft-delete)
  Future<void> deletePersonalNotification(String userId, String notifId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notifId)
        .update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================
  // MIGRATION UTILITY
  // Run ONCE to add isDeleted: false to old notification documents
  // ==========================================
  Future<void> migrateOldNotifications(String gymId) async {
    try {
      debugPrint("Starting notification migration for gym: $gymId");

      // Migrate gym notifications
      QuerySnapshot gymNotifs = await _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('notifications')
          .get();

      WriteBatch batch = _firestore.batch();
      int count = 0;

      for (var doc in gymNotifs.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (!data.containsKey('isDeleted')) {
          batch.update(doc.reference, {
            'isDeleted': false,
            'deletedAt': null,
            'gymNotifId': doc.id,
          });
          count++;
        }
        if (count >= 490) {
          await batch.commit();
          batch = _firestore.batch();
          count = 0;
        }
      }
      if (count > 0) await batch.commit();
      debugPrint("Migrated gym notifications");

      // Migrate member notifications
      QuerySnapshot membersSnap = await _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('members')
          .get();

      for (var memberDoc in membersSnap.docs) {
        String uid = memberDoc.id;
        QuerySnapshot userNotifs = await _firestore
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .get();

        batch = _firestore.batch();
        count = 0;

        for (var doc in userNotifs.docs) {
          var data = doc.data() as Map<String, dynamic>;
          if (!data.containsKey('isDeleted')) {
            batch.update(doc.reference, {
              'isDeleted': false,
              'deletedAt': null,
              'gymNotifId': data['gymNotifId'] ?? '',
            });
            count++;
          }
          if (count >= 490) {
            await batch.commit();
            batch = _firestore.batch();
            count = 0;
          }
        }
        if (count > 0) await batch.commit();
      }

      debugPrint("Notification migration complete for gym: $gymId");
    } catch (e) {
      debugPrint("Migration error: $e");
      rethrow;
    }
  }
}