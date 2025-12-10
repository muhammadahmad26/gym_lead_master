import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';

class AppBackGroundPage extends StatelessWidget {
  final Widget child;
  const AppBackGroundPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.darkBlue,
            AppColors.mediumBlue,
            AppColors.lightBlue,

            AppColors.lightBlueColor,
            AppColors.whiteColor,
          ],
        ),
      ),
      child: child,
    );
  }
}
