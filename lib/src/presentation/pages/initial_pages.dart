import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';
import 'package:gym_lead_master/src/presentation/widgets/app_button.dart';

class InitialPages extends StatelessWidget {
  const InitialPages({super.key});

  @override
  Widget build(BuildContext context) {
    final Size(:width, :height) = MediaQuery.sizeOf(context);
    return Scaffold(
      body: AppBackGroundPage(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/app_main_logo.png",
                width: 100,
                height: 100,
              ),
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
                        Shadow(
                          color: AppColors.greyColor,
                          offset: Offset(1, 4),
                        ),
                      ],
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.1,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: width * 0.1,
                  right: width * 0.1,
                  bottom: width * 0.04,
                ),
                child: FittedBox(
                  child: Text(
                    'Helping Gym run smarter & memeber stay on track',
                    style: TextStyle(
                      shadows: const [
                        Shadow(
                          color: AppColors.whiteColor,
                          offset: Offset(1, 1),
                        ),
                      ],
                      color: AppColors.themeBlueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.05,
                    ),
                  ),
                ),
              ),
              AppButton(
                text: ('Gym Admin'),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.gymAdmin);
                },
              ),
              SizedBox(height: width * 0.02),
              AppButton(
                text: "Gym Member",
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.gymMember);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
