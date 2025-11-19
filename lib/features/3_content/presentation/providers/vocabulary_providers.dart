import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/3_content/domain/entities/vocabulary_item.dart';
import 'package:pprincipal/features/3_content/data/datasources/vocabulary_local_datasource.dart';
import 'package:pprincipal/features/3_content/data/repositories/vocabulary_repository_impl.dart';
import 'package:pprincipal/features/4_profile/presentation/providers/user_provider.dart';

/// An AsyncNotifier-backed provider that loads the current user's vocabulary
/// from the persistent repository and exposes helper methods to save items.
final vocabularyListProvider =
    AsyncNotifierProvider<VocabularyListNotifier, List<VocabularyItem>>(
      () => VocabularyListNotifier(),
    );

class VocabularyListNotifier extends AsyncNotifier<List<VocabularyItem>> {
  late final VocabularyRepositoryImpl _repo;

  @override
  Future<List<VocabularyItem>> build() async {
    // Initialize repository backed by SharedPreferences data source.
    final local = VocabularyLocalDataSource();
    _repo = VocabularyRepositoryImpl(local: local);

    // Determine current user id; fall back to 'u1' for legacy/tests.
    final user = ref.watch(currentUserProvider);
    final userId = user?.email ?? 'u1';

    final list = await _repo.loadAll(userId);
    return list;
  }

  Future<void> salvarItem(VocabularyItem item) async {
    state = const AsyncValue.loading();
    try {
      await _repo.saveItem(item);
      final updated = await _repo.loadAll(item.userId);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
