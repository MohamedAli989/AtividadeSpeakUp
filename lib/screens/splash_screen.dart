// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
// A navegação usa rotas nomeadas; imports de telas individuais não são
// necessários neste arquivo
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
    // garantir que o provider de usuário carregue os dados em cache
    await ref.read(userProvider.notifier).load();

    // consultar a persistência diretamente para o estado de login (por
    // segurança)
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
