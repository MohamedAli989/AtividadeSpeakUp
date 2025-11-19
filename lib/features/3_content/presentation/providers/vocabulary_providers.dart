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
        const VocabularyItem(
          id: '3',
          userId: 'u1',
          word: 'please',
          translation: 'por favor',
          originalPhraseId: 'p3',
        ),
        const VocabularyItem(
          id: '4',
          userId: 'u1',
          word: 'thank you',
          translation: 'obrigado',
          originalPhraseId: 'p4',
        ),
        const VocabularyItem(
          id: '5',
          userId: 'u1',
          word: 'sorry',
          translation: 'desculpe',
          originalPhraseId: 'p5',
        ),
        const VocabularyItem(
          id: '6',
          userId: 'u1',
          word: 'yes',
          translation: 'sim',
          originalPhraseId: 'p6',
        ),
        const VocabularyItem(
          id: '7',
          userId: 'u1',
          word: 'no',
          translation: 'não',
          originalPhraseId: 'p7',
        ),
        const VocabularyItem(
          id: '8',
          userId: 'u1',
          word: 'morning',
          translation: 'manhã',
          originalPhraseId: 'p8',
        ),
        const VocabularyItem(
          id: '9',
          userId: 'u1',
          word: 'night',
          translation: 'noite',
          originalPhraseId: 'p9',
        ),
        const VocabularyItem(
          id: '10',
          userId: 'u1',
          word: 'food',
          translation: 'comida',
          originalPhraseId: 'p10',
        ),
        const VocabularyItem(
          id: '11',
          userId: 'u1',
          word: 'water',
          translation: 'água',
          originalPhraseId: 'p11',
        ),
        const VocabularyItem(
          id: '12',
          userId: 'u1',
          word: 'friend',
          translation: 'amigo',
          originalPhraseId: 'p12',
        ),
        const VocabularyItem(
          id: '13',
          userId: 'u1',
          word: 'teacher',
          translation: 'professor',
          originalPhraseId: 'p13',
        ),
        const VocabularyItem(
          id: '14',
          userId: 'u1',
          word: 'house',
          translation: 'casa',
          originalPhraseId: 'p14',
        ),
        const VocabularyItem(
          id: '15',
          userId: 'u1',
          word: 'car',
          translation: 'carro',
          originalPhraseId: 'p15',
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
