// lib/core/services/persistence_service.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:pprincipal/features/4_profile/data/dtos/user_dto.dart';
import 'package:pprincipal/features/4_profile/domain/entities/user_settings.dart';
import 'package:pprincipal/features/5_notifications/domain/entities/app_notification.dart';

class PersistenceService {
  // Chaves existentes mantidas para onboarding/terms
  static const String _onboardingKey = 'seenOnboarding';
  static const String _termsKey = 'acceptedTerms';

  // Novas chaves para perfil do usuário (PII) e consentimento de marketing
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';
  static const String _userDescriptionKey = 'userDescription';
  static const String _userDtoKey = 'userDto';
  static const String _userAvatarColorKey = 'userAvatarColor';
  static const String _appPaletteKey = 'appPalette';
  static const String _themeModeKey = 'themeMode';
  static const String _marketingKey = 'acceptedMarketing';
  static const String _loggedInKey = 'isLoggedIn';

  // Chaves para configurações do utilizador (valores atômicos)
  static const String _userSettingsMetaKey = 'userSettings_metaDiaria_';
  static const String _userSettingsIdiomaKey = 'userSettings_idioma_';
  static const String _userSettingsVelKey = 'userSettings_velocidade_';
  static const String _userSettingsHoraKey = 'userSettings_hora_';

  // Onboarding
  Future<void> setSeenOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, value);
  }

  Future<bool> getSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  // Termos
  Future<void> setAcceptedTerms(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_termsKey, value);
  }

  Future<bool> getAcceptedTerms() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_termsKey) ?? false;
  }

  // Perfil (PII)
  Future<void> setUserData({
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Consentimento de marketing
  Future<void> setMarketingConsent(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_marketingKey, value);
  }

  Future<bool> getMarketingConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_marketingKey) ?? false;
  }

  // Estado de login
  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, value);
  }

  /// Retorna true se a flag de logged-in existir e for true.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  /// Alias compatível com versões anteriores usado por código/testes antigos.
  Future<bool> getLoggedIn() async => isLoggedIn();

  /// Remove a flag de logged-in persistida.
  Future<void> removeLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);
  }

  /// Conveniência: limpa PII do usuário e marca como deslogado.
  Future<void> logout() async {
    await removeUserData();
    await setLoggedIn(false);
  }

  // Helpers de remoção - remoção granular apenas
  Future<void> removeMarketingConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_marketingKey);
  }

  Future<void> removeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  // Descrição do usuário (opcional)
  Future<void> setUserDescription(String? description) async {
    final prefs = await SharedPreferences.getInstance();
    if (description == null) {
      await prefs.remove(_userDescriptionKey);
    } else {
      await prefs.setString(_userDescriptionKey, description);
    }
  }

  Future<String?> getUserDescription() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDescriptionKey);
  }

  Future<void> removeUserDescription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDescriptionKey);
  }

  // Helpers para DTO completo (JSON)
  Future<void> setUserDto(UserDTO dto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDtoKey, dto.toJson());
  }

  Future<UserDTO?> getUserDto() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userDtoKey);
    if (json == null) return null;
    return UserDTO.fromJson(json);
  }

  Future<void> removeUserDto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDtoKey);
  }

  // Avatar color persistence (stored as ARGB int)
  Future<void> setUserAvatarColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userAvatarColorKey, colorValue);
  }

  Future<int?> getUserAvatarColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userAvatarColorKey);
  }

  Future<void> removeUserAvatarColor() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userAvatarColorKey);
  }

  Future<void> setAppPalette(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_appPaletteKey, colorValue);
  }

  Future<int?> getAppPalette() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_appPaletteKey);
  }

  // ThemeMode persistence: 'light' | 'dark' | 'system'
  Future<void> setThemeMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, value);
  }

  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey);
  }

  Future<void> removeAppPalette() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_appPaletteKey);
  }

  // ---------- Granular getters/setters para UserSettings ----------
  Future<void> setMetaDiaria(String userId, int minutos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_userSettingsMetaKey$userId', minutos);
  }

  Future<int?> getMetaDiaria(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_userSettingsMetaKey$userId');
  }

  Future<void> setIdiomaAtivo(String userId, String idioma) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_userSettingsIdiomaKey$userId', idioma);
  }

  Future<String?> getIdiomaAtivo(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_userSettingsIdiomaKey$userId');
  }

  Future<void> setVelocidadeReproducao(String userId, double velocidade) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_userSettingsVelKey$userId', velocidade);
  }

  Future<double?> getVelocidadeReproducao(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('$_userSettingsVelKey$userId');
  }

  Future<void> setHoraLembrete(String userId, String? hora) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_userSettingsHoraKey$userId';
    if (hora == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, hora);
    }
  }

  Future<String?> getHoraLembrete(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_userSettingsHoraKey$userId');
  }

  // ---------- AppNotification persistence ----------
  /// Armazena todas as notificações do utilizador em uma lista JSON.
  Future<void> setAppNotifications(
    String userId,
    List<AppNotification> list,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'appNotifications_$userId';
    final jsonList = list.map((n) => n.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  /// Recupera todas as notificações do utilizador.
  Future<List<AppNotification>> getAppNotifications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'appNotifications_$userId';
    final jsonStr = prefs.getString(key);
    if (jsonStr == null) return <AppNotification>[];
    final decoded = jsonDecode(jsonStr) as List<dynamic>;
    return decoded
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Adiciona/atualiza uma notificação para o utilizador.
  Future<void> addAppNotification(
    String userId,
    AppNotification notificacao,
  ) async {
    final current = await getAppNotifications(userId);
    final index = current.indexWhere((n) => n.id == notificacao.id);
    if (index >= 0) {
      current[index] = notificacao;
    } else {
      current.add(notificacao);
    }
    await setAppNotifications(userId, current);
  }

  /// Remove uma notificação por id.
  Future<void> removeAppNotification(
    String userId,
    String notificationId,
  ) async {
    final current = await getAppNotifications(userId);
    current.removeWhere((n) => n.id == notificationId);
    await setAppNotifications(userId, current);
  }

  // ---------- UserSettings persistence ----------
  // Armazena as configurações do utilizador em uma chave específica.
  Future<void> setUserSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'userSettings_${settings.userId}';
    await prefs.setString(key, jsonEncode(settings.toJson()));
  }

  // Recupera as configurações do utilizador; retorna `null` se não existir.
  Future<UserSettings?> getUserSettings(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'userSettings_$userId';
    final jsonStr = prefs.getString(key);
    if (jsonStr == null) return null;
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return UserSettings.fromJson(map);
  }

  // Remove configurações do utilizador persistidas.
  Future<void> removeUserSettings(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'userSettings_$userId';
    await prefs.remove(key);
  }
}
