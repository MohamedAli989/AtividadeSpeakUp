// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
// Navigation uses named routes; individual screen imports not required here
import '../services/persistence_service.dart';
import '../utils/colors.dart';

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
    final seenOnboarding = await ref
        .read(userProvider.notifier)
        .getSeenOnboarding();
    final acceptedTerms = await ref
        .read(userProvider.notifier)
        .getAcceptedTerms();
    // ensure user provider loads cached data
    await ref.read(userProvider.notifier).load();

    // consult persistence directly for login state for safety
    final loggedIn = await PersistenceService().isLoggedIn();

    // Aguarda um pouco para a splash screen ser visível
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final targetRoute = !seenOnboarding
        ? '/onboarding'
        : (!acceptedTerms ? '/terms' : (!loggedIn ? '/login' : '/home'));

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(targetRoute);
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
