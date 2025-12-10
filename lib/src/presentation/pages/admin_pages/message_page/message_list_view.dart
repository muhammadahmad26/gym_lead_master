import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/app_padding.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/data/model/messages_model.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/message_list_tile.dart';

class MessageListView extends StatelessWidget {
  final List<MessagesModel> message;
  const MessageListView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        top: AppPaddings.medium,
        left: AppPaddings.small,
        right: AppPaddings.small,
      ),
      itemCount: message.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: MessageListTile(message: message[index]),
        );
      },
    );
  }
}
