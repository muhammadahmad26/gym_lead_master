import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/pages/login_pages/gymAdminLoginPage.dart';
import 'package:gym_lead_master/src/presentation/pages/login_pages/gymMemberLoginPage.dart';
import 'package:gym_lead_master/src/presentation/pages/initial_pages.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.initialPage:
        return MaterialPageRoute(builder: (_) => InitialPages());
      case AppRoutes.gymAdmin:
        return MaterialPageRoute(builder: (_) => GymAdminLoginPage());
      case AppRoutes.gymMember:
        return MaterialPageRoute(builder: (_) => GymMemberPage());

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
