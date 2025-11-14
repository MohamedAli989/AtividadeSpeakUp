import '../repositories/terms_repository.dart';

class SetTermsAccepted {
  final TermsRepository repository;

  SetTermsAccepted(this.repository);

  Future<void> call(bool value) async {
    await repository.setAccepted(value);
  }
}
