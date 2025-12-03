import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/chat_detail_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/data/model/messages_model.dart';

class MessageListTile extends StatelessWidget {
  const MessageListTile({super.key, required this.message});

  final MessagesModel message;
  bool isCount() {
    return int.tryParse(message.count) != null && int.parse(message.count) > 0;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50.0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(message: message),
          ),
        );
      },
      child: ListTile(
        leading: GestureDetector(
          child: CircleAvatar(
            radius: 25,
            child: Image.asset(AppImages.userIcon, fit: BoxFit.contain),
          ),
        ),
        title: Text(
          message.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          message.messageContant,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.blackColor,
            fontWeight: isCount() ? FontWeight.w600 : FontWeight.normal,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.time,
              style: TextStyle(
                color: AppColors.blackColor,
                fontSize: 12,
                fontWeight: isCount() ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (int.tryParse(message.count) != null &&
                int.parse(message.count) > 0)
              Container(
                margin: EdgeInsets.only(top: 4),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 44, 62, 110), // unread badge
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message.count,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
