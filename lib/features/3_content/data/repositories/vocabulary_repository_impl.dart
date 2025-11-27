import 'package:pprincipal/features/3_content/domain/entities/vocabulary_item.dart';
import 'package:pprincipal/features/3_content/domain/repositories/vocabulary_repository.dart';
import 'package:pprincipal/features/3_content/data/datasources/vocabulary_local_datasource.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  final VocabularyLocalDataSource local;

  VocabularyRepositoryImpl({required this.local});

  @override
  Future<List<VocabularyItem>> loadAll(String userId) => local.loadAll(userId);

  @override
  Future<void> saveAll(String userId, List<VocabularyItem> items) =>
      local.saveAll(userId, items);

  @override
  Future<void> saveItem(VocabularyItem item) async {
    final list = await loadAll(item.userId);
    final exists = list.any((e) => e.id == item.id);
    final updated = exists
        ? [
            for (final e in list)
              if (e.id == item.id) item else e,
          ]
        : [...list, item];
    await saveAll(item.userId, updated);
  }
}
