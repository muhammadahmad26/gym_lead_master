import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/admin_main_page.dart';
import 'package:gym_lead_master/src/presentation/pages/initial_pages.dart';
import 'package:gym_lead_master/src/presentation/pages/member_home_page/memeber_home_page.dart';
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

      // home: InitialPages(),
      home: adminHomePage(),
      // home: MemeberHomePage(),
      // home: GymAdminLoginPage(),
      // home: GymAdminSignupPage(),
    );
  }
}
