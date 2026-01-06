import 'package:flutter/foundation.dart'; // kDebugMode 
import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';
import 'package:gym_lead_master/src/core/widgets/app_button.dart';

import 'package:gym_lead_master/main.dart'; 

class InitialPages extends StatelessWidget {
  const InitialPages({super.key});

  @override
  Widget build(BuildContext context) {
    // MediaQuery 
    final Size size = MediaQuery.sizeOf(context);
    final double width = size.width;

    return Scaffold(
      body: AppBackGroundPage(
        child: Stack(
          children: [
            // Main UI Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(AppImages.appLogoIcon, width: 100, height: 100),
                  
                  // Main Heading
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.1,
                      right: width * 0.1,
                      top: width * 0.04,
                      bottom: width * 0.02,
                    ),
                    child: FittedBox(
                      child: Text(
                        "Stay Fit, Stay Organized",
                        style: TextStyle(
                          shadows: const [
                            Shadow(color: AppColors.greyColor, blurRadius: 4),
                          ],
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.1,
                        ),
                      ),
                    ),
                  ),

                  // Subheading
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.1,
                      right: width * 0.1,
                      bottom: width * 0.04,
                    ),
                    child: FittedBox(
                      child: Text(
                        'Helping Gym run smarter & member stay on track',
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: width * 0.05,
                        ),
                      ),
                    ),
                  ),

                  // Gym Admin Button
                  AppButton(
                    text: 'Gym Admin',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.gymAdminLogInPage);
                    },
                  ),

                  SizedBox(height: width * 0.02),

                  // Gym Member Button
                  AppButton(
                    text: "Gym Member",
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.gymMemberLoginPage);
                    },
                  ),

                  SizedBox(height: width * 0.02),

                  // Super Admin Button
                  AppButton(
                    text: "Super Admin",
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.superAdminLoginPage);
                    },
                  ),
                ],
              ),
            ),

            // --- Secret Setup Button (Sirf Debug Mode mein) ---
            if (kDebugMode)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onDoubleTap: () async { // Double tap par rakha hai mazeed safety ke liye
                      await setupSuperAdmin();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("🚀 Super Admin Account Initialized!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: Text(
                      "DEV: Double-tap to setup system",
                      style: TextStyle(
                        color: AppColors.whiteColor.withOpacity(0.2), // Bohat halka dikhega
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
