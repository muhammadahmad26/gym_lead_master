import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/app_padding.dart';
import 'package:gym_lead_master/src/core/constants/app_text_size.dart';

enum PaymentMethod { creditCard, jazzCash, easypaisa, cash }

class PaymentMethodSelector extends StatefulWidget {
  final Function(PaymentMethod) onMethodChanged;

  const PaymentMethodSelector({super.key, required this.onMethodChanged});

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  PaymentMethod _selectedMethod = PaymentMethod.creditCard;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppPaddings.medium),
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: AppTextStyles.headlineMedium,
            ),
            RadioListTile<PaymentMethod>(
              title: const Text('Credit / Debit Card'),
              value: PaymentMethod.creditCard,
              groupValue: _selectedMethod,
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                  widget.onMethodChanged(_selectedMethod);
                });
              },
              secondary: const Icon(Icons.credit_card),
            ),
            RadioListTile<PaymentMethod>(
              title: const Text('JazzCash'),
              value: PaymentMethod.jazzCash,
              groupValue: _selectedMethod,
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                  widget.onMethodChanged(_selectedMethod);
                });
              },
              secondary: const Icon(Icons.account_balance_wallet),
            ),
            RadioListTile<PaymentMethod>(
              title: const Text('Easypaisa'),
              value: PaymentMethod.easypaisa,
              groupValue: _selectedMethod,
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                  widget.onMethodChanged(_selectedMethod);
                });
              },
              secondary: const Icon(Icons.account_balance_wallet),
            ),
          ],
        ),
      ),
    );
  }
}