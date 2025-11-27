// lib/features/3_content/presentation/providers/content_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/3_content/data/datasources/content_remote_datasource.dart';
import 'package:pprincipal/features/3_content/data/repositories/content_repository_impl.dart';
import 'package:pprincipal/features/3_content/domain/usecases/carregar_modulos_usecase.dart';
import 'package:pprincipal/features/3_content/domain/usecases/carregar_licoes_usecase.dart';
import 'package:pprincipal/features/3_content/domain/usecases/carregar_frases_usecase.dart';

// Provider privado que cria a implementação do repositório usando o data source.
final _contentRepositoryProvider = Provider((ref) {
  final remote = ContentRemoteDataSource();
  return ContentRepositoryImpl(remote);
});

final carregarModulosUseCaseProvider = Provider((ref) {
  final repo = ref.watch(_contentRepositoryProvider);
  return CarregarModulosUseCase(repo);
});

final carregarLicoesUseCaseProvider = Provider((ref) {
  final repo = ref.watch(_contentRepositoryProvider);
  return CarregarLicoesUseCase(repo);
});

final carregarFrasesUseCaseProvider = Provider((ref) {
  final repo = ref.watch(_contentRepositoryProvider);
  return CarregarFrasesUseCase(repo);
});
