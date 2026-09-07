import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:gym_lead_master/firebase_options.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/admin_main_page.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/payment_page/admin_pyment_page.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/admin_profile_page.dart';
import 'package:gym_lead_master/src/presentation/pages/common/profile_page/profile_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/common/signUp_page.dart';

import 'package:gym_lead_master/src/presentation/pages/splash_page/initial_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_chat_page/member_massage_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_home_page/member_home_page.dart';
import 'package:gym_lead_master/src/presentation/routes/appRouter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );
  }

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
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
      builder: (context, child) {
        
        if (!kIsWeb) return child!;

        return LayoutBuilder(
          builder: (context, constraints) {
            const double maxPhoneWidth = 480;
            double effectiveWidth =
                constraints.maxWidth < maxPhoneWidth
                    ? constraints.maxWidth
                    : maxPhoneWidth;

            return Container(
              color: const Color(0xFFEDEDED),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxPhoneWidth),
                  child: MediaQuery(
                    
                    data: MediaQuery.of(context).copyWith(
                      size: Size(effectiveWidth, constraints.maxHeight),
                    ),
                    child: Material(elevation: 8, child: child),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
