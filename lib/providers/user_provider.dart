import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/persistence_service.dart';

class User {
  final String? name;
  final String? email;
  final String? description;
  final bool loggedIn;

  User({this.name, this.email, this.description, this.loggedIn = false});

  User copyWith({
    String? name,
    String? email,
    String? description,
    bool? loggedIn,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      description: description ?? this.description,
      loggedIn: loggedIn ?? this.loggedIn,
    );
  }
}

class UserNotifier extends StateNotifier<User> {
  final PersistenceService _svc = PersistenceService();

  UserNotifier() : super(User(name: null, email: null, loggedIn: false));

  Future<void> load() async {
    final name = await _svc.getUserName();
    final email = await _svc.getUserEmail();
    final description = await _svc.getUserDescription();
    final loggedIn = await _svc.getLoggedIn();
    state = User(
      name: name,
      email: email,
      description: description,
      loggedIn: loggedIn,
    );
  }

  // App-level helpers (onboarding / terms / marketing)
  Future<bool> getSeenOnboarding() => _svc.getSeenOnboarding();
  Future<bool> getAcceptedTerms() => _svc.getAcceptedTerms();

  Future<bool> getMarketingConsent() => _svc.getMarketingConsent();
  Future<void> setMarketingConsent(bool value) =>
      _svc.setMarketingConsent(value);
  Future<void> removeMarketingConsent() => _svc.removeMarketingConsent();

  Future<void> setUserData({
    required String name,
    required String email,
  }) async {
    await _svc.setUserData(name: name, email: email);
    state = state.copyWith(name: name, email: email);
  }

  Future<void> setUserName(String name) async {
    await _svc.setUserData(name: name, email: state.email ?? '');
    state = state.copyWith(name: name);
  }

  Future<void> setUserDescription(String? description) async {
    await _svc.setUserDescription(description);
    state = state.copyWith(description: description);
  }

  Future<void> removeUserData() async {
    await _svc.removeUserData();
    state = state.copyWith(name: null, email: null);
  }

  Future<void> setLoggedIn(bool value) async {
    await _svc.setLoggedIn(value);
    state = state.copyWith(loggedIn: value);
  }

  Future<void> logout() async {
    await _svc.logout();
    state = state.copyWith(loggedIn: false, name: null, email: null);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  return UserNotifier();
});
