import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus {
  pending,
  approved,
  failed,
}

class AdminPayment {
  final String id;
  final String adminId;
  final String adminName;
  final String adminEmail;
  final String gymName;
  final double amount;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? processedBy;
  final String rejectionReason;

  AdminPayment({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.adminEmail,
    required this.gymName,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.processedBy,
    this.rejectionReason = '',
  });

  factory AdminPayment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminPayment(
      id: doc.id,
      adminId: data['adminId'] ?? '',
      adminName: data['adminName'] ?? '',
      adminEmail: data['adminEmail'] ?? '',
      gymName: data['gymName'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${data['status']}',
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      processedAt: data['processedAt'] != null
          ? (data['processedAt'] as Timestamp).toDate()
          : null,
      processedBy: data['processedBy'],
      rejectionReason: data['rejectionReason'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'adminName': adminName,
      'adminEmail': adminEmail,
      'gymName': gymName,
      'amount': amount,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'processedAt': processedAt != null ? Timestamp.fromDate(processedAt!) : null,
      'processedBy': processedBy,
      'rejectionReason': rejectionReason,
    };
  }
}