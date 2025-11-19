import 'package:pprincipal/features/2_auth/domain/repositories/i_auth_repository.dart';

class PularLoginUseCase {
  final IAuthRepository repository;

  PularLoginUseCase(this.repository);

  Future<void> call({String? name}) async {
    await repository.skipLogin(name: name);
  }
}
