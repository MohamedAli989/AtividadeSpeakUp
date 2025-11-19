import 'package:pprincipal/core/services/persistence_service.dart';

/// Returns a route string to navigate to based on persisted app state.
class VerificarStatusAppUseCase {
  final PersistenceService _persistence;

  VerificarStatusAppUseCase([PersistenceService? persistence])
    : _persistence = persistence ?? PersistenceService();

  /// Returns one of: '/onboarding', '/terms', '/login', '/home'
  Future<String> call() async {
    final seenOnboarding = await _persistence.getSeenOnboarding();
    final acceptedTerms = await _persistence.getAcceptedTerms();
    final loggedIn = await _persistence.isLoggedIn();

    if (!seenOnboarding) return '/onboarding';
    if (!acceptedTerms) return '/terms';
    if (!loggedIn) return '/login';
    return '/home';
  }
}
