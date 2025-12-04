// lib/core/app/app.dart
// ignore_for_file: deprecated_member_use
// dart:async intentionally omitted (no top-level zones here)
import 'package:flutter/material.dart';
import 'package:pprincipal/core/utils/colors.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:pprincipal/core/presentation/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/0_splash/presentation/pages/splash_screen.dart';
import 'package:pprincipal/features/4_profile/presentation/pages/profile_page.dart';
import 'package:pprincipal/features/4_profile/presentation/pages/settings_screen.dart';
import 'package:pprincipal/features/4_profile/presentation/pages/profile_edit_page.dart';
import 'package:pprincipal/features/4_profile/presentation/pages/user_settings_page.dart';
import 'package:pprincipal/features/3_content/presentation/pages/speakup_home_screen.dart';
import 'package:pprincipal/features/2_auth/presentation/pages/login_screen.dart';
import 'package:pprincipal/features/4_profile/presentation/pages/privacy_screen.dart';
import 'package:pprincipal/features/2_auth/presentation/pages/terms_screen.dart';
import 'package:pprincipal/features/1_onboarding/presentation/pages/onboarding_screen.dart';
import 'package:pprincipal/features/2_auth/presentation/providers/accepted_terms_provider.dart';
// theme_provider is intentionally not required for the static design-system theme

/// Conteúdo movido de `lib/main.dart`.
/// Renomeado `MyApp` -> `App`.

/// Aplicação de topo que inclui listeners do Riverpod e um Navigator.
class AppWithProviders extends ConsumerStatefulWidget {
  const AppWithProviders({super.key});

  @override
  ConsumerState<AppWithProviders> createState() => _AppWithProvidersState();
}

class _AppWithProvidersState extends ConsumerState<AppWithProviders> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(acceptedTermsProvider, (previous, next) {
      if (next == true) {
        _navigatorKey.currentState?.pushReplacementNamed('/home');
      }
    });

    return App(navigatorKey: _navigatorKey);
  }
}

class App extends ConsumerStatefulWidget {
  const App({super.key, this.navigatorKey});

  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);

    final lightTheme = _buildTheme(Brightness.light, themeState.seedColor);
    final darkTheme = _buildTheme(Brightness.dark, themeState.seedColor);

    final app = AnimatedTheme(
      data: themeState.mode == ThemeMode.dark ? darkTheme : lightTheme,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOut,
      child: MaterialApp(
        navigatorKey: widget.navigatorKey,
        title: 'SpeakUp App',
        debugShowCheckedModeBanner: false,
        themeMode: themeState.mode,
        theme: lightTheme,
        darkTheme: darkTheme,

        home: const SplashScreen(),
        routes: {
          '/profile': (context) => const ProfilePage(),
          '/profile_edit': (context) => const ProfileEditPage(),
          '/settings': (context) => const SettingsScreen(),
          '/user_settings': (context) => const UserSettingsPage(),
          '/home': (context) => const SpeakUpHomeScreen(),
          '/privacy': (context) => const PrivacyScreen(),
          '/terms': (context) => const TermsScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );

    return app;
  }

  ThemeData _buildTheme(Brightness brightness, [Color? seedColor]) {
    final seed = seedColor ?? AppPalettes.light['primary'] as Color;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme.copyWith(error: AppColors.error),
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Lightweight wrapper to avoid importing material_color_utilities in multiple files.
  CorePalette corePaletteFromSeed(int seed) {
    // Lazy import to keep binary size minimal in analysis; import here.
    // Using material_color_utilities to generate a CorePalette.
    return CorePalette.of(seed);
  }
}
