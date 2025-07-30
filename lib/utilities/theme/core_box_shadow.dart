import 'package:flutter/material.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

class AppBoxShadow {
  static List<BoxShadow> legacyShadow = [
    const BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 10,
      color: AppColors.black04,
    )
  ];

  static List<BoxShadow> mainBoxShadow = [
    const BoxShadow(
      offset: Offset(4, 8),
      blurRadius: 24,
      color: AppColors.black04,
    )
  ];

  static List<BoxShadow> mainButtonShadow = [
    BoxShadow(
      offset: const Offset(4, 8),
      blurRadius: 24,
      color: AppColors.primaryColor.withOpacity(0.25),
    )
  ];

  static List<BoxShadow> calculatorShadow = const [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 10,
      color: AppColors.black04,
    )
  ];
}
