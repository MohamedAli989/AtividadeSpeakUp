import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/3_content/domain/entities/vocabulary_item.dart';

/// Helper que abre o diálogo de ações para um item de vocabulário.
/// Garante `barrierDismissible: false` conforme convenção.
Future<void> showVocabularyActionsDialog(
  BuildContext context, {
  required VocabularyItem item,
  Future<void> Function()? onEdit,
  Future<void> Function()? onRemove,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        VocabularyActionsDialog(item: item, onEdit: onEdit, onRemove: onRemove),
  );
}

/// Diálogo que apresenta ações para um `VocabularyItem`.
///
/// - `onEdit` e `onRemove` são callbacks opcionais que serão chamados quando
///   o usuário confirmar a ação. Recomenda-se que esses callbacks invoquem
///   UseCases/providers via `ref.read(...)` do Riverpod no contexto onde o
///   diálogo for aberto.
class VocabularyActionsDialog extends ConsumerWidget {
  final VocabularyItem item;
  final Future<void> Function()? onEdit;
  final Future<void> Function()? onRemove;

  const VocabularyActionsDialog({
    super.key,
    required this.item,
    this.onEdit,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(item.word),
      content: const Text('Escolha uma ação para este item de vocabulário.'),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            if (onEdit != null) {
              await onEdit!();
            } else {
              // Nenhum callback fornecido — por convenção, o caller deve
              // fornecer um `onEdit` que invoque o UseCase ou abra o formulário.
            }
          },
          child: const Text('Editar'),
        ),
        TextButton(
          onPressed: () async {
            // Fecha o diálogo principal antes da confirmação.
            Navigator.of(context).pop();

            final confirmed = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (c) {
                return AlertDialog(
                  title: const Text('Tem certeza?'),
                  content: const Text(
                    'Deseja apagar esta palavra? Esta ação não pode ser desfeita.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(c).pop(false),
                      child: const Text('Não'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(c).pop(true),
                      child: const Text('Sim'),
                    ),
                  ],
                );
              },
            );

            if (confirmed == true) {
              if (onRemove != null) {
                await onRemove!();
              } else {
                // Nenhum callback de remoção foi passado. Por convenção,
                // o caller deve passar um callback que invoque o UseCase
                // apropriado via `ref.read(...)` do Riverpod.
              }
            }
          },
          child: const Text('Remover'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
