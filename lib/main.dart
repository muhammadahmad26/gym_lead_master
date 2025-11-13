import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/pages/common/signUp_page.dart';
import 'package:gym_lead_master/src/presentation/pages/login_pages/gym_admin_login_page.dart';
import 'package:gym_lead_master/src/presentation/pages/initial_pages.dart';
import 'package:gym_lead_master/src/presentation/pages/signUp_page/gym_Admin_signUp_Page.dart';
import 'package:gym_lead_master/src/presentation/routes/appRouter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GYM Lead Master',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      onGenerateRoute: AppRouter.generateRoute,
      
      home: InitialPages(),
      // home: GymAdminLoginPage(),
      // home: GymAdminSignupPage(),
    );
  }
}
