// lib/features/0_splash/presentation/pages/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/providers/user_provider.dart';
import 'package:pprincipal/core/services/persistence_service.dart';
import 'package:pprincipal/core/utils/colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    try {
      debugPrint('splash: _checkFirstRun start');
      final seenOnboarding = await ref
          .read(userProvider.notifier)
          .getSeenOnboarding();
      debugPrint('splash: seenOnboarding = $seenOnboarding');

      final acceptedTerms = await ref
          .read(userProvider.notifier)
          .getAcceptedTerms();
      debugPrint('splash: acceptedTerms = $acceptedTerms');

      debugPrint('splash: calling userProvider.load()');
      await ref.read(userProvider.notifier).load();
      debugPrint('splash: userProvider.load() completed');

      final loggedIn = await PersistenceService().isLoggedIn();
      debugPrint('splash: loggedIn = $loggedIn');

      // Pequena espera para manter o splash visível
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) {
        debugPrint('splash: widget not mounted, aborting navigation');
        return;
      }

      final targetRoute = !seenOnboarding
          ? '/onboarding'
          : (!acceptedTerms ? '/terms' : (!loggedIn ? '/login' : '/home'));
      debugPrint('splash: navigating to $targetRoute');
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(targetRoute);
    } catch (e, st) {
      debugPrint('splash: exception in _checkFirstRun: $e');
      debugPrint(st.toString());
      // Em caso de erro, navegar para tela de erro mínima ou login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primarySlate,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_rounded, color: AppColors.primaryViolet, size: 80),
            SizedBox(height: 20),
            Text(
              'SpeakUp',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
