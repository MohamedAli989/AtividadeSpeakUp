import 'package:pprincipal/features/3_content/domain/entities/module.dart';
import 'package:pprincipal/features/3_content/domain/repositories/i_content_repository.dart';

/// Caso de uso para carregar os módulos de uma língua.
class CarregarModulosUseCase {
  final IContentRepository repository;

  CarregarModulosUseCase(this.repository);

  Future<List<Module>> call(String languageId) async {
    return await repository.carregarModulos(languageId);
  }
}
