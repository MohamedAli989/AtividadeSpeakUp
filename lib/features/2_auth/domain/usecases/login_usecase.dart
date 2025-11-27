import 'package:pprincipal/features/2_auth/domain/repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<void> call({required String email, required String password}) async {
    await repository.login(email: email, password: password);
  }
}
