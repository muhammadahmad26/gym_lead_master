import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/services/notification_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/data/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';
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
      debugPrint("Error loading gymId: $e");
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
        iconTheme: const IconThemeData(
          color: Colors.white, // Back arrow color
        ),
        title: const Text(
          "Send Notifications",
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
          Navigator.pushNamed(
            context,

            AppRoutes.createNotificationPage,
            arguments: {'gymId': _gymId},
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
          debugPrint("Notification stream error: ${snapshot.error}");
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
        onLongPress: isDeleting ? null : () => _showDeleteDialog(notif),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: notif.type.color.withOpacity(0.15),
                        child: Icon(
                          notif.type.icon,
                          color: notif.type.color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
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
                                    style: TextStyle(
                                      color: notif.type.color,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    "To: ${notif.targetCount} members",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        notif.createdAt != null
                            ? timeago.format(notif.createdAt!)
                            : "Just now",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notif.message,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Deleting for all members...",
                          style: TextStyle(
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
                Icon(Icons.delete_outline, color: Colors.red[700], size: 28),
                const SizedBox(width: 10),
                const Expanded(child: Text("Delete Notification?")),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "This notification will be removed from:",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 16,
                      color: AppColors.DarkBlueGrey,
                    ),
                    const SizedBox(width: 6),
                    const Expanded(child: Text("Your admin dashboard")),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.people,
                      size: 16,
                      color: AppColors.blueColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text("All ${notif.targetCount} member devices"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "This action can be undone from the database if needed.",
                          style: TextStyle(
                            fontSize: 11,
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
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _performDelete(notif);
                },
                icon: const Icon(Icons.delete, size: 18),
                label: const Text("Delete for Everyone"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
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
              "Notification deleted for you and ${notif.targetCount} members ✅",
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint("Delete failed: $e");
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
            content: Text("Sync complete! ✅"),
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
