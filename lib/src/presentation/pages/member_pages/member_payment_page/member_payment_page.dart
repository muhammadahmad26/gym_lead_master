import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/core/constants/app_padding.dart';
import 'package:gym_lead_master/src/core/constants/app_text_size.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/data/model/list_items_model.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/widgets/custom_list_tile.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_payment_page/available_plan_card.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_payment_page/data/model/member_detail.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_payment_page/data/model/payment_summary.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_payment_page/data/model/plan.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_payment_page/data/model/transaction.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_payment_page/payment_header.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_payment_page/payment_method.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_payment_page/payment_summary_card.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_payment_page/transaction_history_tile.dart';

class MemberPaymentScreen extends StatefulWidget {
  final Member member;

  const MemberPaymentScreen({super.key, required this.member});

  @override
  State<MemberPaymentScreen> createState() => _MemberPaymentScreenState();
}

class _MemberPaymentScreenState extends State<MemberPaymentScreen> {
  Plan? _selectedPlan;
  PaymentMethod? _selectedPaymentMethod;

  // --- Dummy Data ---
  late final PaymentSummary _summary;
  late final List<Plan> _availablePlans;
  late final List<Transaction> _transactionHistory;

  @override
  void initState() {
    super.initState();
    _summary = PaymentSummary(
      lastPaymentDate: DateTime.now().subtract(const Duration(days: 30)),
      lastPaymentAmount: 49.99,
      nextPaymentDue: DateTime.now().add(const Duration(days: 30)),
      pendingAmount: 49.99,
    );
    _availablePlans = [
      Plan(id: 'p1', name: 'Basic', duration: 'Monthly', price: 29.99, features: ['Gym Access']),
      Plan(id: 'p2', name: 'Premium', duration: 'Monthly', price: 49.99, features: ['Gym Access', 'Group Classes', '1 PT Session']),
      Plan(id: 'p3', name: 'All-Access', duration: 'Yearly', price: 499.99, features: ['Unlimited Everything', 'Guest Passes']),
    ];
    _transactionHistory = [
      Transaction(id: 't1', date: DateTime.now().subtract(Duration(days: 30)), amount: 49.99, paymentMethod: 'Credit Card', status: TransactionStatus.paid),
      Transaction(id: 't2', date: DateTime.now().subtract(Duration(days: 60)), amount: 49.99, paymentMethod: 'JazzCash', status: TransactionStatus.paid),
      Transaction(id: 't3', date: DateTime.now().subtract(Duration(days: 90)), amount: 29.99, paymentMethod: 'Credit Card', status: TransactionStatus.failed),
    ];
  }

  void _handlePayment() {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );
      return;
    }
    // In a real app, this would integrate with a payment gateway.
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text('Pay \$${_selectedPlan?.price.toStringAsFixed(2)} for ${_selectedPlan?.name} plan with ${_selectedPaymentMethod?.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment Successful!'), backgroundColor: AppColors.successGreen),
              );
            },
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackGroundPage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Payments'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              PaymentHeader(member: widget.member),
              PaymentSummaryCard(summary: _summary),
              AvailablePlansCard(
                plans: _availablePlans,
                onPlanSelected: (plan) {
                  setState(() {
                    _selectedPlan = plan;
                  });
                },
              ),
              PaymentMethodSelector(
                onMethodChanged: (method) {
                  setState(() {
                    _selectedPaymentMethod = method;
                  });
                },
              ),
              const SizedBox(height: AppPaddings.medium),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppPaddings.medium),
                child: ElevatedButton(
                  onPressed: _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    'Pay Now (\$${(_selectedPlan?.price ?? _summary.pendingAmount).toStringAsFixed(2)})',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: AppPaddings.large),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppPaddings.medium),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Transaction History', style: AppTextStyles.headlineMedium),
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _transactionHistory.length,
                itemBuilder: (context, index) {
                  return TransactionHistoryTile(transaction: _transactionHistory[index]);
                },
              ),
              const SizedBox(height: AppPaddings.medium),
              _buildSupportSection(),
              const SizedBox(height: AppPaddings.large),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    final supportItems = [
      ListItem(icon: Icons.help_center, title: 'Help & FAQ'),
      ListItem(icon: Icons.contact_support, title: 'Contact Support'),
    ];

    return Column(
      children: supportItems.map((item) {
        return CustomListTile(
          item: item,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigating to ${item.title}...')),
            );
          },
        );
      }).toList(),
    );
  }
}
