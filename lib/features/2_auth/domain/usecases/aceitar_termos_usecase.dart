import 'package:pprincipal/features/2_auth/domain/repositories/i_auth_repository.dart';

class AceitarTermosUseCase {
  final IAuthRepository repository;

  AceitarTermosUseCase(this.repository);

  Future<void> call() async {
    await repository.acceptTerms();
  }
}
