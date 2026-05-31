
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/services/notification_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/data/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class MemberNotificationsScreen extends StatefulWidget {
  const MemberNotificationsScreen({super.key});

  @override
  State<MemberNotificationsScreen> createState() =>
      _MemberNotificationsScreenState();
}

class _MemberNotificationsScreenState extends State<MemberNotificationsScreen> {
  final NotificationService _notifService = NotificationService();
  String _searchQuery = "";
  NotificationType? _filterType;
  String? _deletingNotifId;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('en', timeago.EnMessages());
  }

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Notifications", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.DarkBlueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await _notifService.markAllAsRead(userId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("All marked as read"),
                        backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Error: $e"),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text("Mark all read",
                style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _notifService.getMemberNotifications(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print("Member notification error: ${snapshot.error}");
                  return _buildErrorState(
                      "Error loading notifications.\n${snapshot.error}");
                }

                if (!snapshot.hasData) {
                  return _buildEmptyState();
                }

                // CLIENT-SIDE FILTER: Remove deleted notifications
                var activeDocs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return data['isDeleted'] != true;
                }).toList();

                if (activeDocs.isEmpty) {
                  return _buildEmptyState();
                }

                var notifications = activeDocs
                    .map((doc) => AppNotification.fromFirestore(doc))
                    .toList();

                // Apply search + type filters
                if (_filterType != null) {
                  notifications = notifications
                      .where((n) => n.type == _filterType)
                      .toList();
                }
                if (_searchQuery.isNotEmpty) {
                  notifications = notifications
                      .where((n) =>
                          n.title.toLowerCase().contains(
                              _searchQuery.toLowerCase()) ||
                          n.message.toLowerCase().contains(
                              _searchQuery.toLowerCase()))
                      .toList();
                }

                if (notifications.isEmpty) return _buildEmptyState();

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      var notif = notifications[index];
                      return _buildNotificationCard(notif, userId);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Search notifications...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(null, "All"),
                ...NotificationType.values
                    .map((type) => _buildFilterChip(type, type.label)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(NotificationType? type, String label) {
    bool isSelected = _filterType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) =>
            setState(() => _filterType = selected ? type : null),
        selectedColor: AppColors.blueColor.withOpacity(0.2),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notif, String userId) {
    bool isDeleting = _deletingNotifId == notif.id;

    if (isDeleting) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                "Deleting notification...",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text("Delete Notification?"),
            content:
                const Text("This notification will be removed from your list."),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Cancel")),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Delete",
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => _deleteNotification(userId, notif.id),
      child: Card(
        elevation: notif.isRead ? 1 : 3,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: notif.isRead
            ? Colors.white
            : AppColors.veryLightBlue.withOpacity(0.5),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: notif.type.color.withOpacity(0.1),
            child: Icon(notif.type.icon, color: notif.type.color),
          ),
          title: Text(notif.title,
              style: TextStyle(
                  fontWeight:
                      notif.isRead ? FontWeight.normal : FontWeight.bold)),
          subtitle: Text(notif.message,
              maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                notif.createdAt != null
                    ? timeago.format(notif.createdAt!)
                    : "",
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              if (!notif.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.blueColor, shape: BoxShape.circle),
                ),
            ],
          ),
          onTap: () async {
            if (!notif.isRead) {
              try {
                await _notifService.markAsRead(userId, notif.id);
              } catch (e) {
                print("Error marking as read: $e");
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _deleteNotification(String userId, String notifId) async {
    setState(() => _deletingNotifId = notifId);

    try {
      await _notifService.deletePersonalNotification(userId, notifId);

      if (mounted) {
        setState(() => _deletingNotifId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Notification deleted"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _deletingNotifId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No notifications yet",
              style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.orange[300]),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}