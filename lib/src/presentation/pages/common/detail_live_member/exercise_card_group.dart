import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/data/gym_members_data.dart';
import 'package:gym_lead_master/src/presentation/pages/common/detail_live_member/exercise_card.dart';

class ExerciseCardsGroup extends StatelessWidget {
  const ExerciseCardsGroup({
    super.key,
    // required this.cardWidth,
    // required this.cardHeight,
    required this.fontSize,
    required this.listImageAddress,
    required this.listExerciseNames,
    required this.gymMembers,
  });

  // final double cardWidth;
  // final double cardHeight;
  final double fontSize;
  final List<String> listImageAddress;
  final List<String> listExerciseNames;
  final GymMembersData gymMembers;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double fontSize = maxWidth * 0.4;
        double cardWidth = maxWidth < 600 ? maxWidth * 0.40 : 190;
        double cardHeight = 60;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: List.generate(6, (index) {
              return SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: ExerciseCard(
                  fontSize: fontSize,
                  imagePath: listImageAddress[index],
                  nameOfExercise: listExerciseNames[index],
                  memberDoingExercise:
                      [
                        gymMembers.membersDoingChestExercise,
                        gymMembers.membersDoingLegExercise,
                        gymMembers.membersDoingTricepsExercise,
                        gymMembers.membersDoingBicepsExercise,
                        gymMembers.membersDoingCardioExercise,
                        gymMembers.membersDoingWeightLossExercise,
                      ][index],
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
