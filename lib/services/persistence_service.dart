// lib/services/persistence_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_dto.dart';

class PersistenceService {
  // Chaves existentes mantidas para onboarding/terms
  static const String _onboardingKey = 'seenOnboarding';
  static const String _termsKey = 'acceptedTerms';

  // Novas chaves para perfil do usuário (PII) e consentimento de marketing
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';
  static const String _userDescriptionKey = 'userDescription';
  static const String _userDtoKey = 'userDto';
  static const String _marketingKey = 'acceptedMarketing';
  static const String _loggedInKey = 'isLoggedIn';

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
}
