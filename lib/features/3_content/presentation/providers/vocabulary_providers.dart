// Simple in-memory vocabulary provider for demonstration
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/3_content/domain/entities/vocabulary_item.dart';

final vocabularyListProvider =
    StateNotifierProvider<VocabularyListNotifier, List<VocabularyItem>>(
      (ref) => VocabularyListNotifier(),
    );

class VocabularyListNotifier extends StateNotifier<List<VocabularyItem>> {
  VocabularyListNotifier()
    : super([
        const VocabularyItem(
          id: '1',
          userId: 'u1',
          word: 'hello',
          translation: 'olá',
          originalPhraseId: 'p1',
        ),
        const VocabularyItem(
          id: '2',
          userId: 'u1',
          word: 'goodbye',
          translation: 'tchau',
          originalPhraseId: 'p2',
        ),
      ]);

  Future<void> salvarItem(VocabularyItem item) async {
    // Simula persistência assíncrona
    await Future.delayed(const Duration(milliseconds: 120));

    final exists = state.any((e) => e.id == item.id);
    if (exists) {
      state = [
        for (final e in state)
          if (e.id == item.id) item else e,
      ];
    } else {
      state = [...state, item];
    }
  }
}
