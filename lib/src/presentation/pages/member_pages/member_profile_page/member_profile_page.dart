import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/constants/app_padding.dart';
import 'package:gym_lead_master/src/core/constants/app_text_size.dart';
import 'package:gym_lead_master/src/core/widgets/custom_textForm_field.dart';
import 'package:gym_lead_master/src/core/widgets/app_button.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/data/model/list_items_model.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/widgets/custom_list_tile.dart';
import 'package:gym_lead_master/src/presentation/pages/splash_page/initial_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberProfilePage extends StatefulWidget {
  const MemberProfilePage({super.key});

  @override
  State<MemberProfilePage> createState() => _MemberProfilePageState();
}

class _MemberProfilePageState extends State<MemberProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _userName = "Loading...";
  String _userEmail = "Loading...";
  String _userRole = "Member";
  String _gymId = "gym_001";

  StreamSubscription<DocumentSnapshot>? _userSub;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _userSub?.cancel();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _gymId = prefs.getString('gymId') ?? "gym_001");

    _userSub = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            var data = snapshot.data() as Map<String, dynamic>;
            if (!mounted) return;
            setState(() {
              _userName = data['name'] ?? "User";
              _userEmail = data['email'] ?? "No Email";
              _userRole = data['role'] ?? "Member";
              _nameController.text = _userName;
              _emailController.text = _userEmail;
            });
          }
        });
  }

  Future<void> _updateProfile() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'name': _nameController.text});

    await FirebaseFirestore.instance
        .collection('gyms')
        .doc(_gymId)
        .collection('members')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'name': _nameController.text});

    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile Updated")));
  }

  Future<void> _changePassword() async {
    if (_passwordController.text.isEmpty) return;
    try {
      await FirebaseAuth.instance.currentUser!.updatePassword(
        _passwordController.text,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password Changed")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Edit Profile"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFormField(controller: _nameController, label: "Name"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Change Password"),
            content: CustomTextFormField(
              controller: _passwordController,
              label: "New Password",
              obsecuretext: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _changePassword,
                child: const Text("Update"),
              ),
            ],
          ),
    );
  }

  // NEW: Logout with Confirmation Dialog
  Future<void> _logout() async {
    bool? confirmLogout = await _showLogoutConfirmationDialog();

    if (confirmLogout != true) return;

    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const InitialPages()),
        (route) => false,
      );
    }
  }

  // NEW: Logout Confirmation Dialog
  Future<bool?> _showLogoutConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.logout, color: Colors.redAccent, size: 28),
              SizedBox(width: 10),
              Text('Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.DarkBlueGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackGroundPage(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(AppImages.userIcon),
              ),
              const SizedBox(height: 15),
              Text(
                _userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                _userEmail,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blueColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _userRole.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),

              const SizedBox(height: 30),

              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    CustomListTile(
                      item: ListItem(icon: Icons.edit, title: 'Edit Profile'),
                      onTap: _showEditDialog,
                    ),
                    CustomListTile(
                      item: ListItem(
                        icon: Icons.lock,
                        title: 'Change Password',
                      ),
                      onTap: _showPasswordDialog,
                    ),
                    // UPDATED: Logout now shows confirmation dialog
                    CustomListTile(
                      item: ListItem(icon: Icons.logout, title: 'Logout'),
                      onTap: _logout, // Changed from inline code to method
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
