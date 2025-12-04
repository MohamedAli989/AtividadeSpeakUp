import 'package:pprincipal/features/3_content/domain/entities/module.dart';
import 'package:pprincipal/features/3_content/domain/entities/lesson.dart';
import 'package:pprincipal/features/3_content/domain/entities/phrase.dart';
import 'package:pprincipal/features/3_content/domain/repositories/i_content_repository.dart';
import 'package:pprincipal/features/3_content/data/datasources/content_remote_datasource.dart';
import 'package:pprincipal/features/3_content/domain/entities/notice.dart';
import 'package:pprincipal/features/3_content/domain/entities/language.dart';

/// Implementação concreta do repositório de conteúdo.
class ContentRepositoryImpl implements IContentRepository {
  final ContentRemoteDataSource _dataSource;

  ContentRepositoryImpl(this._dataSource);

  @override
  Future<List<Module>> carregarModulos(String languageId) async {
    return await _dataSource.loadModules(languageId);
  }

  @override
  Future<List<Lesson>> carregarLicoesDoModulo(String moduleId) async {
    return await _dataSource.loadLessonsForModule(moduleId);
  }

  @override
  Future<List<Phrase>> carregarFrasesDaLicao(String lessonId) async {
    return await _dataSource.loadPhrasesForLesson(lessonId);
  }

  @override
  Future<List<Notice>> carregarRecados() async {
    return await _dataSource.getNotices();
  }

  @override
  Future<List<Language>> carregarLinguas() async {
    return await _dataSource.loadLanguages();
  }
}
