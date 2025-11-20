// lib/features/4_profile/domain/usecases/carregar_user_settings_usecase.dart
// Usecase para carregar as configurações do utilizador.

import '../repositories/i_user_settings_repository.dart';
import '../entities/user_settings.dart';

class CarregarUserSettingsUseCase {
  final IUserSettingsRepository repository;

  CarregarUserSettingsUseCase(this.repository);

  Future<UserSettings> call(String userId) async {
    return repository.carregar(userId);
  }
}
