import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_padding.dart';
import 'package:gym_lead_master/src/core/constants/app_text_size.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/data/model/gym_status_model.dart';

class GymStatsCard extends StatelessWidget {
  final GymStats stats;

  const GymStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppPaddings.medium),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.medium),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total Members', stats.totalMembers.toString()),
            _buildStatItem('Active', stats.activeMembers.toString()),
            _buildStatItem('Trainers', stats.trainers.toString()),
            _buildStatItem('Check-ins', stats.checkIns.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}