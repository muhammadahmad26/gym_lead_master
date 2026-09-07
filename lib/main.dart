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
    // await connectToFirebaseEmulator();
  }

  runApp(const MyApp());
}

//---Connect to Firebase Emulators for Firestore, Auth, and Storage--//
// Future<void> connectToFirebaseEmulator() async {
//   String host = 'localhost';

//   if (!kIsWeb) {
//     if (Platform.isAndroid) {
//       DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//       AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//       if (androidInfo.isPhysicalDevice) {
//         host = '192.168.1.40';
//       } else {
//         host = '10.0.2.2';
//       }
//     }
//   }

//   try {
//     await FirebaseAuth.instance.useAuthEmulator(host, 9099);
//     FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
//     await FirebaseStorage.instance.useStorageEmulator(host, 9199);
//     debugPrint("Connected to Firebase Emulator on: $host");
//   } catch (e) {
//     debugPrint("Emulator connection error: $e");
//   }
// }

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
        // This app is designed for phone-width screens. On the web build,
        // a wide desktop/laptop browser window would otherwise stretch
        // every Row/layout far beyond what it was designed for, causing
        // overflow and odd spacing. Keep it phone-width and centered on
        // wide screens instead — the same pattern WhatsApp Web etc. use.
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
                    // Also override the reported size, so any screen doing
                    // its own MediaQuery.of(context).size.width math (chat
                    // bubble widths, responsive helpers) sees the phone
                    // width too, not the raw browser window width.
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
