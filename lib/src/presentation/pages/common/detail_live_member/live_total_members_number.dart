import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/data/gym_members_data.dart';

class LiveTotalMembersNumber extends StatelessWidget {
  const LiveTotalMembersNumber({
    super.key,
    required this.gymMembers,
    required this.fontSize,
  });

  final GymMembersData gymMembers;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.whiteColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          gymMembers.totalMembers,
          style: TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSize.clamp(20, 40),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
