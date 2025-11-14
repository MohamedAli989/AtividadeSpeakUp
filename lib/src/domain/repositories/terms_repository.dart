abstract class TermsRepository {
  Future<void> setAccepted(bool value);
  Future<bool> getAccepted();
}
