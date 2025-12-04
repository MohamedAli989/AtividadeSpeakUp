// lib/features/3_content/domain/usecases/carregar_recados_usecase.dart
import 'package:pprincipal/features/3_content/domain/repositories/i_content_repository.dart';
import 'package:pprincipal/features/3_content/domain/entities/notice.dart';

class CarregarRecadosUseCase {
  final IContentRepository _repo;
  CarregarRecadosUseCase(this._repo);

  Future<List<Notice>> call() async {
    return await _repo.carregarRecados();
  }
}
