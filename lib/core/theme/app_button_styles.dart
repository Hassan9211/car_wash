import 'package:car_wash/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppButtonStyles {
  AppButtonStyles._();

  static const double borderRadius = 8;
  static const double primaryHeight = 46;

  static ButtonStyle filled({
    Color backgroundColor = AppColors.brandGreen,
    Color foregroundColor = Colors.white,
    double height = primaryHeight,
    BorderSide? side,
  }) {
    return FilledButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      minimumSize: Size.fromHeight(height),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 0,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      side: side,
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.white.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.hovered)) {
          return Colors.white.withValues(alpha: 0.05);
        }
        return null;
      }),
    );
  }

  static ButtonStyle outlined({
    Color foregroundColor = AppColors.brandGreen,
    Color borderColor = AppColors.border,
    double height = primaryHeight,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: foregroundColor,
      minimumSize: Size.fromHeight(height),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: borderColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return foregroundColor.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.hovered)) {
          return foregroundColor.withValues(alpha: 0.05);
        }
        return null;
      }),
    );
  }
}
