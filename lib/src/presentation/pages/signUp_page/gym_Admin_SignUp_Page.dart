import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/presentation/pages/common/signUp_page.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';

class GymAdminSignupPage extends StatelessWidget {
  const GymAdminSignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AppBackGroundPage(
        child: Center(child: SignUpPage(
          route: AppRoutes.gymAdminLogInPage,
          recognizer: AppRoutes.gymAdminLogInPage,
        )),
      ),
    );
  }
}

