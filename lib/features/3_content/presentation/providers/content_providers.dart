// lib/features/3_content/presentation/providers/content_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/3_content/data/datasources/content_remote_datasource.dart';
import 'package:pprincipal/features/3_content/data/repositories/content_repository_impl.dart';
import 'package:pprincipal/features/3_content/domain/usecases/carregar_modulos_usecase.dart';
import 'package:pprincipal/features/3_content/domain/usecases/carregar_licoes_usecase.dart';
import 'package:pprincipal/features/3_content/domain/usecases/carregar_frases_usecase.dart';
import 'package:pprincipal/features/3_content/domain/usecases/carregar_recados_usecase.dart';
import 'package:pprincipal/features/3_content/domain/usecases/carregar_linguas_usecase.dart';
import 'package:pprincipal/features/3_content/domain/entities/language.dart';
import 'package:pprincipal/features/3_content/domain/entities/module.dart';
import 'package:pprincipal/features/3_content/domain/entities/lesson.dart';
import 'package:pprincipal/features/3_content/domain/entities/notice.dart';

// Provider privado que cria a implementação do repositório usando o data source.
final _contentRepositoryProvider = Provider((ref) {
  final remote = ContentRemoteDataSource();
  return ContentRepositoryImpl(remote);
});

final carregarModulosUseCaseProvider = Provider((ref) {
  final repo = ref.watch(_contentRepositoryProvider);
  return CarregarModulosUseCase(repo);
});

final carregarLinguasUseCaseProvider = Provider((ref) {
  final repo = ref.watch(_contentRepositoryProvider);
  return CarregarLinguasUseCase(repo);
});

final carregarLicoesUseCaseProvider = Provider((ref) {
  final repo = ref.watch(_contentRepositoryProvider);
  return CarregarLicoesUseCase(repo);
});

final carregarFrasesUseCaseProvider = Provider((ref) {
  final repo = ref.watch(_contentRepositoryProvider);
  return CarregarFrasesUseCase(repo);
});

final carregarRecadosUseCaseProvider = Provider((ref) {
  final repo = ref.watch(_contentRepositoryProvider);
  return CarregarRecadosUseCase(repo);
});

final recadosProvider = FutureProvider<List<Notice>>((ref) {
  final usecase = ref.watch(carregarRecadosUseCaseProvider);
  return usecase.call();
});

/// Provide languages as a FutureProvider - used by the Home screen to
/// determine the current language and load modules.
final languagesProvider = FutureProvider<List<Language>>((ref) {
  final usecase = ref.watch(carregarLinguasUseCaseProvider);
  return usecase.call();
});

/// Modules for a specific language.
final modulesProvider = FutureProvider.family<List<Module>, String>((
  ref,
  languageId,
) {
  final usecase = ref.watch(carregarModulosUseCaseProvider);
  return usecase.call(languageId);
});

/// Lessons for a specific module.
final lessonsProvider = FutureProvider.family<List<Lesson>, String>((
  ref,
  moduleId,
) {
  final usecase = ref.watch(carregarLicoesUseCaseProvider);
  return usecase.call(moduleId);
});
