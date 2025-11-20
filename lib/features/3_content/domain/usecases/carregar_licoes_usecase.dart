import 'package:pprincipal/features/3_content/domain/entities/lesson.dart';
import 'package:pprincipal/features/3_content/domain/repositories/i_content_repository.dart';

/// Caso de uso para carregar as lições de um módulo.
class CarregarLicoesUseCase {
  final IContentRepository repository;

  CarregarLicoesUseCase(this.repository);

  Future<List<Lesson>> call(String moduleId) async {
    return await repository.carregarLicoesDoModulo(moduleId);
  }
}
