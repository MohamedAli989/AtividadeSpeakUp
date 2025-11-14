import '../../../services/persistence_service.dart';

class LocalTermsDataSource {
  final PersistenceService _persistenceService;

  LocalTermsDataSource(this._persistenceService);

  Future<void> setAcceptedTerms(bool value) async {
    await _persistenceService.setAcceptedTerms(value);
  }

  Future<bool> getAcceptedTerms() async {
    return await _persistenceService.getAcceptedTerms();
  }
}
