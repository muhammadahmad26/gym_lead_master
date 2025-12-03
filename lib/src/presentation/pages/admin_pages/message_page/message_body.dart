import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/data/member_message_dummy_data.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/message_list_view.dart';

class MessageBody extends StatelessWidget {
  const MessageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackGroundPage(
        child: MessageListView(message: MemberMessageDummyData.member),
      ),
    );
  }
}
