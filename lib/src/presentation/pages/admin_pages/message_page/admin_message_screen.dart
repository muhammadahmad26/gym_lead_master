import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/message_body.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/message_screen_bar.dart';

class AdminMessageScreen extends StatefulWidget {
  const AdminMessageScreen({super.key});

  @override
  State<AdminMessageScreen> createState() => _AdminMessageScreenState();
}

class _AdminMessageScreenState extends State<AdminMessageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: const MessageScreenBar(),
      ),
      body: AppBackGroundPage(child: MessageBody()),
    );
  }
}
