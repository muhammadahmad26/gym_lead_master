import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/data/models/attendance_model.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/attendance/member_attendance_tab.dart';
import 'package:intl/intl.dart';

class MemberDetailScreen extends StatelessWidget {
  final String gymId;
  final Map<String, dynamic> memberData;

  const MemberDetailScreen({
    super.key,
    required this.gymId,
    required this.memberData,
  });

  @override
  Widget build(BuildContext context) {
    String name = memberData['name'] ?? 'Unknown';
    String email = memberData['email'] ?? '';
    String role = memberData['role'] ?? 'member';
    String location = memberData['location'] ?? '';
    String mStatus = memberData['membershipStatus'] ?? 'not_paid';
    String? profileBase64 = memberData['profileImageBase64'];
    String uid = memberData['uid'] ?? '';

    String joinDateStr = "N/A";
    if (memberData['joinDate'] != null) {
      DateTime dt = (memberData['joinDate'] as Timestamp).toDate();
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
            MemberAttendanceTab(gymId: gymId, memberId: uid, memberName: name),
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
                _buildProfileAvatar(profileBase64),
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
  Widget _buildProfileAvatar(String? base64Image, {double radius = 30}) {
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
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: Icon(Icons.person, size: radius, color: Colors.grey[600]),
    );
  }
}
