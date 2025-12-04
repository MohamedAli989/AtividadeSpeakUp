import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pprincipal/core/services/persistence_service.dart';
import 'package:pprincipal/features/4_profile/domain/entities/user_profile.dart';
import 'package:pprincipal/features/2_auth/domain/repositories/i_auth_repository.dart';

/// Lightweight implementation of auth repository that persists minimal state
/// using `PersistenceService`. Replace or extend with FirebaseAuth integration
/// if/when `firebase_auth` is added to the project.
class AuthRepositoryImpl implements IAuthRepository {
  final PersistenceService _persistence;
  final _supabase = Supabase.instance.client;

  AuthRepositoryImpl([PersistenceService? persistence])
    : _persistence = persistence ?? PersistenceService();

  @override
  Future<void> login({required String email, required String password}) async {
    // Use Supabase auth to sign in. If Supabase isn't configured, fall back
    // to local persistence for offline/testing scenarios.
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      // If sign in succeeded, try to read the current user and persist data.
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final userEmail = user.email;
        final nameMeta = (user.userMetadata ?? {})['name'] as String?;
        final userName = nameMeta ?? (userEmail?.split('@').first ?? '');
        await _persistence.setUserData(
          name: userName,
          email: userEmail ?? email,
        );
        await _persistence.setLoggedIn(true);
        return;
      }
    } catch (_) {
      // ignore errors and continue to persist locally
    }
    // Fallback: persist minimal info locally when Supabase not available.
    await _persistence.setUserData(name: email.split('@').first, email: email);
    await _persistence.setLoggedIn(true);
  }

  @override
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {}
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
  Future<bool> isLoggedIn() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) return true;
    } catch (_) {
      // ignore
    }
    return await _persistence.isLoggedIn();
  }

  @override
  Future<bool> getSeenOnboarding() async =>
      await _persistence.getSeenOnboarding();

  @override
  Future<bool> getAcceptedTerms() async =>
      await _persistence.getAcceptedTerms();

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    // Prefer Supabase current user when available
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final email = user.email;
        final name =
            (user.userMetadata ?? {})['name'] as String? ??
            (email?.split('@').first);
        return UserProfile(
          name: name,
          email: email,
          description: null,
          loggedIn: true,
        );
      }
    } catch (_) {
      // ignore and fallback
    }

    final name = await _persistence.getUserName();
    final email = await _persistence.getUserEmail();
    if (name == null && email == null) return null;
    return UserProfile(
      name: name,
      email: email,
      description: null,
      loggedIn: await _persistence.isLoggedIn(),
    );
  }
}
