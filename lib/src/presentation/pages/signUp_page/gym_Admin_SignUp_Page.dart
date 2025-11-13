import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/presentation/pages/common/signUp_page.dart';

class GymAdminSignupPage extends StatefulWidget {
  const GymAdminSignupPage({super.key});

  @override
  State<GymAdminSignupPage> createState() => _GymAdminSignupPageState();
}

class _GymAdminSignupPageState extends State<GymAdminSignupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AppBackGroundPage(child: Center(child: SignUpPage())),
    );
  }
}
