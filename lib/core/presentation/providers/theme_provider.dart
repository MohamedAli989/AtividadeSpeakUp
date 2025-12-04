import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/core/services/persistence_service.dart';

class AppThemeState {
  final ThemeMode mode;
  final Color seedColor;

  const AppThemeState({
    this.mode = ThemeMode.system,
    this.seedColor = Colors.deepPurple,
  });

  AppThemeState copyWith({ThemeMode? mode, Color? seedColor}) {
    return AppThemeState(
      mode: mode ?? this.mode,
      seedColor: seedColor ?? this.seedColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AppThemeState &&
            other.mode == mode &&
            other.seedColor == seedColor);
  }

  @override
  int get hashCode => Object.hash(mode, seedColor);
}

class ThemeNotifier extends StateNotifier<AppThemeState> {
  ThemeNotifier() : super(const AppThemeState()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final val = await PersistenceService().getThemeMode();
      ThemeMode mode;
      if (val == 'light') {
        mode = ThemeMode.light;
      } else if (val == 'dark') {
        mode = ThemeMode.dark;
      } else {
        mode = ThemeMode.system;
      }

      final pal = await PersistenceService().getAppPalette();
      final seed = pal != null ? Color(pal) : Colors.deepPurple;
      state = AppThemeState(mode: mode, seedColor: seed);
    } catch (_) {
      state = const AppThemeState();
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    try {
      final s = mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
          ? 'dark'
          : 'system';
      await PersistenceService().setThemeMode(s);
    } catch (_) {}
  }

  Future<void> setColor(Color color) async {
    state = state.copyWith(seedColor: color);
    try {
      await PersistenceService().setAppPalette(color.toARGB32());
    } catch (_) {}
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeState>((
  ref,
) {
  return ThemeNotifier();
});
