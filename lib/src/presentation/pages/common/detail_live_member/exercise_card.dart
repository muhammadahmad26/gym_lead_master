import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';

class ExerciseCard extends StatelessWidget {
  final String imagePath;
  final String nameOfExercise;
  final String memberDoingExercise;
  final double fontSize;

  const ExerciseCard({
    super.key,
    required this.imagePath,
    required this.nameOfExercise,
    required this.memberDoingExercise,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightPinkColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(imagePath, width: 30, height: 20),
          ),
          // const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SizedBox(
              // width: 70,
              // height: 40,
              // child:
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text(
                  nameOfExercise,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyColor,
                  ),
                ),
              ),
              // ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memberDoingExercise,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                    ),
                    Text(
                      "  ●",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.themeBlueColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
