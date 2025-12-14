import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/firebase_options.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/active_member_list_page.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/admin_main_page.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/admin_message_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/common/login_page.dart';
import 'package:gym_lead_master/src/presentation/pages/initial_pages.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_home_page.dart';
import 'package:gym_lead_master/src/presentation/routes/appRouter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      // home: adminHomePage(),
      // home: MemeberHomePage(),
      // home: ActiveMemberListPage(),
      // home: AdminMessageScreen(),
      // home: GymAdminLoginPage(),
      // home: GymAdminSignupPage(),
      home: InitialPages(),
    );
  }
}
