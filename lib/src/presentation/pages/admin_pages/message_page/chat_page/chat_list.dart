import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/data/model/chat_message_model.dart';

class ChatList extends StatelessWidget {
  final ChatMessageModel chat;

  const ChatList({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: chat.isMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: chat.isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: chat.isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              chat.text,
              style: TextStyle(
                fontSize: 16,
                color: chat.isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              chat.time,
              style: TextStyle(
                fontSize: 11,
                color: chat.isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}