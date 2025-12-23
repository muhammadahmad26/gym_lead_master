import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_payment_page/data/model/transaction.dart';
import 'package:intl/intl.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_padding.dart';
import 'package:gym_lead_master/src/core/constants/app_text_size.dart';

class TransactionHistoryTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionHistoryTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    Color statusColor = AppColors.accent;
    String statusText = 'UNKNOWN';
    switch (transaction.status) {
      case TransactionStatus.paid:
        statusColor = AppColors.successGreen;
        statusText = 'PAID';
        break;
      case TransactionStatus.pending:
        statusColor = AppColors.warningOrange;
        statusText = 'PENDING';
        break;
      case TransactionStatus.failed:
        statusColor = AppColors.accent;
        statusText = 'FAILED';
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppPaddings.medium,
        vertical: 4,
      ),
      child: ListTile(
        leading: const Icon(Icons.receipt_long, color: AppColors.BrightBlue),
        title: Text(
          NumberFormat.currency(symbol: '\$').format(transaction.amount),
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${DateFormat('MMM dd, yyyy').format(transaction.date)} • ${transaction.paymentMethod}',
          style: AppTextStyles.bodyMedium,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
