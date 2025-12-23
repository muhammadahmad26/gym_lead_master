
import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/app_padding.dart';
import 'package:gym_lead_master/src/core/constants/app_text_size.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_payment_page/data/model/payment_summary.dart';
import 'package:intl/intl.dart';

class PaymentSummaryCard extends StatelessWidget {
  final PaymentSummary summary;

  const PaymentSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppPaddings.medium),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Summary',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppPaddings.medium),
            _buildSummaryRow('Last Payment', DateFormat.yMMMd().format(summary.lastPaymentDate),
                '\$${summary.lastPaymentAmount.toStringAsFixed(2)}'),
            const Divider(),
            _buildSummaryRow('Next Payment Due', DateFormat.yMMMd().format(summary.nextPaymentDue),
                '\$${summary.pendingAmount.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String date, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelLarge),
                Text(date, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}


