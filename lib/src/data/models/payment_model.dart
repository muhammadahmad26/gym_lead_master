import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentMethodModel {
  final String id;
  final String gymId;
  final String type; // "jazzcash" | "easypaisa" | "bank"
  final String accountTitle;
  final String accountNumber;
  final String bankName;
  final String iban;
  final bool isActive;

  PaymentMethodModel({
    required this.id,
    required this.gymId,
    required this.type,
    required this.accountTitle,
    required this.accountNumber,
    this.bankName = '',
    this.iban = '',
    this.isActive = true,
  });

  String get typeLabel {
    switch (type.toLowerCase()) {
      case 'jazzcash': return 'JazzCash';
      case 'easypaisa': return 'EasyPaisa';
      case 'bank': return 'Bank Account';
      default: return type;
    }
  }

  IconData get icon {
    switch (type.toLowerCase()) {
      case 'jazzcash': return Icons.phone_android;
      case 'easypaisa': return Icons.account_balance_wallet;
      case 'bank': return Icons.account_balance;
      default: return Icons.payment;
    }
  }

  String get displayName => "$typeLabel - $accountTitle - $accountNumber";

  factory PaymentMethodModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PaymentMethodModel(
      id: doc.id,
      gymId: data['gymId'] ?? '',
      type: data['type'] ?? 'jazzcash',
      accountTitle: data['accountTitle'] ?? '',
      accountNumber: data['accountNumber'] ?? '',
      bankName: data['bankName'] ?? '',
      iban: data['iban'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gymId': gymId,
      'type': type,
      'accountTitle': accountTitle,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'iban': iban,
      'isActive': isActive,
    };
  }
}