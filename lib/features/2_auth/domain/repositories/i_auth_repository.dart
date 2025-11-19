import 'package:pprincipal/features/4_profile/domain/entities/user_profile.dart';

abstract class IAuthRepository {
  Future<void> login({required String email, required String password});
  Future<void> logout();
  Future<void> skipLogin({String? name});
  Future<void> acceptTerms();

  Future<bool> isLoggedIn();
  Future<bool> getSeenOnboarding();
  Future<bool> getAcceptedTerms();

  Future<UserProfile?> getCurrentUserProfile();
}
