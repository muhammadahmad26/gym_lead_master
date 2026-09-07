import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/widgets/gym_status_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/widgets/header_section.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/data/model/admin_profile_model.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/data/model/gym_status_model.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/data/model/list_items_model.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/widgets/custom_list_tile.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';
import 'package:gym_lead_master/services/auth_service.dart';
import 'package:gym_lead_master/services/database_service.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool _isDarkMode = false;
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();

  final _jazzController = TextEditingController();
  final _easyController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankAccountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadPaymentSettings();
  }

  @override
  void dispose() {
    _jazzController.dispose();
    _easyController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    super.dispose();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDarkMode = prefs.getBool('isDark') ?? false);
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDarkMode = !_isDarkMode);
    prefs.setBool('isDark', _isDarkMode);
  }

  void _loadPaymentSettings() async {
    // Fetch from DB and populate controllers
  }

  void _savePaymentSettings() {
    _dbService.updatePaymentSettings("gym_001", {
      'jazzCash': _jazzController.text,
      'easyPaisa': _easyController.text,
      'bankName': _bankNameController.text,
      'bankAccount': _bankAccountController.text,
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Settings Saved")));
  }

  // NEW: Logout with Confirmation Dialog
  Future<void> _logout() async {
    bool? confirmLogout = await _showLogoutConfirmationDialog();

    if (confirmLogout != true) return;

    await _authService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.loginChooserPage,
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(135),
        child: HeaderSection(
          admin: const Admin(
            name: 'Admin User',
            email: 'admin@gym.com',
            role: 'Super Admin',
            imageUrl: 'assets/images/user.png',
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          GymStatsCard(
            stats: const GymStats(
              totalMembers: 0,
              activeMembers: 0,
              trainers: 0,
              checkIns: 0,
            ),
          ),

          _buildSection('Settings'),
          CustomListTile(
            item: ListItem(icon: Icons.dark_mode, title: 'Theme Mode'),
            onTap: _toggleTheme,
          ),
          CustomListTile(
            item: ListItem(icon: Icons.language, title: 'Language'),
            onTap: () {},
          ),
          CustomListTile(
            item: ListItem(icon: Icons.payment, title: 'Payment Settings'),
            onTap: _showPaymentSettings,
          ),

          _buildSection('Support'),
          CustomListTile(
            item: ListItem(icon: Icons.help, title: 'Help'),
            onTap: () {},
          ),

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            // UPDATED: Logout button now calls _logout method with dialog
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _logout, 
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  void _showPaymentSettings() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Payment Details"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _jazzController,
                  decoration: const InputDecoration(
                    labelText: "JazzCash Number",
                  ),
                ),
                TextField(
                  controller: _easyController,
                  decoration: const InputDecoration(
                    labelText: "EasyPaisa Number",
                  ),
                ),
                TextField(
                  controller: _bankNameController,
                  decoration: const InputDecoration(labelText: "Bank Name"),
                ),
                TextField(
                  controller: _bankAccountController,
                  decoration: const InputDecoration(
                    labelText: "Account Number",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _savePaymentSettings,
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }
}
