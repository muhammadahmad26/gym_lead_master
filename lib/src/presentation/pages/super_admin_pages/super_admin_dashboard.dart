import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';

import 'data/services/super_admin_service.dart';
import 'super_admin_home_page.dart';
import 'super_admin_message_page.dart';
import 'super_admin_payment_page.dart';
import 'super_admin_profile_page.dart';
import 'super_admin_add_admin_page.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  final SuperAdminService _superAdminService = SuperAdminService();
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SuperAdminHomePage(),
    const SuperAdminPaymentPage(),
    const SuperAdminMessagePage(),
    const SuperAdminProfilePage(),
  ];

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

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _navigateToAddAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SuperAdminAddAdminPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          height: 70,
          decoration: const BoxDecoration(
            color: AppColors.DarkBlueGrey,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, "Home", 0),
              _buildNavItem(Icons.payment, "Payments", 1),
              _buildNavItem(Icons.message, "Messages", 2),
              _buildNavItem(Icons.person, "Profile", 3),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAddAdmin,
          backgroundColor: AppColors.BrightBlue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.BrightBlue : AppColors.grayColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.BrightBlue : AppColors.grayColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
