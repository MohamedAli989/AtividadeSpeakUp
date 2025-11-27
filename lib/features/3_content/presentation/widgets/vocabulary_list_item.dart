import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/3_content/domain/entities/vocabulary_item.dart';
import 'package:pprincipal/features/3_content/presentation/dialogs/vocabulary_form_dialog.dart';
import 'package:pprincipal/features/3_content/presentation/providers/vocabulary_providers.dart';
import 'package:pprincipal/core/utils/colors.dart';

/// Item de lista que apresenta um `VocabularyItem` e botão de edição.
///
/// O widget não faz persistência por si; recebe um callback `onSave` que
/// deve persistir o item (por exemplo, chamando um UseCase/provider).
class VocabularyListItem extends ConsumerWidget {
  final VocabularyItem item;
  final Future<void> Function(VocabularyItem) onSave;

  const VocabularyListItem({
    super.key,
    required this.item,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Remover palavra?'),
            content: Text("Tem certeza que deseja remover '${item.word}'?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Remover'),
              ),
            ],
          ),
        );

        return result ?? false;
      },
      onDismissed: (direction) {
        // Remove item via provider and show confirmation snackbar.
        ref.read(vocabularyListProvider.notifier).removerItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removido com sucesso.')),
        );
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        title: Text(
          item.word,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(item.translation),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined),
          color: AppColors.primaryBlue,
          onPressed: () async {
            await showVocabularyFormDialog(context, item: item, onSave: onSave);
          },
        ),
      ),
    );
  }
}
