import 'package:flutter/material.dart';

class AppResponsive {
  /// Get font size that scales with screen width
  /// Base design width: 400px (standard mobile)
  static double fontSize(BuildContext context, double baseSize) {
    double width = MediaQuery.of(context).size.width;
    // Scale factor: on 400px width = 1.0, on 200px = 0.5, on 600px = 1.5
    double scale = width / 400;
    // Clamp between 0.7 and 1.4 to prevent extreme sizes
    scale = scale.clamp(0.7, 1.4);
    return baseSize * scale;
  }

  /// Get padding that scales with screen width
  static double padding(BuildContext context, double basePadding) {
    double width = MediaQuery.of(context).size.width;
    double scale = width / 400;
    scale = scale.clamp(0.7, 1.4);
    return basePadding * scale;
  }

  /// Get icon size that scales
  static double iconSize(BuildContext context, double baseSize) {
    double width = MediaQuery.of(context).size.width;
    double scale = width / 400;
    scale = scale.clamp(0.7, 1.4);
    return baseSize * scale;
  }

  /// Responsive text style
  static TextStyle textStyle(
    BuildContext context, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontSize: AppResponsive.fontSize(context, fontSize),
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  /// Check if screen is small (below 360px width)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  /// Check if screen is tablet
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }
}