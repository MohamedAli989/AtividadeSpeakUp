import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/3_content/domain/entities/vocabulary_item.dart';

/// UseCase-style provider that exposes a `Future<void> Function(VocabularyItem)`
/// to save a vocabulary item. Internally delegates to the notifier used in
/// the demo provider. This lets presentation code depend on a UseCase API.
import 'package:pprincipal/features/3_content/domain/usecases/salvar_vocabulario_usecase.dart';
import 'package:pprincipal/features/3_content/data/datasources/vocabulary_local_datasource.dart';
import 'package:pprincipal/features/3_content/data/repositories/vocabulary_repository_impl.dart';
import 'package:pprincipal/features/3_content/presentation/providers/vocabulary_providers.dart';

/// Provider that exposes a `Future<void> Function(VocabularyItem)` usecase
/// backed by SharedPreferences via `VocabularyLocalDataSource`.
final salvarVocabularioUseCaseProvider =
    Provider<Future<void> Function(VocabularyItem)>((ref) {
      final local = VocabularyLocalDataSource();
      final repo = VocabularyRepositoryImpl(local: local);
      final usecase = SalvarVocabularioUseCase(repo);

      return (VocabularyItem item) async {
        await usecase.call(item);
        // Invalidate the vocabulary list so the UI reloads from persistence.
        ref.invalidate(vocabularyListProvider);
      };
    });
