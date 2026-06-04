import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/utils/app_responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActiveMemberListPage extends StatefulWidget {
  const ActiveMemberListPage({super.key});

  @override
  State<ActiveMemberListPage> createState() => _ActiveMemberListPageState();
}

class _ActiveMemberListPageState extends State<ActiveMemberListPage> {
  String _gymId = "loading";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGymId();
  }

  Future<void> _loadGymId() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedGymId = prefs.getString('gymId');

    if (savedGymId != null) {
      setState(() {
        _gymId = savedGymId;
        _isLoading = false;
      });
    } else {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        var doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists) {
          String dbGymId = doc.data()!['gymId'];
          await prefs.setString('gymId', dbGymId);
          setState(() {
            _gymId = dbGymId;
            _isLoading = false;
          });
        }
      }
    }
  }

    @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
            body: AppBackGroundPage(
        child: AnnotatedRegion<SystemUiOverlayStyle>( 
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + AppResponsive.padding(context, 10), // Status bar height + 10
                ),
                // ... baaki code waisa hi ...
                child: Column(
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.2,
                      child: Image.asset(AppImages.appLogoIcon, fit: BoxFit.contain),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Pro Fitness Gym",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Active Members (Live)',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: StreamBuilder<QuerySnapshot>(
                    // ... baaki stream builder code waisa hi rahega ...
                  stream: _getActiveMembersStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No active members yet today",
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    var members = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        var memberData =
                            members[index].data() as Map<String, dynamic>;

                        // CALCULATE TIME AGO
                        Timestamp? checkInTime = memberData['checkInTime'];
                        String timeString = "Just now";
                        if (checkInTime != null) {
                          Duration diff = DateTime.now().difference(
                            checkInTime.toDate(),
                          );
                          int mins = diff.inMinutes;
                          if (mins < 1) {
                            timeString = "Just now";
                          } else if (mins < 60) {
                            timeString = "$mins min ago";
                          } else {
                            timeString = "${diff.inHours}h ago";
                          }
                        }

                        // GET EXERCISES
                        List<dynamic> exercises =
                            memberData['currentExercises'] ?? [];
                        String exerciseString = exercises.join(", ");
                        if (exerciseString.isEmpty)
                          exerciseString = "General Workout";

                        return Card(
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            //Show profile picture from Base64
                            leading: _buildProfileAvatar(
  imageUrl: memberData['profileImageUrl'] ?? '',
  base64Image: memberData['profileImageBase64'] ?? '',
  radius: 22,
),
                            title: Text(
                              memberData['name'] ?? "Unknown",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(exerciseString),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 17.0,
                                  color: Color.fromARGB(255, 29, 29, 29),
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  timeString,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 68, 67, 67),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
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
  Stream<QuerySnapshot> _getActiveMembersStream() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    return FirebaseFirestore.instance
        .collection('gyms')
        .doc(_gymId)
        .collection('members')
        .where(
          'checkInTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .orderBy('checkInTime', descending: true)
        .snapshots();
  }
}
