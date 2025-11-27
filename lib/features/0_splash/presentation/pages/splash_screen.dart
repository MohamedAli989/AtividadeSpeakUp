// lib/features/0_splash/presentation/pages/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/4_profile/presentation/providers/user_provider.dart';
import 'package:pprincipal/features/2_auth/presentation/providers/auth_providers.dart';
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
    // Load user state and trigger the app status check.
    // It's safe to call provider reads in initState; navigation happens after
    // async operations and checks for `mounted` before using `context`.
    ref.read(userProvider.notifier).load();

    // Trigger the verificarStatusAppUseCaseProvider and navigate when it completes.
    () async {
      try {
        final route = await ref.read(verificarStatusAppUseCaseProvider.future);
        // Keep splash visible briefly
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(route);
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }();
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
