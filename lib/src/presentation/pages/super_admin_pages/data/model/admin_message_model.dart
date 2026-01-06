import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderEmail;
  final String senderRole;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  AdminMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderEmail,
    required this.senderRole,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  factory AdminMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderEmail: data['senderEmail'] ?? '',
      senderRole: data['senderRole'] ?? 'admin',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderEmail': senderEmail,
      'senderRole': senderRole,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}

class MessageThread {
  final String threadId;
  final String participantId;
  final String participantName;
  final String participantEmail;
  final String participantRole;
  final List<AdminMessage> messages;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String lastMessageText;

  MessageThread({
    required this.threadId,
    required this.participantId,
    required this.participantName,
    required this.participantEmail,
    required this.participantRole,
    required this.messages,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.lastMessageText = '',
  });
}
