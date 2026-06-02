import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/services/database_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/chat_page/chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminMessageScreen extends StatefulWidget {
  const AdminMessageScreen({super.key});

  @override
  State<AdminMessageScreen> createState() => _AdminMessageScreenState();
}

class _AdminMessageScreenState extends State<AdminMessageScreen> {
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
    if (_gymId == "loading") {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Members Chat",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
              return const Center(
                child: Text(
                  "No members found",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            var users = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: users.length,
              itemBuilder: (context, index) {
                var userData = users[index].data() as Map<String, dynamic>;
                String uid = userData['uid'] ?? '';

                if (uid == currentUserId) return const SizedBox.shrink();

                String chatRoomId = _dbService.getChatRoomId(
                  currentUserId,
                  uid,
                );

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: _buildProfileAvatar(
  imageUrl: userData['profileImageUrl'] ?? '',
  base64Image: userData['profileImageBase64'] ?? '',
),
                    title: Text(
                      userData['name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      userData['role']?.toString().toUpperCase() ?? 'MEMBER',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    trailing: _buildUnreadBadge(
                      _gymId,
                      chatRoomId,
                      currentUserId,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ChatDetailScreen(
                                gymId: _gymId,
                                receiverUid: uid,
                                receiverName: userData['name'] ?? 'Unknown',
                                receiverImageBase64:
                                    userData['profileImageBase64'] ?? '',
                                    receiverImageUrl: userData['profileImageUrl'] ?? '',

                              ),
                        ),
                      );
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
  Widget _buildUnreadBadge(
    String gymId,
    String chatRoomId,
    String currentUserId,
  ) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _dbService.getChatRoomData(gymId, chatRoomId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Icon(
            Icons.chat_bubble_outline,
            color: AppColors.blueColor,
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        int unreadCount = data['unreadCount_$currentUserId'] ?? 0;

        if (unreadCount == 0) {
          return const Icon(
            Icons.chat_bubble_outline,
            color: AppColors.blueColor,
          );
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  // Base64 Profile Avatar
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
