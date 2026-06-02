import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/services/database_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/attendance/attendance_dashboard_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/attendance/member_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GymMembersPage extends StatefulWidget {
  const GymMembersPage({super.key});

  @override
  State<GymMembersPage> createState() => _GymMembersPageState();
}

class _GymMembersPageState extends State<GymMembersPage> {
  final DatabaseService _dbService = DatabaseService();
  String _gymId = "loading";

  @override
  void initState() {
    super.initState();
    _loadGymId();
  }

  Future<void> _loadGymId() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedGymId = prefs.getString('gymId');

    if (savedGymId != null) {
      setState(() => _gymId = savedGymId);
    } else {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        var doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists) {
          String dbGymId = doc.data()!['gymId'];
          await prefs.setString('gymId', dbGymId);
          setState(() => _gymId = dbGymId);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gym Members",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.DarkBlueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppBackGroundPage(
        child:
            _gymId == "loading"
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                  stream: _dbService.getMembersStream(_gymId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snapshot.error}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 60,
                              color: Colors.white70,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No members registered yet.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    var members = snapshot.data!.docs;
                    int totalMembers = members.length; // Calculate total count

                    return Column(
                      children: [
                        // Total Members Header
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.blueColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.groups,
                                color: Colors.white,
                                size: 30,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Total Members: $totalMembers",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        //Action Buttons Row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => AttendanceDashboardScreen(
                                              gymId: _gymId,
                                            ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.event_available,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    "Attendance",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.DarkBlueGrey,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Existing member list is already shown
                                  },
                                  icon: const Icon(
                                    Icons.people_outline,
                                    color: AppColors.blueColor,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    "All Members",
                                    style: TextStyle(
                                      color: AppColors.blueColor,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: AppColors.blueColor.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Members List
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              var data =
                                  members[index].data() as Map<String, dynamic>;

                              String name = data['name'] ?? 'Unknown';
                              String role = data['role'] ?? 'member';
                              String location = data['location'] ?? '';
                              String mStatus =
                                  data['membershipStatus'] ?? 'not_paid';
                              String? profileBase64 =
                                  data['profileImageBase64'];

                              String joinDateStr = "N/A";
                              if (data['joinDate'] != null) {
                                DateTime dt =
                                    (data['joinDate'] as Timestamp).toDate();
                                joinDateStr = DateFormat(
                                  'dd MMM yyyy',
                                ).format(dt);
                              }

                              Color roleColor =
                                  role == 'trainer'
                                      ? Colors.orange
                                      : AppColors.BrightBlue;
                              Color statusColor = Colors.grey;
                              String statusLabel = "NOT PAID";

                              if (mStatus == 'active') {
                                statusColor = Colors.green;
                                statusLabel = "ACTIVE";
                              } else if (mStatus == 'pending') {
                                statusColor = Colors.orange;
                                statusLabel = "PENDING";
                              }

                              // Wrap card with GestureDetector for tap
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => MemberDetailScreen(
                                            gymId: _gymId,
                                            memberData: data,
                                          ),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildProfileAvatar(
  imageUrl: data['profileImageUrl'] ?? '', 
  base64Image: data['profileImageBase64'] ?? '',
),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.DarkBlueGrey,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 4,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: roleColor
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      role.toUpperCase(),
                                                      style: TextStyle(
                                                        color: roleColor,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: statusColor
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      statusLabel,
                                                      style: TextStyle(
                                                        color: statusColor,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.location_on_outlined,
                                                    size: 16,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      location.isEmpty
                                                          ? "Not provided"
                                                          : location,
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 13,
                                                        fontStyle:
                                                            location.isEmpty
                                                                ? FontStyle
                                                                    .italic
                                                                : FontStyle
                                                                    .normal,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .calendar_today_outlined,
                                                    size: 14,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "Joined: $joinDateStr",
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Tap indicator
                                        const Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
      ),
    );
  }

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
