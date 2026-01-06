import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/firebase_options.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/active_member_list_page.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/admin_main_page.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/admin_message_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/common/forget_password_page.dart';
import 'package:gym_lead_master/src/presentation/pages/common/login_page.dart';
import 'package:gym_lead_master/src/presentation/pages/initial_pages.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_home_page/member_home_page.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_payment_page/data/member_dummy_trainstion_data/member_dummy_data.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_payment_page/member_payment_page.dart';
import 'package:gym_lead_master/src/presentation/pages/super_admin_pages/data/services/super_admin_service.dart';

import 'package:gym_lead_master/src/presentation/routes/appRouter.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );
    await connectToFirebaseEmulator();
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
      onGenerateRoute: AppRouter.generateRoute,

      home: InitialPages(),
      // home: SuperAdminDashboard(),
    );
  }
}

//---Connect to Firebase Emulators for Firestore, Auth, and Storage--//

Future<void> connectToFirebaseEmulator() async {
  String host = 'localhost'; // Default for iOS Simulator & Web

  if (!kIsWeb) {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.isPhysicalDevice) {
        // *IMPORTANT*: Yahan apna laptop ka IP address likho
        // Kyunke real phone ko laptop ka pata nahi hota
        host = '192.168.1.40';
      } else {
        // Android Emulator ka internal address
        host = '10.0.2.2';
      }
    }
  }

  // Ab sab services ko connect karo
  try {
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);

    await FirebaseStorage.instance.useStorageEmulator(host, 9199);
    print("Connected to Firebase Emulator on: $host");
  } catch (e) {
    print("Emulator connection error: $e");
  }
}

//--- Super Admin Setup Function --//

Future<void> setupSuperAdmin() async {
  final superAdminService = SuperAdminService();

  try {
    await superAdminService.initializeSuperAdmin(
      email: 'superadmin@email.com',
      password: 'SuperSecure@123',
      name: 'Master Administrator',
    );
    print('✅ Super Admin created successfully');
  } catch (e) {
    print('❌ Error: $e');
  }
}
