import '../../domain/repositories/terms_repository.dart';
import '../datasources/local_terms_datasource.dart';

class TermsRepositoryImpl implements TermsRepository {
  final LocalTermsDataSource localDataSource;

  TermsRepositoryImpl(this.localDataSource);

  @override
  Future<bool> getAccepted() async {
    return await localDataSource.getAcceptedTerms();
  }

  @override
  Future<void> setAccepted(bool value) async {
    await localDataSource.setAcceptedTerms(value);
  }
}
