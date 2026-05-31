
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum NotificationType {
  general,
  timing,
  paymentReminder,
  paymentApproved,
  paymentRejected,
  membershipExpiry,
  membershipRenewed,
  newPlan,
  event,
  emergency;

  static NotificationType fromString(String type) {
    return NotificationType.values.firstWhere(
      (e) => e.name.toLowerCase() == type.toLowerCase(),
      orElse: () => NotificationType.general,
    );
  }
}

extension NotificationTypeExtension on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.general:
        return 'General';
      case NotificationType.timing:
        return 'Gym Timing';
      case NotificationType.paymentReminder:
        return 'Payment Reminder';
      case NotificationType.paymentApproved:
        return 'Payment Approved';
      case NotificationType.paymentRejected:
        return 'Payment Rejected';
      case NotificationType.membershipExpiry:
        return 'Membership Expiring';
      case NotificationType.membershipRenewed:
        return 'Membership Renewed';
      case NotificationType.newPlan:
        return 'New Plan';
      case NotificationType.event:
        return 'Event';
      case NotificationType.emergency:
        return 'Emergency';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.general:
        return Icons.info_outline;
      case NotificationType.timing:
        return Icons.access_time;
      case NotificationType.paymentReminder:
        return Icons.payment_outlined;
      case NotificationType.paymentApproved:
        return Icons.check_circle_outline;
      case NotificationType.paymentRejected:
        return Icons.cancel_outlined;
      case NotificationType.membershipExpiry:
        return Icons.timer_off;
      case NotificationType.membershipRenewed:
        return Icons.autorenew;
      case NotificationType.newPlan:
        return Icons.new_releases_outlined;
      case NotificationType.event:
        return Icons.event_outlined;
      case NotificationType.emergency:
        return Icons.warning_amber_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.emergency:
        return Colors.red;
      case NotificationType.paymentRejected:
        return Colors.redAccent;
      case NotificationType.paymentApproved:
        return Colors.green;
      case NotificationType.membershipRenewed:
        return Colors.green;
      case NotificationType.newPlan:
        return Colors.blue;
      case NotificationType.event:
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }
}

class AppNotification {
  final String id;
  final String gymId;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime? createdAt;
  final String createdBy;
  final bool isRead;
  final DateTime? readAt;
  final bool isDeleted;
  final DateTime? deletedAt;      
  final String gymNotifId;        
  final int targetCount;        

  AppNotification({
    required this.id,
    this.gymId = '',
    required this.title,
    required this.message,
    this.type = NotificationType.general,
    this.createdAt,
    this.createdBy = '',
    this.isRead = false,
    this.readAt,
    this.isDeleted = false,
    this.deletedAt,                 
    this.gymNotifId = '',    
    this.targetCount = 0,           
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      gymId: data['gymId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.fromString(data['type'] ?? 'general'),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      createdBy: data['createdBy'] ?? '',
      isRead: data['isRead'] ?? false,
      readAt: data['readAt'] != null
          ? (data['readAt'] as Timestamp).toDate()
          : null,
      isDeleted: data['isDeleted'] ?? false,
      deletedAt: data['deletedAt'] != null             
          ? (data['deletedAt'] as Timestamp).toDate()
          : null,
      gymNotifId: data['gymNotifId'] ?? '',            
      targetCount: data['targetCount'] ?? 0,           
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gymId': gymId,
      'title': title,
      'message': message,
      'type': type.name,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,  
      'gymNotifId': gymNotifId,                                               
      'targetCount': targetCount,                                              
    };
  }
}