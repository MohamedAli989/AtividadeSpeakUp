import 'package:flutter/material.dart';
import 'package:pprincipal/features/3_content/presentation/dialogs/provider_form_dialog_clean.dart';

/// Widget pequeno que exibe um ícone de lápis e abre o diálogo de edição.
///
/// - [initialValues]: mapa com os campos iniciais que serão pré-preenchidos.
/// - [onSave]: callback que será chamado com os valores atualizados. Deve
///   executar a persistência (UseCase/DAO) e pode lançar em caso de erro.
class ProviderEditIcon extends StatelessWidget {
  final Map<String, String?> initialValues;
  final Future<void> Function(Map<String, String?> values) onSave;

  const ProviderEditIcon({
    super.key,
    required this.initialValues,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit, size: 20),
      tooltip: 'Editar',
      onPressed: () async {
        await showProviderFormDialogClean(
          context,
          initialValues: initialValues,
          onSave: onSave,
        );
      },
    );
  }
}
