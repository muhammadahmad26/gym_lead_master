import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/chat_page/chat_list.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/data/model/chat_message_model.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/data/model/messages_model.dart';

class ChatDetailScreen extends StatefulWidget {
  final MessagesModel message;

  const ChatDetailScreen({super.key, required this.message});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<MessagesModel> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages = [widget.message];
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // Add to Firestore
      await _firestore.collection('messages').add({
        'senderId': currentUser.uid,
        'senderName': currentUser.displayName ?? 'User',
        'senderEmail': currentUser.email ?? '',
        'senderRole': 'admin',
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Clear input
      _messageController.clear();

      // Update local state for immediate feedback
      setState(() {
        widget.message.chatMessage.add(
          ChatMessageModel(
            id: DateTime.now().toString(),
            text: text,
            time: DateTime.now().toString().substring(11, 16),
            isMe: true,
          ),
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
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
    final chat = widget.message.chatMessage;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.whiteColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 58, 67, 94),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              child: Image.asset(AppImages.userIcon, fit: BoxFit.contain),
            ),
            const SizedBox(width: 10),
            Text(
              widget.message.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.whiteColor,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: chat.length,
              itemBuilder: (context, index) {
                return ChatList(chat: chat[index]);
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
