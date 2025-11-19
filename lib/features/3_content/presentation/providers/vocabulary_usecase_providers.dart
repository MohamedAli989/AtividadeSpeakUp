import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/3_content/domain/entities/vocabulary_item.dart';
import 'package:pprincipal/features/3_content/presentation/providers/vocabulary_providers.dart';

/// UseCase-style provider that exposes a `Future<void> Function(VocabularyItem)`
/// to save a vocabulary item. Internally delegates to the notifier used in
/// the demo provider. This lets presentation code depend on a UseCase API.
final salvarVocabularioUseCaseProvider =
    Provider<Future<void> Function(VocabularyItem)>((ref) {
      return (VocabularyItem item) async {
        await ref.read(vocabularyListProvider.notifier).salvarItem(item);
      };
    });
