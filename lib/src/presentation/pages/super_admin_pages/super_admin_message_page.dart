import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_text_size.dart';
import 'package:gym_lead_master/src/presentation/pages/super_admin_pages/data/model/admin_message_model.dart';

import 'data/services/super_admin_service.dart';

class SuperAdminMessagePage extends StatefulWidget {
  const SuperAdminMessagePage({super.key});

  @override
  State<SuperAdminMessagePage> createState() => _SuperAdminMessagePageState();
}

class _SuperAdminMessagePageState extends State<SuperAdminMessagePage> {
  final SuperAdminService _superAdminService = SuperAdminService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();

  List<MessageThread> _threads = [];
  MessageThread? _selectedThread;
  List<AdminMessage> _currentMessages = [];

  @override
  void initState() {
    super.initState();
    _loadMessageThreads();
  }

  void _loadMessageThreads() {
    final superAdmin = _auth.currentUser;
    if (superAdmin == null) return;

    _superAdminService.getMessageThreads(superAdmin.uid).listen((threads) {
      setState(() => _threads = threads);
    });
  }

  void _loadThreadMessages(String participantId) {
    _superAdminService.getThreadMessages(participantId).listen((messages) {
      setState(() => _currentMessages = messages);
    });
  }

  void _selectThread(MessageThread thread) {
    setState(() => _selectedThread = thread);
    _loadThreadMessages(thread.participantId);
    
    // Mark as read
    final unreadMessageIds = thread.messages
        .where((msg) => !msg.isRead)
        .map((msg) => msg.id)
        .toList();
    if (unreadMessageIds.isNotEmpty) {
      _superAdminService.markAsRead(unreadMessageIds);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _selectedThread == null) return;

    final superAdmin = _auth.currentUser;
    if (superAdmin == null) return;

    try {
      await _superAdminService.sendMessage(
        senderId: superAdmin.uid,
        senderName: 'Super Admin',
        senderEmail: superAdmin.email ?? '',
        senderRole: 'super_admin',
        text: _messageController.text.trim(),
      );
      
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: ${e.toString()}'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.DarkBlueGrey,
        elevation: 0,
        title: Row(
          children: [
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "G",
                    style: TextStyle(
                      color: Color(0xFFFFEB3B),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: "Y",
                    style: TextStyle(
                      color: Color(0xFFFF9800),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: "M",
                    style: TextStyle(
                      color: Color(0xFF80FFB0),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: " Messages",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _selectedThread = null);
            },
            icon: const Icon(Icons.inbox, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBlue,
              AppColors.mediumBlue,
              AppColors.lightBlue,
              Color.fromARGB(255, 150, 179, 218),
              Color.fromARGB(255, 198, 218, 245),
            ],
          ),
        ),
        child: Row(
          children: [
            // Left side: Thread list
            Expanded(
              flex: _selectedThread == null ? 1 : 1,
              child: _buildThreadList(),
            ),
            
            // Right side: Chat view (only visible when thread selected)
            if (_selectedThread != null) ...[
              const VerticalDivider(width: 1, color: Colors.white),
              Expanded(
                flex: 2,
                child: _buildChatView(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThreadList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Admins',
              style: AppTextStyles.headlineMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: _threads.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _threads.length,
                    itemBuilder: (context, index) {
                      return _buildThreadTile(_threads[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadTile(MessageThread thread) {
    final isSelected = _selectedThread?.threadId == thread.threadId;

    return InkWell(
      onTap: () => _selectThread(thread),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.BrightBlue.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.BrightBlue.withOpacity(0.2),
              child: const Icon(Icons.person, color: AppColors.BrightBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        thread.participantName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (thread.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${thread.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height:4),
                  Text(
                    thread.lastMessageText,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height:4),
                  Text(
                    _formatTime(thread.lastMessageTime),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.DarkBlueGrey.withOpacity(0.5),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() => _selectedThread = null);
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.BrightBlue.withOpacity(0.2),
                child: const Icon(Icons.person, color: AppColors.BrightBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedThread?.participantName ?? 'Admin',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _selectedThread?.participantEmail ?? '',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: _currentMessages.isEmpty
              ? Center(
                  child: Text(
                    'No messages in this conversation',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _currentMessages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(_currentMessages[index]);
                  },
                ),
        ),

        // Input field
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.DarkBlueGrey.withOpacity(0.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.BrightBlue,
                child: IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(AdminMessage message) {
    final isSuperAdmin = message.senderRole == 'super_admin';

    return Align(
      alignment: isSuperAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isSuperAdmin ? AppColors.BrightBlue : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSuperAdmin)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.senderName,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.BrightBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              message.text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSuperAdmin ? Colors.white : Colors.white,
              ),
            ),
            const SizedBox(height:4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isSuperAdmin ? Colors.white70 : Colors.white70,
                  ),
                ),
                if (!message.isRead) ...[
                  const SizedBox(width: 8),
                  const Text(
                    '✓',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
