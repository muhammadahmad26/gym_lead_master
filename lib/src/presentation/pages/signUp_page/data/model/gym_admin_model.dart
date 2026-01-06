import 'package:cloud_firestore/cloud_firestore.dart';

enum AdminStatus {
  pending,
  active,
  blocked,
  rejected,
}

class GymAdmin {
  final String id;
  final String email;
  final String name;
  final String location;
  final String phone;
  final String gymName;
  final AdminStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? blockedAt;
  final String? approvedBy; // Super Admin ID who approved
  final String? blockedBy; // Super Admin ID who blocked
  final String rejectionReason; // If rejected

  GymAdmin({
    required this.id,
    required this.email,
    required this.name,
    required this.location,
    required this.phone,
    required this.gymName,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.blockedAt,
    this.approvedBy,
    this.blockedBy,
    this.rejectionReason = '',
  });

  factory GymAdmin.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GymAdmin(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      phone: data['phone'] ?? '',
      gymName: data['gymName'] ?? '',
      status: AdminStatus.values.firstWhere(
        (e) => e.toString() == 'AdminStatus.${data['status']}',
        orElse: () => AdminStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      approvedAt: data['approvedAt'] != null
          ? (data['approvedAt'] as Timestamp).toDate()
          : null,
      blockedAt: data['blockedAt'] != null
          ? (data['blockedAt'] as Timestamp).toDate()
          : null,
      approvedBy: data['approvedBy'],
      blockedBy: data['blockedBy'],
      rejectionReason: data['rejectionReason'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'location': location,
      'phone': phone,
      'gymName': gymName,
      'status': status.toString().split('.').last,
      'createdAt': createdAt,
      'approvedAt': approvedAt,
      'blockedAt': blockedAt,
      'approvedBy': approvedBy,
      'blockedBy': blockedBy,
      'rejectionReason': rejectionReason,
    };
  }
}
