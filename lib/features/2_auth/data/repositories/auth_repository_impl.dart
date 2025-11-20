import 'package:pprincipal/core/services/persistence_service.dart';
import 'package:pprincipal/features/4_profile/domain/entities/user_profile.dart';
import 'package:pprincipal/features/2_auth/domain/repositories/i_auth_repository.dart';

/// Lightweight implementation of auth repository that persists minimal state
/// using `PersistenceService`. Replace or extend with FirebaseAuth integration
/// if/when `firebase_auth` is added to the project.
class AuthRepositoryImpl implements IAuthRepository {
  final PersistenceService _persistence;

  AuthRepositoryImpl([PersistenceService? persistence])
    : _persistence = persistence ?? PersistenceService();

  @override
  Future<void> login({required String email, required String password}) async {
    // TODO: integrate real authentication (FirebaseAuth) here.
    // For now, persist minimal user info and mark as logged in.
    await _persistence.setUserData(name: email.split('@').first, email: email);
    await _persistence.setLoggedIn(true);
  }

  @override
  Future<void> logout() async {
    await _persistence.logout();
  }

  @override
  Future<void> skipLogin({String? name}) async {
    if (name != null && name.isNotEmpty) {
      await _persistence.setUserData(name: name, email: '');
    }
    await _persistence.setLoggedIn(true);
  }

  @override
  Future<void> acceptTerms() async {
    await _persistence.setAcceptedTerms(true);
  }

  @override
  Future<bool> isLoggedIn() async => await _persistence.isLoggedIn();

  @override
  Future<bool> getSeenOnboarding() async =>
      await _persistence.getSeenOnboarding();

  @override
  Future<bool> getAcceptedTerms() async =>
      await _persistence.getAcceptedTerms();

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    final name = await _persistence.getUserName();
    final email = await _persistence.getUserEmail();
    if (name == null && email == null) return null;
    return UserProfile(name: name, email: email, description: null);
  }
}
