import 'package:flutter/material.dart';
import 'package:lingolearn/utilities/theme/smooth_rectangular_border.dart';

class AppBoxDecoration {
  static BoxDecoration getBoxDecoration({
    double borderRadius = 10,
    Color color = Colors.white,
    double spreadRadius = 0,
    double blurRadius = 20,
    bool showShadow = true,
    BoxBorder? border,
  }) {
    return BoxDecoration(
      borderRadius: SmoothBorderRadius(
        cornerRadius: borderRadius,
        cornerSmoothing: 10,
      ),
      border: border,
      color: color,
      boxShadow: showShadow == true
          ? [
              BoxShadow(
                spreadRadius: spreadRadius,
                blurRadius: blurRadius,
                color: Colors.black.withValues(alpha: 0.06),
                offset: const Offset(0, 4),
              ),
            ]
          : [],
    );
  }
}
