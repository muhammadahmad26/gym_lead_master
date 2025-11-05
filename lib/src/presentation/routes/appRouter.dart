import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/pages/gymAdminPage.dart';
import 'package:gym_lead_master/src/presentation/pages/gymMemberPage.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.GymAdmin:
        return MaterialPageRoute(builder: (_) => GymAdminPage());
      case AppRoutes.GymMember:
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
