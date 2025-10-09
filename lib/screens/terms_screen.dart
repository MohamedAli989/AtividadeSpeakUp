// lib/screens/terms_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'speakup_home_screen.dart';
import '../utils/colors.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _termsAccepted = false;

  Future<void> _acceptTerms() async {
    if (_termsAccepted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('acceptedTerms', true);
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SpeakUpHomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa aceitar os termos para continuar.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Termos de Uso e LGPD')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Aqui vai o texto completo dos seus Termos de Serviço, Política de Privacidade e conformidade com a LGPD...\n\n' *
                      20,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _termsAccepted,
                  onChanged: (bool? value) =>
                      setState(() => _termsAccepted = value ?? false),
                  activeColor: AppColors.primaryViolet,
                ),
                const Expanded(
                  child: Text(
                    'Eu li e aceito os Termos e a Política de Privacidade.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _acceptTerms,
              child: const Text(
                'Continuar',
                style: TextStyle(fontSize: 18, color: AppColors.textLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
