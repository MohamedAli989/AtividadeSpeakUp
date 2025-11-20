import 'package:pprincipal/features/3_content/domain/entities/vocabulary_item.dart';

abstract class VocabularyRepository {
  /// Load all vocabulary items for a given user.
  Future<List<VocabularyItem>> loadAll(String userId);

  /// Persist the given list of vocabulary items for the user.
  Future<void> saveAll(String userId, List<VocabularyItem> items);

  /// Convenience to save a single item (implementations may just load/modify/save).
  Future<void> saveItem(VocabularyItem item);
}
