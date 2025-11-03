import 'package:flutter/material.dart';

class AppColors {
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Background Colors
  static Color background(BuildContext context) {
    return isDark(context) ? Colors.black : const Color(0xFFF5F5F5);
  }

  static Color cardBackground(BuildContext context) {
    return isDark(context) ? const Color(0xFF1A1A1A) : Colors.white;
  }

  static Color cardBorder(BuildContext context) {
    return isDark(context) ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);
  }

  static Color inputBackground(BuildContext context) {
    return isDark(context) ? const Color(0xFF262626) : const Color(0xFFF0F0F0);
  }

  // Text Colors
  static Color primaryText(BuildContext context) {
    return isDark(context) ? Colors.white : Colors.black;
  }

  static Color secondaryText(BuildContext context) {
    return isDark(context) ? const Color(0xFF9E9E9E) : const Color(0xFF616161);
  }

  static Color tertiaryText(BuildContext context) {
    return isDark(context) ? const Color(0xFF616161) : const Color(0xFF9E9E9E);
  }

  // Accent Colors (tetap sama di dark/light)
  static const Color green = Color(0xFF8BC34A);
  static const Color lightGreen = Color(0xFFCDDC39);
  static const Color blue = Color(0xFF03A9F4);
  static const Color red = Color(0xFFFF6B6B);
  static const Color orange = Color(0xFFFF9800);
  static const Color purple = Color(0xFFAA96DA);

  // Icon Colors
  static Color iconColor(BuildContext context) {
    return isDark(context) ? Colors.white : Colors.black;
  }

  static Color iconColorSecondary(BuildContext context) {
    return isDark(context) ? const Color(0xFF9E9E9E) : const Color(0xFF616161);
  }
}