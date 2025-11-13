import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../../utils/colors.dart';

class TermsScreenClean extends ConsumerStatefulWidget {
  const TermsScreenClean({super.key});

  @override
  ConsumerState<TermsScreenClean> createState() => _TermsScreenCleanState();
}

class _TermsScreenCleanState extends ConsumerState<TermsScreenClean> {
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Termos de Uso e LGPD')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
        child: Column(
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
                      final setTerms = ref.read(
                        setTermsAcceptedUsecaseProvider,
                      );
                      try {
                        await setTerms.call(true);
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
        ),
      ),
    );
  }
}
