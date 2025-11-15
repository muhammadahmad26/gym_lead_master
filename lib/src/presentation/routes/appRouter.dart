import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_main_page.dart';
import 'package:gym_lead_master/src/presentation/pages/login_pages/gym_admin_login_page.dart';
import 'package:gym_lead_master/src/presentation/pages/login_pages/gym_member_login_page.dart';
import 'package:gym_lead_master/src/presentation/pages/initial_pages.dart';
import 'package:gym_lead_master/src/presentation/pages/signUp_page/gym_Admin_signUp_Page.dart';
import 'package:gym_lead_master/src/presentation/pages/signUp_page/gym_member_sigUp_page.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.initialPage:
        return MaterialPageRoute(builder: (_) => InitialPages());
      case AppRoutes.gymAdminLogInPage:
        return MaterialPageRoute(builder: (_) => GymAdminLoginPage());
      case AppRoutes.gymMemberLoginPage:
        return MaterialPageRoute(builder: (_) => GymMemberLogInPage());
      case AppRoutes.gymAdminSignUpPage:
        return MaterialPageRoute(builder: (_) => GymAdminSignupPage());
      case AppRoutes.gymMemberSignUpPage:
        return MaterialPageRoute(builder: (_) => GymMemberSignUpPage());
      case AppRoutes.adminHomePage:
        return MaterialPageRoute(builder: (_) => adminHomePage());
      default:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text("404 - Page Not Found")),
              ),
        );
    }
  }
}
