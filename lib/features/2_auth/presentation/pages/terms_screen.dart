// lib/features/2_auth/presentation/pages/terms_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/providers/accepted_terms_provider.dart';
import 'package:pprincipal/core/utils/colors.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
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
  const _TermsBody();

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
                  final messenger = ScaffoldMessenger.of(context);
                  final notifier = ref.read(acceptedTermsProvider.notifier);
                  try {
                    await notifier.setAccepted(true);
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Erro ao salvar aceite: $e')),
                    );
                    return;
                  }

                  messenger.showSnackBar(
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
