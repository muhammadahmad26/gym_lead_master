import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/widgets/app_button.dart';
import 'package:gym_lead_master/src/data/model/gym_members_data.dart';
import 'package:gym_lead_master/src/presentation/pages/common/detail_live_member/exercise_card_group.dart';
import 'package:gym_lead_master/src/presentation/pages/common/detail_live_member/live_total_members_number.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key, required this.isAdmin});
  final bool isAdmin;

  static List<String> listImageAddress = [
    "assets/images/chest_home.png",
    "assets/images/leg_home.png",
    "assets/images/triceps_home.png",
    "assets/images/chest_home.png",
    "assets/images/cardio_home.png",
    "assets/images/weightloss_home.png",
  ];
  static List<String> listExerciseNames = [
    "Chest",
    "Leg",
    "Triceps",
    "Biceps",
    "Cardio",
    "Weight loss",
  ];

  @override
  Widget build(BuildContext context) {
    final GymMembersData gymMembers = GymMembersData(
      totalMembers: "100",
      membersDoingBicepsExercise: "10",
      membersDoingCardioExercise: "20",
      membersDoingChestExercise: "15",
      membersDoingLegExercise: "20",
      membersDoingTricepsExercise: "15",
      membersDoingWeightLossExercise: "30",
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          double fontSize = maxWidth * 0.4;

          return AppBackGroundPage(
            child: Center(
              child: Column(
                children: [
                  const Spacer(),
                  FractionallySizedBox(
                    widthFactor: 0.2,
                    child: Image.asset(
                      AppImages.appLogoIcon,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Pro Fitness Gym",
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize.clamp(20, 25),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(flex: 1),
                  LiveTotalMembersNumber(
                    gymMembers: gymMembers,
                    fontSize: fontSize,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Live Gym Members",
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize.clamp(16, 28),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  ExerciseCardsGroup(
                    fontSize: fontSize,
                    listImageAddress: listImageAddress,
                    listExerciseNames: listExerciseNames,
                    gymMembers: gymMembers,
                  ),

                  const Spacer(),

                  if (isAdmin)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AppButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.checkInPage);
                        },
                        text: "Check In",
                      ),
                    ),

                  const Spacer(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
