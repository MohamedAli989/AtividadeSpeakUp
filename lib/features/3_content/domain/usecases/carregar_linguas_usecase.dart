import 'package:pprincipal/features/3_content/domain/entities/language.dart';
import 'package:pprincipal/features/3_content/domain/repositories/i_content_repository.dart';

class CarregarLinguasUseCase {
  final IContentRepository repository;

  CarregarLinguasUseCase(this.repository);

  Future<List<Language>> call() async {
    return await repository.carregarLinguas();
  }
}
