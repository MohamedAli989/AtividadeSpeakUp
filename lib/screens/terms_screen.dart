// lib/screens/terms_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../utils/colors.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  // State for the top-level screen kept minimal; body handled by _TermsBody.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Termos de Uso e LGPD')),
      body: const Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
        child: _TermsBody(),
      ),
    );
  }
}

class _TermsBody extends ConsumerStatefulWidget {
  const _TermsBody({Key? key}) : super(key: key);

  @override
  ConsumerState<_TermsBody> createState() => _TermsBodyState();
}

class _TermsBodyState extends ConsumerState<_TermsBody> {
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
            minimumSize: const Size(double.infinity, 48),
          ),
          onPressed: _termsAccepted
              ? () async {
                  try {
                    await ref
                        .read(userProvider.notifier)
                        .setAcceptedTerms(true);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao salvar aceite: $e')),
                    );
                    return;
                  }

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Termos aceitos com sucesso.'),
                    ),
                  );
                }
              : null,
          child: const Text(
            'Continuar',
            style: TextStyle(fontSize: 18, color: AppColors.textLight),
          ),
        ),
      ],
    );
  }
}
