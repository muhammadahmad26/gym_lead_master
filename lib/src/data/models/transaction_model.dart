import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// UPDATED: Enhanced Enum with direct properties
enum TransactionStatus {
  notPaid('not_paid', 'NOT PAID', Colors.grey),
  pending('pending', 'PENDING', Colors.orange),
  approved('approved', 'APPROVED', Colors.green),
  failed('failed', 'FAILED', Colors.red);

  final String firebaseValue;
  final String label;
  final Color color;

  const TransactionStatus(this.firebaseValue, this.label, this.color);

  
  static TransactionStatus fromString(String status) {
    return TransactionStatus.values.firstWhere(
      (e) => e.firebaseValue.toLowerCase() == status.toLowerCase(),
      orElse: () => TransactionStatus.notPaid,
    );
  }
}

class TransactionModel {
  final String id;
  final String memberId;
  final String memberName;
  final String memberEmail;
  final String gymId;
  final String planId;
  final String planName;
  final double amount;
  final String duration;
  final String paymentMethodId;
  final String paymentMethodType;
  final String paymentMethodLabel;
  final String accountTitle;
  final String accountNumber;
  final String screenshotUrl;
  final TransactionStatus status;
  final DateTime? createdAt;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String reviewedBy;
  final String rejectionReason;

  TransactionModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.memberEmail,
    required this.gymId,
    this.planId = '',
    this.planName = 'No Plan Selected',
    this.amount = 0.0,
    this.duration = '',
    this.paymentMethodId = '',
    this.paymentMethodType = '',
    this.paymentMethodLabel = '',
    this.accountTitle = '',
    this.accountNumber = '',
    this.screenshotUrl = '',
    this.status = TransactionStatus.notPaid,
    this.createdAt,
    this.submittedAt,
    this.approvedAt,
    this.rejectedAt,
    this.reviewedBy = '',
    this.rejectionReason = '',
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      memberId: data['memberId'] ?? '',
      memberName: data['memberName'] ?? '',
      memberEmail: data['memberEmail'] ?? '',
      gymId: data['gymId'] ?? '',
      planId: data['planId'] ?? '',
      planName: data['planName'] ?? 'No Plan',
      amount: (data['amount'] ?? 0.0).toDouble(),
      duration: data['duration'] ?? '',
      paymentMethodId: data['paymentMethodId'] ?? '',
      paymentMethodType: data['paymentMethodType'] ?? '',
      paymentMethodLabel: data['paymentMethodLabel'] ?? '',
      accountTitle: data['accountTitle'] ?? '',
      accountNumber: data['accountNumber'] ?? '',
      screenshotUrl: data['screenshotUrl'] ?? '',
      status: TransactionStatus.fromString(data['status'] ?? 'not_paid'), 
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
      submittedAt: data['submittedAt'] != null ? (data['submittedAt'] as Timestamp).toDate() : null,
      approvedAt: data['approvedAt'] != null ? (data['approvedAt'] as Timestamp).toDate() : null,
      rejectedAt: data['rejectedAt'] != null ? (data['rejectedAt'] as Timestamp).toDate() : null,
      reviewedBy: data['reviewedBy'] ?? '',
      rejectionReason: data['rejectionReason'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'memberEmail': memberEmail,
      'gymId': gymId,
      'planId': planId,
      'planName': planName,
      'amount': amount,
      'duration': duration,
      'paymentMethodId': paymentMethodId,
      'paymentMethodType': paymentMethodType,
      'paymentMethodLabel': paymentMethodLabel,
      'accountTitle': accountTitle,
      'accountNumber': accountNumber,
      'screenshotUrl': screenshotUrl,
      'status': status.firebaseValue,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'submittedAt': submittedAt != null ? Timestamp.fromDate(submittedAt!) : null,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'rejectedAt': rejectedAt != null ? Timestamp.fromDate(rejectedAt!) : null,
      'reviewedBy': reviewedBy,
      'rejectionReason': rejectionReason,
    };
  }
}