// lib/core/utils/color_utils.dart
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

extension ColorUtils on Color {
  /// Return color as 32-bit ARGB integer for persistence.
  int toARGB32() => value;

  /// Create a Color from a 32-bit ARGB integer.
  static Color fromARGB32(int v) => Color(v);
}
