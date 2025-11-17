// lib/features/4_profile/data/repositories/user_settings_repository_impl.dart
// Implementação do repositório de UserSettings usando PersistenceService.

import 'package:pprincipal/core/services/persistence_service.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/i_user_settings_repository.dart';

class UserSettingsRepositoryImpl implements IUserSettingsRepository {
  final PersistenceService _svc;

  UserSettingsRepositoryImpl(this._svc);

  @override
  Future<UserSettings> carregar(String userId) async {
    final settings = await _svc.getUserSettings(userId);
    if (settings != null) return settings;
    // Retorna configurações padrão se não houver nada persistido.
    return UserSettings.defaultSettings(userId);
  }

  @override
  Future<void> salvar(UserSettings settings) async {
    await _svc.setUserSettings(settings);
  }

  @override
  Future<void> remover(String userId) async {
    await _svc.removeUserSettings(userId);
  }
}
