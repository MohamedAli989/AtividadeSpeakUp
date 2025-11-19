import 'package:pprincipal/features/3_content/domain/entities/module.dart';
import 'package:pprincipal/features/3_content/domain/entities/lesson.dart';
import 'package:pprincipal/features/3_content/domain/entities/phrase.dart';

/// Contrato do repositório de conteúdo.
abstract class IContentRepository {
  /// Carrega os módulos disponíveis para uma língua.
  Future<List<Module>> carregarModulos(String languageId);

  /// Carrega as lições que pertencem a um módulo.
  Future<List<Lesson>> carregarLicoesDoModulo(String moduleId);

  /// Carrega as frases de uma lição.
  Future<List<Phrase>> carregarFrasesDaLicao(String lessonId);
}
