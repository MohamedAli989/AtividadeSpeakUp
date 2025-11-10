// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'terms_screen.dart';
import '../utils/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  double _paginaAtual = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _paginaAtual = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completarOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const TermsScreen()));
  }

  Widget _construirPaginaOnboarding(
    String titulo,
    String subtitulo,
    IconData icone,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icone, color: AppColors.primaryViolet, size: 100),
        const SizedBox(height: 40),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primarySlate,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          subtitulo,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                children: [
                  _construirPaginaOnboarding(
                    'Bem-vindo ao SpeakUp!',
                    'Treine sua fala e melhore sua pronúncia com frases guiadas.',
                    Icons.translate,
                  ),
                  _construirPaginaOnboarding(
                    'Como Funciona?',
                    '1. Oiça. 2. Grave. 3. Receba feedback.',
                    Icons.hearing,
                  ),
                  _construirPaginaOnboarding(
                    'Crie uma meta!',
                    'Pratique 10 minutos por dia.',
                    Icons.flag,
                  ),
                ],
              ),
            ),
            DotsIndicator(
              dotsCount: 3,
              position: _paginaAtual,
              decorator: DotsDecorator(activeColor: AppColors.primaryBlue),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_paginaAtual < 2) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  } else {
                    _completarOnboarding();
                  }
                },
                child: Text(
                  _paginaAtual < 2 ? 'Continuar' : 'Finalizar',
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
