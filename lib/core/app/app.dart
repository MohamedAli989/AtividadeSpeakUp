// lib/core/app/app.dart
// dart:async intentionally omitted (no top-level zones here)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pprincipal/core/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/0_splash/presentation/pages/splash_screen.dart';
import 'package:pprincipal/features/4_profile/presentation/pages/profile_page.dart';
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
    final baseText = GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme);

    final app = MaterialApp(
      navigatorKey: widget.navigatorKey,
      title: 'SpeakUp App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.surface,
        textTheme: baseText.copyWith(
          bodyMedium: baseText.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.neutralBorder, width: 2),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/profile': (context) => const ProfilePage(),
        '/user_settings': (context) => const UserSettingsPage(),
        '/home': (context) => const SpeakUpHomeScreen(),
        '/privacy': (context) => const PrivacyScreen(),
        '/terms': (context) => const TermsScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );

    try {
      ProviderScope.containerOf(context);
      return app;
    } catch (_) {
      return ProviderScope(child: app);
    }
  }
}
