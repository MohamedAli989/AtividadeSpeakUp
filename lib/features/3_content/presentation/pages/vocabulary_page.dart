import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/3_content/presentation/providers/vocabulary_providers.dart';
import 'package:pprincipal/features/3_content/presentation/providers/vocabulary_usecase_providers.dart';
import 'package:pprincipal/features/3_content/presentation/widgets/vocabulary_list_item.dart';

class VocabularyPage extends ConsumerWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(vocabularyListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Vocabulários')),
      body: items.isEmpty
          ? const Center(child: Text('Nenhum item de vocabulário.'))
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return VocabularyListItem(
                  item: item,
                  onSave: (updated) async {
                    final salvar = ref.read(salvarVocabularioUseCaseProvider);
                    await salvar(updated);
                  },
                );
              },
            ),
    );
  }
}
