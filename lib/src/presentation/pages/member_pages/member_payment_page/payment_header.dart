import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_padding.dart';
import 'package:gym_lead_master/src/core/constants/app_text_size.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_payment_page/data/model/member_detail.dart';

class PaymentHeader extends StatelessWidget {
  final Member member;

  const PaymentHeader({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppPaddings.large),
      decoration: const BoxDecoration(
        color: AppColors.DarkBlueGrey,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(member.imageUrl),
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: AppPaddings.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${member.membershipId}',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  'Plan: ${member.membershipType}',
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


