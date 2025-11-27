// lib/features/4_profile/domain/usecases/salvar_user_settings_usecase.dart
// Usecase para salvar as configurações do utilizador.

import '../repositories/i_user_settings_repository.dart';
import '../entities/user_settings.dart';

class SalvarUserSettingsUseCase {
  final IUserSettingsRepository repository;

  SalvarUserSettingsUseCase(this.repository);

  Future<void> call(UserSettings settings) async {
    await repository.salvar(settings);
  }
}
