import 'package:pprincipal/features/3_content/domain/entities/phrase.dart';
import 'package:pprincipal/features/3_content/domain/repositories/i_content_repository.dart';

/// Caso de uso para carregar as frases de uma lição.
class CarregarFrasesUseCase {
  final IContentRepository repository;

  CarregarFrasesUseCase(this.repository);

  Future<List<Phrase>> call(String lessonId) async {
    return await repository.carregarFrasesDaLicao(lessonId);
  }
}
