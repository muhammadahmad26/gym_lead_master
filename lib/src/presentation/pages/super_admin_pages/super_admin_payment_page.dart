import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_padding.dart';
import 'package:gym_lead_master/src/core/constants/app_text_size.dart';
import 'package:gym_lead_master/src/presentation/pages/super_admin_pages/data/model/admin_payment_model.dart';

import 'data/services/super_admin_service.dart';

class SuperAdminPaymentPage extends StatefulWidget {
  const SuperAdminPaymentPage({super.key});

  @override
  State<SuperAdminPaymentPage> createState() => _SuperAdminPaymentPageState();
}

class _SuperAdminPaymentPageState extends State<SuperAdminPaymentPage> {
  final SuperAdminService _superAdminService = SuperAdminService();
  PaymentStatus _selectedFilter = PaymentStatus.pending;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.DarkBlueGrey,
        elevation: 0,
        title: Row(
          children: [
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
                    text: " Payments",
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
            // Filter Tabs
            Padding(
              padding: const EdgeInsets.all(AppPaddings.medium),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFilterTab(
                        'Pending',
                        PaymentStatus.pending,
                        AppColors.warningOrange,
                      ),
                    ),
                    Expanded(
                      child: _buildFilterTab(
                        'Approved',
                        PaymentStatus.approved,
                        AppColors.successGreen,
                      ),
                    ),
                    Expanded(
                      child: _buildFilterTab(
                        'Failed',
                        PaymentStatus.failed,
                        AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Payments List
            Expanded(
              child: StreamBuilder<List<AdminPayment>>(
                stream: _superAdminService.getPaymentsByStatus(_selectedFilter),
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

                  final payments = snapshot.data ?? [];

                  if (payments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ${_selectedFilter.toString().split('.').last} payments',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppPaddings.medium),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      return _buildPaymentCard(payments[index]);
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

  Widget _buildFilterTab(String label, PaymentStatus status, Color color) {
    final isSelected = _selectedFilter == status;

    return InkWell(
      onTap: () {
        setState(() => _selectedFilter = status);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(AdminPayment payment) {
    Color statusColor;
    String statusText;

    switch (payment.status) {
      case PaymentStatus.pending:
        statusColor = AppColors.warningOrange;
        statusText = 'Pending';
        break;
      case PaymentStatus.approved:
        statusColor = AppColors.successGreen;
        statusText = 'Approved';
        break;
      case PaymentStatus.failed:
        statusColor = AppColors.accent;
        statusText = 'Failed';
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
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.BrightBlue.withOpacity(0.2),
                  child: const Icon(Icons.person, color: AppColors.BrightBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.adminName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        payment.adminEmail,
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

            // Details
            _buildDetailRow(Icons.business, 'Gym', payment.gymName),
            _buildDetailRow(Icons.attach_money, 'Amount', '\$${payment.amount.toStringAsFixed(2)}'),
            _buildDetailRow(Icons.calendar_today, 'Date', _formatDate(payment.createdAt)),

            if (payment.processedAt != null)
              _buildDetailRow(
                Icons.check_circle,
                'Processed',
                _formatDate(payment.processedAt!),
              ),

            if (payment.rejectionReason.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        payment.rejectionReason,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Actions
            if (payment.status == PaymentStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _handleApprovePayment(payment.id),
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
                    onPressed: () => _handleRejectPayment(payment.id),
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.Lightertext),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: AppTextStyles.labelLarge,
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handleApprovePayment(String paymentId) async {
    try {
      await _superAdminService.approvePayment(paymentId, 'super_admin');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment approved successfully'),
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

  Future<void> _handleRejectPayment(String paymentId) async {
    final reason = await _showReasonDialog('Reject Payment', 'Enter rejection reason:');
    if (reason == null || reason.isEmpty) return;

    try {
      await _superAdminService.rejectPayment(paymentId, 'super_admin', reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment rejected'),
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
