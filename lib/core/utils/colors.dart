// lib/core/utils/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Semantic palette — vibrant, modern (updated)
  static const Color primary = Color(0xFF6C63FF); // vibrant purple
  static const Color secondary = Color(0xFF58CC02); // vivid green accent
  static const Color background = Color(0xFFF7F9FB); // off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF2ECC71);
  static const Color onPrimary = Colors.white;
  static const Color onSurface = Color(0xFF4B4B4B); // dark grey text

  // Backwards-compatible aliases (older code references)
  static const Color primaryBlue = primary;
  static const Color primaryViolet = primary;
  static const Color primarySlate = onSurface;
  static const Color textLight = onPrimary;

  // Utility greys
  static const Color muted = Color(0xFF9AA4B2);
  static const Color cardShadow = Color(0x0A000000);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C5CF0), Color(0xFF5CC7D6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF6F8FB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
