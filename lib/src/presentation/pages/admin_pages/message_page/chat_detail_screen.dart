import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/data/model/messages_model.dart';

class ChatDetailScreen extends StatelessWidget {
  final MessagesModel message;

  ChatDetailScreen({super.key, required this.message});

  final List<Map<String, dynamic>> dummyMessages = [
    {"isMe": false, "msg": "Hello! How are you?", "time": "10:55 AM"},
    {"isMe": true, "msg": "I'm good! How about you?", "time": "10:56 AM"},
    {"isMe": false, "msg": "I'm fine. Need help with training?", "time": "10:57 AM"},
    {"isMe": true, "msg": "Yes sure, guide me for today's exercise.", "time": "10:58 AM"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage("assets/user.png"),
            ),
            const SizedBox(width: 10),
            Text(
              message.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: dummyMessages.length,
              itemBuilder: (context, index) {
                final chat = dummyMessages[index];
                final bool isMe = chat["isMe"];

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(isMe ? 12 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          chat["msg"],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chat["time"],
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.black54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
