import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/services/database_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/chat_page/chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberMessageScreen extends StatefulWidget {
  const MemberMessageScreen({super.key});

  @override
  State<MemberMessageScreen> createState() => _MemberMessageScreenState();
}

class _MemberMessageScreenState extends State<MemberMessageScreen> {
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
        var doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
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
    if (_gymId == "loading") {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gym Chat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.DarkBlueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppBackGroundPage(
        child: StreamBuilder<QuerySnapshot>(
          stream: _dbService.getGymUsers(_gymId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No users found", style: TextStyle(color: Colors.white)));
            }

            var users = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: users.length,
              itemBuilder: (context, index) {
                var userData = users[index].data() as Map<String, dynamic>;
                String uid = userData['uid'] ?? '';

                if (uid == currentUserId) return const SizedBox.shrink();

                String role = userData['role'] ?? 'member';
                String chatRoomId = _dbService.getChatRoomId(currentUserId, uid);

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: _buildProfileAvatar(userData['profileImageBase64'] ?? ''),
                    title: Text(userData['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      role == 'admin' ? 'ADMIN' : 'Member',
                      style: TextStyle(
                        color: role == 'admin' ? Colors.blue : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: role == 'admin' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: _buildUnreadBadge(_gymId, chatRoomId, currentUserId),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          gymId: _gymId,
                          receiverUid: uid,
                          receiverName: userData['name'] ?? 'Unknown',
                          receiverImageBase64: userData['profileImageBase64'] ?? '',
                          receiverImageUrl: userData['profileImageUrl'] ?? '', 
                        ),
                      ));
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Unread Count Badge Stream
  Widget _buildUnreadBadge(String gymId, String chatRoomId, String currentUserId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _dbService.getChatRoomData(gymId, chatRoomId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Icon(Icons.chat_bubble_outline, color: AppColors.blueColor);
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        int unreadCount = data['unreadCount_$currentUserId'] ?? 0;

        if (unreadCount == 0) {
          return const Icon(Icons.chat_bubble_outline, color: AppColors.blueColor);
        }

        return Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
          constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
          child: Text(
            unreadCount > 99 ? '99+' : '$unreadCount',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  // Base64 Profile Avatar
  Widget _buildProfileAvatar(String base64Image, {double radius = 25}) {
    if (base64Image.isNotEmpty) {
      try {
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[300],
          backgroundImage: MemoryImage(base64Decode(base64Image)),
        );
      } catch (e) {
        return CircleAvatar(radius: radius, backgroundColor: Colors.grey[300], child: Icon(Icons.person, size: radius));
      }
    }
    return CircleAvatar(radius: radius, backgroundColor: Colors.grey[300], child: Icon(Icons.person, size: radius));
  }
}