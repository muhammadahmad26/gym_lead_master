import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/constants/app_padding.dart';
import 'package:gym_lead_master/src/core/constants/app_text_size.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/data/model/admin_profile_model.dart';

class HeaderSection extends StatelessWidget {
  final Admin admin;

  const HeaderSection({super.key, required this.admin});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(AppPaddings.large),
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor,
              offset: Offset(2, 2),
              blurRadius: 10,
              spreadRadius: 1,
              blurStyle: BlurStyle.normal,
            ),
          ],
          color: AppColors.DarkBlueGrey,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Image.asset(AppImages.userIcon, fit: BoxFit.contain),
            ),
            const SizedBox(width: AppPaddings.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    admin.name,
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    admin.email,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.BrightBlue.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      admin.role,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
