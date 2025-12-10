import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/constants/app_padding.dart';
import 'package:gym_lead_master/src/core/constants/app_text_size.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/data/model/admin_profile_model.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/data/model/gym_status_model.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/data/model/list_items_model.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/widgets/custom_list_tile.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/widgets/gym_status_card.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/widgets/header_section.dart';

class AdminProfilePage extends StatelessWidget {
  final Admin admin = const Admin(
    name: 'muhammad Ali',
    email: 'mali@admin.com',
    role: 'Super Admin',
    imageUrl: AppImages.userIcon,
  );

  final GymStats gymStats = const GymStats(
    totalMembers: 100,
    activeMembers: 80,
    trainers: 25,
    checkIns: 55,
  );

  final List<ListItem> settingsItems = [
    ListItem(icon: Icons.person, title: 'Edit Profile'),
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

  AdminProfilePage({super.key});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logging out...')),
                  );
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: AppColors.blueColor),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderSection(admin: admin),
            const SizedBox(height: AppPaddings.large),
            GymStatsCard(stats: gymStats),
            const SizedBox(height: AppPaddings.large),
            _buildSection('Settings'),
            Column(
              children:
                  settingsItems.map((item) {
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
            _buildSection('Support'),
            Column(
              children:
                  supportItems.map((item) {
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
            _buildLogoutButton(context),
            const SizedBox(height: AppPaddings.large),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPaddings.medium,
        vertical: AppPaddings.small,
      ),
      child: Text(title, style: AppTextStyles.headlineMedium),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPaddings.medium),
        child: ElevatedButton.icon(
          onPressed: () => _handleLogout(context),
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text('Logout', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blueColor,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
