import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/core/services/persistence_service.dart';

class ThemeNotifier extends StateNotifier<Color> {
  ThemeNotifier() : super(Colors.deepPurple) {
    _load();
  }

  Future<void> _load() async {
    try {
      final val = await PersistenceService().getAppPalette();
      if (val != null) state = Color(val);
    } catch (_) {}
  }

  Future<void> setPalette(Color color) async {
    state = color;
    try {
      await PersistenceService().setAppPalette(color.toARGB32());
    } catch (_) {}
  }

  Future<void> clearPalette() async {
    state = Colors.deepPurple;
    try {
      await PersistenceService().removeAppPalette();
    } catch (_) {}
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, Color>((ref) {
  return ThemeNotifier();
});
