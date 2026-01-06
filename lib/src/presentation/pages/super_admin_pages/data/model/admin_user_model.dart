import 'package:cloud_firestore/cloud_firestore.dart';

enum AdminStatus {
  pending,
  active,
  blocked,
  rejected,
}

enum UserRole {
  superAdmin,
  admin,
  member,
}

class AdminUser {
  final String id;
  final String email;
  final String name;
  final String location;
  final String phone;
  final String gymName;
  final AdminStatus status;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? blockedAt;
  final String? approvedBy;
  final String? blockedBy;
  final String rejectionReason;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.location,
    required this.phone,
    required this.gymName,
    required this.status,
    required this.role,
    required this.createdAt,
    this.approvedAt,
    this.blockedAt,
    this.approvedBy,
    this.blockedBy,
    this.rejectionReason = '',
  });

  factory AdminUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUser(
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
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.admin,
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
      'role': role.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'blockedAt': blockedAt != null ? Timestamp.fromDate(blockedAt!) : null,
      'approvedBy': approvedBy,
      'blockedBy': blockedBy,
      'rejectionReason': rejectionReason,
    };
  }
}