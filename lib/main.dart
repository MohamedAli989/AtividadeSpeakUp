// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/profile_page.dart';
import 'screens/speakup_home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/onboarding_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/accepted_terms_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AppWithProviders()));
}

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
    // Escuta a aceitação dos termos e navega quando aceito. Este código fica
    // dentro de um Consumer para só rodar quando um ProviderScope estiver
    // presente (isto é, no app real). Testes que usam `MyApp` diretamente
    // não precisam do ProviderScope.
    ref.listen<bool>(acceptedTermsProvider, (previous, next) {
      if (next == true) {
        _navigatorKey.currentState?.pushReplacementNamed('/home');
      }
    });

    return MyApp(navigatorKey: _navigatorKey);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.navigatorKey});

  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
      // O ponto de entrada do app agora é a nossa SplashScreen
      home: const SplashScreen(),
      routes: {
        '/profile': (context) => const ProfilePage(),
        '/home': (context) => const SpeakUpHomeScreen(),
        '/privacy': (context) => const PrivacyScreen(),
        '/terms': (context) => const TermsScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );

    // Se não houver um ProviderScope acima (por exemplo, testes que fazem
    // pump de `MyApp` diretamente), envolve o MaterialApp em um ProviderScope
    // para que widgets Consumer possam ler providers com segurança.
    try {
      // Isto lança se não existir um ProviderScope ancestral.
      ProviderScope.containerOf(context);
      return app;
    } catch (_) {
      return ProviderScope(child: app);
    }
  }
}
