// lib/core/utils/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF58CC02);
  static const Color primaryDark = Color(0xFF46A302);
  static const Color secondary = Color(0xFFCE82FF);
  static const Color accent = Color(0xFF1CB0F6);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F9FA);
  static const Color textPrimary = Color(0xFF4B4B4B);
  static const Color textSecondary = Color(0xFF777777);
  static const Color error = Color(0xFFFF4B4B);
  static const Color neutralBorder = Color(0xFFE5E5E5);

  // Backwards-compatible aliases for existing code that referenced older names
  static const Color primaryBlue = primary;
  static const Color primaryViolet = secondary;
  static const Color primarySlate = textPrimary;
  static const Color textLight = Colors.white;
}
