import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/3_content/domain/entities/vocabulary_item.dart';
import 'package:pprincipal/features/3_content/presentation/dialogs/vocabulary_form_dialog.dart';
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
    return ListTile(
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
    );
  }
}
