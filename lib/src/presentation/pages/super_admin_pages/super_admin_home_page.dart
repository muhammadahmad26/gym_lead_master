import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/constants/app_padding.dart';
import 'package:gym_lead_master/src/core/constants/app_text_size.dart';
import 'package:gym_lead_master/src/presentation/pages/super_admin_pages/data/model/admin_user_model.dart';

import '../admin_pages/profile_page/widgets/header_section.dart';

import 'data/services/super_admin_service.dart';

class SuperAdminHomePage extends StatefulWidget {
  const SuperAdminHomePage({super.key});

  @override
  State<SuperAdminHomePage> createState() => _SuperAdminHomePageState();
}

class _SuperAdminHomePageState extends State<SuperAdminHomePage> {
  final SuperAdminService _superAdminService = SuperAdminService();
  
  Map<String, int> _stats = {
    'totalAdmins': 0,
    'activeAdmins': 0,
    'pendingAdmins': 0,
    'totalMembers': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _superAdminService.getAdminStats();
    setState(() => _stats = stats);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.DarkBlueGrey,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              child: Image.asset(AppImages.userIcon, fit: BoxFit.contain),
            ),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "G",
                    style: TextStyle(
                      color: Color(0xFFFFEB3B),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: "Y",
                    style: TextStyle(
                      color: Color(0xFFFF9800),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: "M",
                    style: TextStyle(
                      color: Color(0xFF80FFB0),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: " Super Admin",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Container(
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
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Stats Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPaddings.medium),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Admins',
                          _stats['totalAdmins'].toString(),
                          Icons.admin_panel_settings,
                          AppColors.BrightBlue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          'Active Admins',
                          _stats['activeAdmins'].toString(),
                          Icons.check_circle,
                          AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Pending',
                          _stats['pendingAdmins'].toString(),
                          Icons.pending,
                          AppColors.warningOrange,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          'Total Members',
                          _stats['totalMembers'].toString(),
                          Icons.people,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Admins List Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPaddings.medium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Admins',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.BrightBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Real-time',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Admins Stream List
            Expanded(
              child: StreamBuilder<List<AdminUser>>(
                stream: _superAdminService.getAllAdmins(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final admins = snapshot.data ?? [];
                  
                  if (admins.isEmpty) {
                    return const Center(
                      child: Text(
                        'No admins found',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppPaddings.medium),
                    itemCount: admins.length,
                    itemBuilder: (context, index) {
                      return _buildAdminCard(admins[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(AdminUser admin) {
    Color statusColor;
    String statusText;
    
    switch (admin.status) {
      case AdminStatus.active:
        statusColor = AppColors.successGreen;
        statusText = 'Active';
        break;
      case AdminStatus.pending:
        statusColor = AppColors.warningOrange;
        statusText = 'Pending';
        break;
      case AdminStatus.blocked:
        statusColor = AppColors.accent;
        statusText = 'Blocked';
        break;
      case AdminStatus.rejected:
        statusColor = Colors.grey;
        statusText = 'Rejected';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.BrightBlue.withOpacity(0.2),
                  child: Icon(Icons.person, color: AppColors.BrightBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admin.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        admin.email,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(Icons.location_on, admin.location),
                ),
                Expanded(
                  child: _buildInfoRow(Icons.business, admin.gymName),
                ),
                Expanded(
                  child: _buildInfoRow(Icons.phone, admin.phone),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (admin.status == AdminStatus.pending)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _handleApproveAdmin(admin.id),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _handleRejectAdmin(admin.id),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (admin.status == AdminStatus.active)
                  ElevatedButton.icon(
                    onPressed: () => _handleBlockAdmin(admin.id),
                    icon: const Icon(Icons.block, size: 16),
                    label: const Text('Block'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warningOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.Lightertext),
        const SizedBox(width:4),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.labelLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _handleApproveAdmin(String adminId) async {
    final currentUser = _superAdminService.getCurrentSuperAdmin();
    final superAdmin = await currentUser;
    if (superAdmin == null) return;

    try {
      await _superAdminService.approveAdmin(adminId, superAdmin.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin approved successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    }
  }

  Future<void> _handleRejectAdmin(String adminId) async {
    final reason = await _showReasonDialog('Reject Admin', 'Enter rejection reason:');
    if (reason == null || reason.isEmpty) return;

    final currentUser = _superAdminService.getCurrentSuperAdmin();
    final superAdmin = await currentUser;
    if (superAdmin == null) return;

    try {
      await _superAdminService.rejectAdmin(adminId, superAdmin.id, reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin rejected'),
            backgroundColor: AppColors.warningOrange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    }
  }

  Future<void> _handleBlockAdmin(String adminId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block Admin'),
        content: const Text('Are you sure you want to block this admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Block',
              style: TextStyle(color: AppColors.warningOrange),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final currentUser = _superAdminService.getCurrentSuperAdmin();
    final superAdmin = await currentUser;
    if (superAdmin == null) return;

    try {
      await _superAdminService.blockAdmin(adminId, superAdmin.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin blocked'),
            backgroundColor: AppColors.warningOrange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    }
  }

  Future<String?> _showReasonDialog(String title, String hint) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
