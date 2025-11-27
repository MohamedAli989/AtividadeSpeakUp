import 'package:pprincipal/features/2_auth/domain/repositories/i_auth_repository.dart';

/// Returns a route string to navigate to based on persisted app state.
class VerificarStatusAppUseCase {
  final IAuthRepository _repo;

  VerificarStatusAppUseCase(this._repo);

  /// Returns one of: '/onboarding', '/terms', '/login', '/home'
  Future<String> call() async {
    final seenOnboarding = await _repo.getSeenOnboarding();
    final acceptedTerms = await _repo.getAcceptedTerms();
    final loggedIn = await _repo.isLoggedIn();

    if (!seenOnboarding) return '/onboarding';
    if (!acceptedTerms) return '/terms';
    if (!loggedIn) return '/login';
    return '/home';
  }
}
