// lib/core/app/app.dart
// dart:async intentionally omitted (no top-level zones here)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/screens/splash_screen.dart';
import 'package:pprincipal/screens/profile_page.dart';
import 'package:pprincipal/features/4_profile/presentation/pages/user_settings_page.dart';
import 'package:pprincipal/screens/speakup_home_screen.dart';
import 'package:pprincipal/screens/login_screen.dart';
import 'package:pprincipal/screens/privacy_screen.dart';
import 'package:pprincipal/screens/terms_screen.dart';
import 'package:pprincipal/screens/onboarding_screen.dart';
import 'package:pprincipal/providers/accepted_terms_provider.dart';

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

class App extends StatefulWidget {
  const App({super.key, this.navigatorKey});

  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      navigatorKey: widget.navigatorKey,
      title: 'SpeakUp App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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
