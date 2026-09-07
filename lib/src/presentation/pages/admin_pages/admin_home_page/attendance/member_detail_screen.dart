import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/data/models/attendance_model.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/attendance/member_attendance_tab.dart';
import 'package:intl/intl.dart';

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/services/database_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/data/models/attendance_model.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/attendance/member_attendance_tab.dart';
import 'package:intl/intl.dart';

class MemberDetailScreen extends StatefulWidget {
  final String gymId;
  final Map<String, dynamic> memberData;

  const MemberDetailScreen({
    super.key,
    required this.gymId,
    required this.memberData,
  });

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  final DatabaseService _dbService = DatabaseService();
  bool _isDeleting = false;

  Future<void> _confirmAndDelete() async {
    String name = widget.memberData['name'] ?? 'this member';
    String uid = widget.memberData['uid'] ?? '';

    bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Delete Member?"),
            content: Text(
              "$name will be permanently removed from your gym, along with all their payment history, attendance records, and notifications. They will no longer be able to log in. This cannot be undone.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm != true || uid.isEmpty) return;

    setState(() => _isDeleting = true);
    try {
      await _dbService.deleteMemberCompletely(widget.gymId, uid);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$name has been removed."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Couldn't delete member: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.memberData['name'] ?? 'Unknown';
    String email = widget.memberData['email'] ?? '';
    String role = widget.memberData['role'] ?? 'member';
    String location = widget.memberData['location'] ?? '';
    String mStatus = widget.memberData['membershipStatus'] ?? 'not_paid';
    String? profileBase64 = widget.memberData['profileImageBase64'];
    String uid = widget.memberData['uid'] ?? '';

    String joinDateStr = "N/A";
    if (widget.memberData['joinDate'] != null) {
      DateTime dt = (widget.memberData['joinDate'] as Timestamp).toDate();
      joinDateStr = DateFormat('dd MMM yyyy').format(dt);
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.LightGrey,
        appBar: AppBar(
          title: Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.DarkBlueGrey,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            if (_isDeleting)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: "Delete Member",
                onPressed: _confirmAndDelete,
              ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [Tab(text: "Profile"), Tab(text: "Attendance")],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProfileTab(
              name,
              email,
              role,
              location,
              mStatus,
              profileBase64,
              joinDateStr,
            ),
            MemberAttendanceTab(gymId: widget.gymId, memberId: uid, memberName: name),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(
    String name,
    String email,
    String role,
    String location,
    String mStatus,
    String? profileBase64,
    String joinDateStr,
  ) {
    Color statusColor = Colors.grey;
    String statusLabel = "NOT PAID";
    if (mStatus == 'active') {
      statusColor = Colors.green;
      statusLabel = "ACTIVE";
    } else if (mStatus == 'pending') {
      statusColor = Colors.orange;
      statusLabel = "PENDING";
    }

    Color roleColor = role == 'trainer' ? Colors.orange : AppColors.BrightBlue;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.DarkBlueGrey, AppColors.BrightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildProfileAvatar(
  imageUrl:widget.memberData['profileImageUrl'] ?? '',
  base64Image: widget.memberData['profileImageBase64'] ?? '',
),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Details
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow(
                    Icons.location_on,
                    'Location',
                    location.isEmpty ? 'Not provided' : location,
                  ),
                  const Divider(),
                  _buildDetailRow(Icons.calendar_today, 'Joined', joinDateStr),
                  const Divider(),
                  _buildDetailRow(Icons.badge, 'Role', role.toUpperCase()),
                  const Divider(),
                  _buildDetailRow(Icons.verified, 'Status', statusLabel),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.blueColor),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  ///--------------------------
  Widget _buildProfileAvatar({String? imageUrl, String? base64Image, double radius = 25}) {
  // Priority 1: Cloudinary URL (New fast way)
  if (imageUrl != null && imageUrl.isNotEmpty) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      backgroundImage: NetworkImage(imageUrl),
      onBackgroundImageError: (_, __) {}, // Prevent red screen if URL fails
    );
  }
  
  // Priority 2: Old Base64 (Fallback for old users)
  if (base64Image != null && base64Image.isNotEmpty) {
    try {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
        backgroundImage: MemoryImage(base64Decode(base64Image)),
      );
    } catch (e) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.person, size: radius, color: Colors.grey[600]),
      );
    }
  }

  // Priority 3: Default Icon
  return CircleAvatar(
    radius: radius,
    backgroundColor: Colors.grey[300],
    child: Icon(Icons.person, size: radius, color: Colors.grey[600]),
  );
}
}
