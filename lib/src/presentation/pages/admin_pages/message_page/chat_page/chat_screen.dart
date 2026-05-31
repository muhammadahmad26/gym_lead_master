import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/services/database_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatDetailScreen extends StatefulWidget {
  final String gymId;
  final String receiverUid;
  final String receiverName;
  final String receiverImageBase64;

  const ChatDetailScreen({
    super.key,
    required this.gymId,
    required this.receiverUid,
    required this.receiverName,
    required this.receiverImageBase64,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  final ScrollController _scrollController = ScrollController();
  late String chatRoomId;
  late String currentUserId;

  // Local Deletion States
  List<String> _locallyDeletedIds = [];
  DateTime? _chatClearedTime;
  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    chatRoomId = _dbService.getChatRoomId(currentUserId, widget.receiverUid);
    _dbService.markMessagesAsRead(widget.gymId, chatRoomId, currentUserId);
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedIds =
        prefs.getStringList('deleted_msgs_$chatRoomId') ?? [];
    final String? clearedTimeStr = prefs.getString('cleared_time_$chatRoomId');

    setState(() {
      _locallyDeletedIds = savedIds;
      if (clearedTimeStr != null) {
        _chatClearedTime = DateTime.parse(clearedTimeStr);
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String text = _messageController.text.trim();
    _messageController.clear();

    DocumentSnapshot senderDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .get();
    Map<String, dynamic> senderData = {
      'uid': currentUserId,
      'name': senderDoc['name'] ?? 'User',
      'profileImageBase64': senderDoc['profileImageBase64'] ?? '',
    };

    Map<String, dynamic> receiverData = {
      'uid': widget.receiverUid,
      'name': widget.receiverName,
      'profileImageBase64': widget.receiverImageBase64,
    };

    await _dbService.sendMessage(
      gymId: widget.gymId,
      chatRoomId: chatRoomId,
      text: text,
      senderUid: currentUserId,
      senderData: senderData,
      receiverData: receiverData,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) return "TODAY";
    if (messageDate == yesterday) return "YESTERDAY";
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Long Press Dialog (Delete Options)
  void _showDeleteOptionsDialog(String messageId, bool isMe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              if (isMe)
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    'Delete for everyone',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _dbService.deleteMessageForEveryone(
                      widget.gymId,
                      chatRoomId,
                      messageId,
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.grey),
                title: const Text(
                  'Delete for me',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() {
                    if (!_locallyDeletedIds.contains(messageId)) {
                      _locallyDeletedIds.add(messageId);
                    }
                  });
                  await _dbService.saveLocalDeletedMessages(chatRoomId, [
                    messageId,
                  ]);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.grey),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // Clear Chat Dialog (No Firebase .get() call - App will never freeze!)
  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Clear Chat?"),
            content: const Text(
              "Messages will only be deleted from your screen.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  DateTime clearTime = DateTime.now();

                  setState(() {
                    _chatClearedTime = clearTime;
                  });

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(
                    'cleared_time_$chatRoomId',
                    clearTime.toIso8601String(),
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Chat cleared for you ✅"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  "Clear",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            _buildProfileAvatar(widget.receiverImageBase64, radius: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(widget.receiverName, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        backgroundColor: AppColors.DarkBlueGrey,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _showClearChatDialog();
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Clear Chat', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _dbService.getChatMessages(widget.gymId, chatRoomId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Error loading messages.",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No messages yet. Say Hi! 👋"),
                  );
                }

                var allMessages = snapshot.data!.docs;

                var messages =
                    allMessages.where((doc) {
                      var msgData = doc.data() as Map<String, dynamic>;
                      String messageId = doc.id;

                      // if (msgData['deletedForEveryone'] == true) return false;

                      if (_locallyDeletedIds.contains(messageId)) return false;

                      //agr ya sms clear time sa porna ha to na dikhya
                      if (_chatClearedTime != null &&
                          msgData['timestamp'] != null) {
                        DateTime msgTime =
                            (msgData['timestamp'] as Timestamp).toDate();
                        //agr ya sms clear time sa phla ka ha to gyb ho jay
                        if (!msgTime.isAfter(_chatClearedTime!)) {
                          return false;
                        }
                      }

                      return true;
                    }).toList();

                if (messages.isEmpty) {
                  return const Center(
                    child: Text("No messages yet. Say Hi! 👋"),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var msgData =
                        messages[index].data() as Map<String, dynamic>;
                    String messageId = messages[index].id;
                    bool isMe = msgData['senderId'] == currentUserId;

                    bool showDate = false;
                    String dateText = "";

                    if (msgData['timestamp'] != null) {
                      DateTime currentMsgDate =
                          (msgData['timestamp'] as Timestamp).toDate();
                      dateText = _formatDate(currentMsgDate);

                      if (index == messages.length - 1) {
                        showDate = true;
                      } else {
                        var prevMsgData =
                            messages[index + 1].data() as Map<String, dynamic>?;
                        if (prevMsgData != null &&
                            prevMsgData['timestamp'] != null) {
                          DateTime prevMsgDate =
                              (prevMsgData['timestamp'] as Timestamp).toDate();
                          if (currentMsgDate.day != prevMsgDate.day ||
                              currentMsgDate.month != prevMsgDate.month) {
                            showDate = true;
                          }
                        }
                      }
                    }

                    return Column(
                      children: [
                        if (showDate) _buildDateSeparator(dateText),
                        GestureDetector(
                          onLongPress:
                              () => _showDeleteOptionsDialog(messageId, isMe),
                          child: _buildMessageBubble(msgData, isMe),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.blueColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Normal Message Bubble
  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    bool isDeletedForEveryone = msg['deletedForEveryone'] ?? false;

    // NEW: If message was deleted for everyone, show replacement UI
    if (isDeletedForEveryone) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[200], // Light grey background
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.block,
                size: 14,
                color: Colors.grey[500],
              ), // Block icon
              const SizedBox(width: 6),
              Text(
                "This message was deleted",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // --- Normal Message Rendering (If NOT deleted) ---
    String text = msg['text'] ?? '';
    bool isRead = msg['isRead'] ?? false;
    String timeStr = "";

    if (msg['timestamp'] != null) {
      DateTime dt = (msg['timestamp'] as Timestamp).toDate();
      timeStr = DateFormat('hh:mm a').format(dt);
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
        padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.blueColor : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                if (isMe)
                  Icon(
                    Icons.done_all,
                    size: 16,
                    color: isRead ? Colors.lightBlueAccent : Colors.white70,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSeparator(String dateText) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            dateText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(String base64Image, {double radius = 25}) {
    if (base64Image.isNotEmpty) {
      try {
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[300],
          backgroundImage: MemoryImage(base64Decode(base64Image)),
        );
      } catch (e) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, size: radius),
        );
      }
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: Icon(Icons.person, size: radius),
    );
  }
}
