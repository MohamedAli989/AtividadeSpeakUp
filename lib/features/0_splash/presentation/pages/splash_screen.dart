// lib/features/0_splash/presentation/pages/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/providers/user_provider.dart';
import 'package:pprincipal/services/persistence_service.dart';
import 'package:pprincipal/utils/colors.dart';

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
    await ref.read(userProvider.notifier).load();
    final loggedIn = await PersistenceService().isLoggedIn();
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
