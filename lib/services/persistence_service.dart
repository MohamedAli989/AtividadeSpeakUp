// lib/services/persistence_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_dto.dart';

class PersistenceService {
  // Existing keys kept for onboarding/terms
  static const String _onboardingKey = 'seenOnboarding';
  static const String _termsKey = 'acceptedTerms';

  // New keys for user profile (PII) and marketing consent
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

  // Terms
  Future<void> setAcceptedTerms(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_termsKey, value);
  }

  Future<bool> getAcceptedTerms() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_termsKey) ?? false;
  }

  // Profile (PII)
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

  // Marketing consent
  Future<void> setMarketingConsent(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_marketingKey, value);
  }

  Future<bool> getMarketingConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_marketingKey) ?? false;
  }

  // Login state
  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, value);
  }

  /// Returns true if a logged-in flag exists and is true.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  /// Backwards-compatible alias used by older code/tests.
  Future<bool> getLoggedIn() async => isLoggedIn();

  /// Removes the persisted logged-in flag.
  Future<void> removeLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);
  }

  /// Convenience: clear user PII and mark logged out.
  Future<void> logout() async {
    await removeUserData();
    await setLoggedIn(false);
  }

  // Removal helpers - granular deletion only
  Future<void> removeMarketingConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_marketingKey);
  }

  Future<void> removeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  // User description (optional)
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

  // Full DTO (JSON) helpers
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
