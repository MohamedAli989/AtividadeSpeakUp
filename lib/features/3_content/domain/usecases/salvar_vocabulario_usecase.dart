import 'package:pprincipal/features/3_content/domain/entities/vocabulary_item.dart';
import 'package:pprincipal/features/3_content/domain/repositories/vocabulary_repository.dart';

class SalvarVocabularioUseCase {
  final VocabularyRepository repository;

  SalvarVocabularioUseCase(this.repository);

  Future<void> call(VocabularyItem item) async {
    final userId = item.userId;
    final list = await repository.loadAll(userId);

    final exists = list.any((e) => e.id == item.id);
    final updated = exists
        ? [
            for (final e in list)
              if (e.id == item.id) item else e,
          ]
        : [...list, item];

    await repository.saveAll(userId, updated);
  }
}
