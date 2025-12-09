import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';


class AppTextStyles {
  static const headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );

  static const headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.onSurface,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.onSurfaceVariant,
  );

  static const labelLarge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );
}
