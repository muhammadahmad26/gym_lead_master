
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/services/notification_service.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';

class NotificationBell extends StatelessWidget {
  final bool isAdmin;
  final String gymId;

  const NotificationBell(
      {super.key, required this.isAdmin, required this.gymId});

  @override
  Widget build(BuildContext context) {
    if (isAdmin) return const SizedBox.shrink();

    String userId = FirebaseAuth.instance.currentUser!.uid;
    NotificationService notifService = NotificationService();

    return StreamBuilder<QuerySnapshot>(
      stream: notifService.getUnreadCount(userId),
      builder: (context, snapshot) {
        int unreadCount = 0;

        if (snapshot.hasData) {
         
          unreadCount = snapshot.data!.docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return data['isDeleted'] != true;
          }).length;
        }

        if (snapshot.hasError) {
          debugPrint("NotificationBell error: ${snapshot.error}");
          return IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.memberNotificationsPage);
            },
            icon: const Icon(Icons.notifications_outlined,
                color: Colors.white),
          );
        }

        return IconButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.memberNotificationsPage);
          },
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined,
                  color: Colors.white),
              if (unreadCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}