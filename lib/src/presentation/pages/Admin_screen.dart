import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/widgets/app_button.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size(:width, :height) = MediaQuery.sizeOf(context);
    return AppBackGroundPage(
      child: Center(
        child: Column(
          children: [
            // Spacer(),
            SizedBox(height: height * 0.02),
            Image.asset(
              AppImages.appLogoIcon,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(height: height * 0.02),
            Text(
              "Pro Fitness Gym",
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                shadows: [
                  const Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 2,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.02),
            Text(
              "Live Gym Members",
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                shadows: [
                  const Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 6,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.02),
            AppButton(text: "Check In", onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
