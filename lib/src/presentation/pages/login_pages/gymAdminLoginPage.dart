import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/presentation/pages/common/login_page.dart';

class GymAdminLoginPage extends StatefulWidget {
  const GymAdminLoginPage({super.key});

  @override
  State<GymAdminLoginPage> createState() => _GymAdminLoginPageState();
}

class _GymAdminLoginPageState extends State<GymAdminLoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AppBackGroundPage(
        child: Center(
          child: LoginPage()
        ),
      ),
    );
  }
}
