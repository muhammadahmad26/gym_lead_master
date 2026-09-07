import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';

class AppBackGroundPage extends StatelessWidget {
  final Widget child;
  const AppBackGroundPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return SizedBox(
      width: size.width,
      height: size.height,

      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBlue,
              AppColors.mediumBlue,
              AppColors.lightBlue,

              Color.fromARGB(255, 150, 179, 218),
              Color.fromARGB(255, 198, 218, 245),
            ],
          ),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}
