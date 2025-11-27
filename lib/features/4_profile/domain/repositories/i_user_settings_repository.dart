// lib/features/4_profile/domain/repositories/i_user_settings_repository.dart
// Abstração do repositório que manipula as configurações do utilizador.

import '../entities/user_settings.dart';

abstract class IUserSettingsRepository {
  /// Carrega as configurações do utilizador identificado por [userId].
  /// Deve retornar as configurações existentes ou as padrão se não houver.
  Future<UserSettings> carregar(String userId);

  /// Salva as [settings] do utilizador.
  Future<void> salvar(UserSettings settings);

  /// Remove as configurações persistidas para [userId].
  Future<void> remover(String userId);
}
