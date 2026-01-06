import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/constants/app_padding.dart';
import 'package:gym_lead_master/src/core/constants/app_text_size.dart';

import '../admin_pages/profile_page/data/model/list_items_model.dart';
import '../admin_pages/profile_page/widgets/custom_list_tile.dart';
import 'data/services/super_admin_service.dart';

class SuperAdminProfilePage extends StatefulWidget {
  const SuperAdminProfilePage({super.key});

  @override
  State<SuperAdminProfilePage> createState() => _SuperAdminProfilePageState();
}

class _SuperAdminProfilePageState extends State<SuperAdminProfilePage> {
  final SuperAdminService _superAdminService = SuperAdminService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic> _profileData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final superAdmin = _auth.currentUser;
      if (superAdmin == null) return;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(superAdmin.uid)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _profileData = docSnapshot.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    }
  }

  void _handleLogout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _superAdminService.logout();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(AppPaddings.large),
            decoration: const BoxDecoration(
              color: AppColors.DarkBlueGrey,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Image.asset(AppImages.userIcon, fit: BoxFit.contain),
                ),
                const SizedBox(width: AppPaddings.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _isLoading
                          ? const SizedBox(
                              width: 150,
                              height: 24,
                              child: LinearProgressIndicator(),
                            )
                          : Text(
                              _profileData['name'] ?? 'Super Admin',
                              style: AppTextStyles.headlineLarge.copyWith(
                                color: Colors.white,
                              ),
                            ),
                      const SizedBox(height:4),
                      _isLoading
                          ? const SizedBox(
                              width: 200,
                              height: 16,
                              child: LinearProgressIndicator(),
                            )
                          : Text(
                              _profileData['email'] ?? '',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                      const SizedBox(height:4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.BrightBlue.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Super Admin',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.darkBlue,
                    AppColors.mediumBlue,
                    AppColors.lightBlue,
                    Color.fromARGB(255, 150, 179, 218),
                    Color.fromARGB(255, 198, 218, 245),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppPaddings.large),

                    // Stats Card
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppPaddings.medium,
                      ),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppPaddings.medium),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('Active Admins', '12'),
                              _buildStatItem('Gyms Managed', '8'),
                              _buildStatItem('Total Members', '450'),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppPaddings.medium),

                    // Profile Information
                    _buildSection('Profile Information'),
                    _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(AppPaddings.medium),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Column(
                            children: [
                              CustomListTile(
                                item: ListItem(
                                  icon: Icons.person,
                                  title: _profileData['name'] ?? 'N/A',
                                ),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Edit name feature coming soon'),
                                    ),
                                  );
                                },
                              ),
                              CustomListTile(
                                item: ListItem(
                                  icon: Icons.email,
                                  title: _profileData['email'] ?? 'N/A',
                                ),
                                onTap: () {},
                              ),
                              CustomListTile(
                                item: ListItem(
                                  icon: Icons.calendar_today,
                                  title: _profileData['createdAt'] != null
                                      ? _formatDate(
                                          (_profileData['createdAt'] as Timestamp).toDate(),
                                        )
                                      : 'N/A',
                                ),
                                onTap: () {},
                              ),
                              CustomListTile(
                                item: ListItem(
                                  icon: Icons.admin_panel_settings,
                                  title: 'Role: Super Admin',
                                ),
                                onTap: () {},
                              ),
                            ],
                          ),

                    const SizedBox(height: AppPaddings.medium),

                    // Settings
                    _buildSection('Settings'),
                    Column(
                      children: settingsItems.map((item) {
                        return CustomListTile(
                          item: item,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Navigating to ${item.title}...'),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppPaddings.medium),

                    // Support
                    _buildSection('Support'),
                    Column(
                      children: supportItems.map((item) {
                        return CustomListTile(
                          item: item,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Navigating to ${item.title}...'),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppPaddings.extraLarge),

                    // Logout Button
                    _buildLogoutButton(context),

                    const SizedBox(height: AppPaddings.large),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.BrightBlue,
          ),
        ),
        const SizedBox(height:4),
        Text(
          label,
          style: AppTextStyles.labelLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPaddings.medium,
        vertical: AppPaddings.small,
      ),
      child: Text(
        title,
        style: AppTextStyles.headlineMedium.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPaddings.medium),
        child: ElevatedButton.icon(
          onPressed: () => _handleLogout(context),
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  final List<ListItem> settingsItems = [
    ListItem(icon: Icons.edit, title: 'Edit Profile'),
    ListItem(icon: Icons.lock, title: 'Change Password'),
    ListItem(icon: Icons.notifications, title: 'Notification Settings'),
    ListItem(icon: Icons.dark_mode, title: 'Theme Mode'),
    ListItem(icon: Icons.language, title: 'Language'),
  ];

  final List<ListItem> supportItems = [
    ListItem(icon: Icons.help_center, title: 'Help & FAQ'),
    ListItem(icon: Icons.contact_support, title: 'Contact Support'),
    ListItem(icon: Icons.privacy_tip, title: 'Privacy Policy'),
    ListItem(icon: Icons.description, title: 'Terms & Conditions'),
  ];
}
