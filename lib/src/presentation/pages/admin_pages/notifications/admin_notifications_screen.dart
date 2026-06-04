import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/services/notification_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/utils/app_responsive.dart';
import 'package:gym_lead_master/src/data/models/notification_model.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/notifications/create_notification_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/common/notifications/notification_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final NotificationService _notifService = NotificationService();
  String _gymId = "loading";
  String? _errorMessage;
  String? _deletingNotifId;

  @override
  void initState() {
    super.initState();
    _loadGymId();
  }

  Future<void> _loadGymId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedGymId = prefs.getString('gymId');

      if (savedGymId != null) {
        setState(() => _gymId = savedGymId);
      } else {
        String? uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          var doc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .get();
          if (doc.exists) {
            String dbGymId = doc.data()!['gymId'] ?? '';
            if (dbGymId.isNotEmpty) {
              await prefs.setString('gymId', dbGymId);
              setState(() => _gymId = dbGymId);
            } else {
              setState(() {
                _gymId = '';
                _errorMessage = "Gym ID not found. Please re-login.";
              });
            }
          } else {
            setState(() {
              _gymId = '';
              _errorMessage = "User profile not found.";
            });
          }
        }
      }
    } catch (e) {
      print("Error loading gymId: $e");
      setState(() {
        _gymId = '';
        _errorMessage = "Failed to load gym data.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sent Notifications",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.DarkBlueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white70, size: 20),
            tooltip: "Sync old notifications",
            onPressed:
                _gymId != "loading" && _gymId.isNotEmpty
                    ? () => _runMigration()
                    : null,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.blueColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateNotificationScreen(gymId: _gymId),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_gymId == "loading") {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _gymId.isEmpty) {
      return _buildErrorState(_errorMessage!, Icons.error_outline, Colors.red);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _notifService.getAdminNotifications(_gymId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print("Notification stream error: ${snapshot.error}");
          return _buildErrorState(
            "Error loading notifications.\n${snapshot.error}",
            Icons.cloud_off,
            Colors.orange,
          );
        }

        if (!snapshot.hasData) {
          return _buildEmptyState();
        }

        // CLIENT-SIDE FILTER: Remove deleted notifications
        var activeDocs =
            snapshot.data!.docs.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return data['isDeleted'] != true;
            }).toList();

        if (activeDocs.isEmpty) {
          return _buildEmptyState();
        }

        var notifs =
            activeDocs
                .map((doc) => AppNotification.fromFirestore(doc))
                .toList();

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: notifs.length,
            itemBuilder: (context, index) {
              var notif = notifs[index];
              return _buildNotificationCard(notif);
            },
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(AppNotification notif) {
    bool isDeleting = _deletingNotifId == notif.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        // TAP TO READ FULL NOTIFICATION
        onTap:
            isDeleting
                ? null
                : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => NotificationDetailScreen(notification: notif),
                    ),
                  );
                },
        onLongPress: isDeleting ? null : () => _showDeleteDialog(notif),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(AppResponsive.padding(context, 12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: AppResponsive.iconSize(context, 20),
                        backgroundColor: notif.type.color.withOpacity(0.15),
                        child: Icon(
                          notif.type.icon,
                          color: notif.type.color,
                          size: AppResponsive.iconSize(context, 20),
                        ),
                      ),
                      SizedBox(width: AppResponsive.padding(context, 12)),
                      Expanded(
                        // EXPANDED so text doesn't push time off-screen
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif.title,
                              style: AppResponsive.textStyle(
                                context,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis, // Truncate if too long
                            ),
                            SizedBox(height: 4),
                            // Type & Count in a Wrap so they don't overlap
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: notif.type.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    notif.type.label,
                                    style: AppResponsive.textStyle(
                                      context,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: notif.type.color,
                                    ),
                                  ),
                                ),
                                Text(
                                  "To: ${notif.targetCount} members",
                                  style: AppResponsive.textStyle(
                                    context,
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppResponsive.padding(context, 8)),
                      // Time
                      Text(
                        notif.createdAt != null
                            ? timeago.format(notif.createdAt!)
                            : "Just now",
                        style: AppResponsive.textStyle(
                          context,
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppResponsive.padding(context, 8)),
                  Text(
                    notif.message,
                    style: AppResponsive.textStyle(
                      context,
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 2, // Only show 2 lines in list
                    overflow: TextOverflow.ellipsis, // Cut with "..."
                  ),
                ],
              ),
            ),
            if (isDeleting)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: AppResponsive.padding(context, 12)),
                        Text(
                          "Deleting for all members...",
                          style: AppResponsive.textStyle(
                            context,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(AppNotification notif) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  color: Colors.red[700],
                  size: AppResponsive.iconSize(context, 24),
                ),
                SizedBox(width: AppResponsive.padding(context, 10)),
                // Flexible: Agar title lamba ho toh wrap karega, overlap nahi karega
                Flexible(
                  child: Text(
                    "Delete Notification?",
                    style: AppResponsive.textStyle(
                      context,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "This notification will be removed from:",
                  style: AppResponsive.textStyle(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppResponsive.padding(context, 12)),

                // Row 1: Admin Dashboard
                _buildDialogInfoRow(
                  Icons.admin_panel_settings,
                  AppColors.DarkBlueGrey,
                  "Your admin dashboard",
                ),
                SizedBox(height: AppResponsive.padding(context, 8)),

                // Row 2: Member Devices
                _buildDialogInfoRow(
                  Icons.people,
                  AppColors.blueColor,
                  "All ${notif.targetCount} member devices",
                ),

                SizedBox(height: AppResponsive.padding(context, 16)),

                // Warning Info Box
                Container(
                  padding: EdgeInsets.all(AppResponsive.padding(context, 10)),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: AppResponsive.iconSize(context, 16),
                        color: Colors.orange[700],
                      ),
                      SizedBox(width: AppResponsive.padding(context, 8)),
                      // ✅ Expanded: Text chhoti screen par auto next line par jayega
                      Expanded(
                        child: Text(
                          "This action can be undone from the database if needed.",
                          style: AppResponsive.textStyle(
                            context,
                            fontSize: 12,
                            color: Colors.orange[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // ✅ FittedBox: Buttons chhoti screen par overlap nahi karenge
              FittedBox(
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        "Cancel",
                        style: AppResponsive.textStyle(
                          context,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(width: AppResponsive.padding(context, 8)),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _performDelete(notif);
                      },
                      icon: Icon(
                        Icons.delete,
                        size: AppResponsive.iconSize(context, 18),
                      ),
                      label: Text(
                        "Delete for Everyone",
                        style: AppResponsive.textStyle(
                          context,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  // Helper Method: Dialog ke andar ki rows ke liye (Clean code)
  Widget _buildDialogInfoRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: AppResponsive.iconSize(context, 16), color: color),
        SizedBox(width: AppResponsive.padding(context, 8)),
        // Flexible: Text agar lamba ho toh cut jayega "..." se, overlap nahi karega
        Flexible(
          child: Text(
            text,
            style: AppResponsive.textStyle(
              context,
              fontSize: 13,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _performDelete(AppNotification notif) async {
    setState(() => _deletingNotifId = notif.id);

    try {
      await _notifService.deleteAdminNotification(_gymId, notif.id);

      if (mounted) {
        setState(() => _deletingNotifId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Notification deleted for you and ${notif.targetCount} members ",
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print("Delete failed: $e");
      if (mounted) {
        setState(() => _deletingNotifId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _runMigration() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Sync Old Notifications?"),
            content: const Text(
              "This will add required fields to old notifications "
              "so they appear correctly. Run this only once.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Run Sync"),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Syncing notifications..."),
              ],
            ),
          ),
    );

    try {
      await _notifService.migrateOldNotifications(_gymId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sync complete! "),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sync failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              "No Sent Notifications Yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Tap the + button to send your first notification to gym members.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, IconData icon, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: color.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _gymId = "loading";
                  _errorMessage = null;
                });
                _loadGymId();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
