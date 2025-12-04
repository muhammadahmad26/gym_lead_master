import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/data/model/messages_model.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/message_list_tile.dart';

class MessageListView extends StatelessWidget {
  final List<MessagesModel> message;
  const MessageListView({super.key, required this.message,});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
      child: ListView.builder(
        itemCount: message.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: MessageListTile(message: message[index]),
          );
        },
      ),
    );
  }
}
