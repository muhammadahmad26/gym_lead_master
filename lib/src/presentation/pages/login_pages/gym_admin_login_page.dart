import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/presentation/pages/common/login_page.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';

class GymAdminLoginPage extends StatelessWidget {
  const GymAdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AppBackGroundPage(
        child: LoginPage(
          route: AppRoutes.adminHomePage,
          recognizer:
              TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.gymAdminSignUpPage,
                    (route) => route.settings.name == AppRoutes.initialPage,
                  );
                },
        ),
      ),
    );
  }
}
