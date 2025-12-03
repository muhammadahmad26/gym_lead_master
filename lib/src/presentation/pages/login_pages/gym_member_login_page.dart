import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/presentation/pages/common/login_page.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';

class GymMemberLogInPage extends StatelessWidget {
  const GymMemberLogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AppBackGroundPage(
        child: Center(
          child: LoginPage(
            
            route: AppRoutes.memberHomePage,
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.gymMemberSignUpPage,
                      (route) => route.settings.name == AppRoutes.initialPage,
                    );
                  },
          ),
        ),
      ),
    );
  }
}
