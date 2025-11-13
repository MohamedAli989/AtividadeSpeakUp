import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/persistence_service.dart';
import '../data/datasources/local_terms_datasource.dart';
import '../data/repositories/terms_repository_impl.dart';
import '../domain/repositories/terms_repository.dart';
import '../domain/usecases/set_terms_accepted.dart';

final persistenceServiceProvider = Provider<PersistenceService>((ref) {
  return PersistenceService();
});

final localTermsDataSourceProvider = Provider<LocalTermsDataSource>((ref) {
  final persistence = ref.read(persistenceServiceProvider);
  return LocalTermsDataSource(persistence);
});

final termsRepositoryProvider = Provider<TermsRepository>((ref) {
  final ds = ref.read(localTermsDataSourceProvider);
  return TermsRepositoryImpl(ds);
});

final setTermsAcceptedUsecaseProvider = Provider<SetTermsAccepted>((ref) {
  final repo = ref.read(termsRepositoryProvider);
  return SetTermsAccepted(repo);
});
