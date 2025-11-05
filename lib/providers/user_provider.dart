import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/persistence_service.dart';
import 'provide_mapper.dart';
import '../models/user_progress.dart';

/// Modelo simples de usuário usado pelo app. Campos são nullable porque
/// o app permite estado anônimo / deslogado.
class User {
  final String? name;
  final String? email;
  final String? description;
  final bool loggedIn;

  const User({this.name, this.email, this.description, this.loggedIn = false});

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

/// Contêiner de estado agregado para o perfil do usuário e progresso.
class UserState {
  final User? profile;
  final UserProgress? progress;

  const UserState({this.profile, this.progress});

  UserState copyWith({User? profile, UserProgress? progress}) {
    return UserState(
      profile: profile ?? this.profile,
      progress: progress ?? this.progress,
    );
  }
}

/// StateNotifier que gerencia tanto o perfil quanto o progresso e persiste
/// o progresso no Firestore.
class UserNotifier extends StateNotifier<AsyncValue<UserState>> {
  final PersistenceService _svc;

  UserNotifier(this._svc) : super(const AsyncValue.loading()) {
    load();
  }

  /// Carrega usuário e progresso. O progresso é carregado do Firestore quando
  /// um identificador de usuário está disponível. Observação: esta
  /// implementação assume que o e-mail do usuário é usado como id do
  /// documento de progresso quando não há um userId explícito armazenado.
  /// Ajuste conforme necessário para corresponder ao seu sistema de auth.
  Future<void> load() async {
    try {
      // Load persisted DTO or legacy fields
      final dto = await _svc.getUserDto();
      User? profile;
      if (dto != null) {
        profile = ProvideMapper.fromDto(dto);
      } else {
        final name = await _svc.getUserName();
        final email = await _svc.getUserEmail();
        final description = await _svc.getUserDescription();
        final loggedIn = await _svc.getLoggedIn();
        profile = User(
          name: name,
          email: email,
          description: description,
          loggedIn: loggedIn,
        );
      }

      UserProgress? progress;
      // Attempt to load progress from Firestore if we have an id to use.
      final userId = profile.email; // assumption: email as id
      if (userId != null && userId.isNotEmpty) {
        final doc = await FirebaseFirestore.instance
            .collection('user_progress')
            .doc(userId)
            .get();
        if (doc.exists) {
          progress = UserProgress.fromJson({'userId': doc.id, ...doc.data()!});
        }
      }

      state = AsyncValue.data(UserState(profile: profile, progress: progress));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Helpers de nível de app (onboarding / termos / marketing) - delega para a
  // camada de persistência
  Future<bool> getSeenOnboarding() => _svc.getSeenOnboarding();
  Future<bool> getAcceptedTerms() => _svc.getAcceptedTerms();
  Future<void> setAcceptedTerms(bool value) => _svc.setAcceptedTerms(value);

  Future<bool> getMarketingConsent() => _svc.getMarketingConsent();
  Future<void> setMarketingConsent(bool value) =>
      _svc.setMarketingConsent(value);
  Future<void> removeMarketingConsent() => _svc.removeMarketingConsent();

  /// Persist full user data and update state.
  Future<void> setUserData({
    required String name,
    required String email,
  }) async {
    final current = state.maybeWhen(data: (s) => s, orElse: () => null);
    final updatedProfile = (current?.profile ?? const User()).copyWith(
      name: name,
      email: email,
    );
    // Persiste o DTO completo para consistência.
    final dto = ProvideMapper.toDto(updatedProfile);
    await _svc.setUserDto(dto);
    state = AsyncValue.data(
      (current ?? const UserState()).copyWith(profile: updatedProfile),
    );
  }

  Future<void> setUserName(String name) async {
    final current = state.maybeWhen(data: (s) => s, orElse: () => null);
    final updated = (current?.profile ?? const User()).copyWith(name: name);
    await _svc.setUserDto(ProvideMapper.toDto(updated));
    state = AsyncValue.data(
      (current ?? const UserState()).copyWith(profile: updated),
    );
  }

  Future<void> setUserDescription(String? description) async {
    final current = state.maybeWhen(data: (s) => s, orElse: () => null);
    final updated = (current?.profile ?? const User()).copyWith(
      description: description,
    );
    await _svc.setUserDto(ProvideMapper.toDto(updated));
    state = AsyncValue.data(
      (current ?? const UserState()).copyWith(profile: updated),
    );
  }

  Future<void> removeUserData() async {
    await _svc.removeUserData();
    await _svc.removeUserDto();
    final current = state.maybeWhen(data: (s) => s, orElse: () => null);
    final updated = (current?.profile ?? const User()).copyWith(
      name: null,
      email: null,
    );
    state = AsyncValue.data(
      (current ?? const UserState()).copyWith(profile: updated),
    );
  }

  Future<void> setLoggedIn(bool value) async {
    final current = state.maybeWhen(data: (s) => s, orElse: () => null);
    final updated = (current?.profile ?? const User()).copyWith(
      loggedIn: value,
    );
    // Persiste tanto o DTO quanto a flag legada de logged-in para
    // compatibilidade com testes/versões antigas.
    await _svc.setUserDto(ProvideMapper.toDto(updated));
    await _svc.setLoggedIn(value);
    state = AsyncValue.data(
      (current ?? const UserState()).copyWith(profile: updated),
    );
  }

  Future<void> logout() async {
    await _svc.logout();
    await _svc.removeUserDto();
    final current = state.maybeWhen(data: (s) => s, orElse: () => null);
    final updated = (current?.profile ?? const User()).copyWith(
      loggedIn: false,
      name: null,
      email: null,
    );
    state = AsyncValue.data(
      (current ?? const UserState()).copyWith(profile: updated),
    );
  }

  /// Increment XP for the current user's progress and persist to Firestore.
  Future<void> incrementXp(int points) async {
    final current = state.maybeWhen(data: (s) => s, orElse: () => null);
    final profile = current?.profile;
    if (profile == null) return;
    final userId = profile.email ?? '';
    if (userId.isEmpty) return;

    final oldProgress =
        current?.progress ??
        UserProgress(
          userId: userId,
          totalXp: 0,
          currentStreak: 0,
          lastPracticeDate: DateTime.fromMillisecondsSinceEpoch(0),
          completedLessonIds: [],
          achievedAchievementIds: [],
          completedChallengeIds: [],
        );

    final updated = oldProgress.copyWith(
      totalXp: oldProgress.totalXp + points,
      lastPracticeDate: DateTime.now(),
    );
    // Persist to Firestore
    await FirebaseFirestore.instance
        .collection('user_progress')
        .doc(userId)
        .set(updated.toJson());
    state = AsyncValue.data(
      (current ?? const UserState()).copyWith(progress: updated),
    );
  }

  /// Mark a lesson complete for the current user and persist progress.
  Future<void> completeLesson(String lessonId) async {
    final current = state.maybeWhen(data: (s) => s, orElse: () => null);
    final profile = current?.profile;
    if (profile == null) return;
    final userId = profile.email ?? '';
    if (userId.isEmpty) return;

    final oldProgress =
        current?.progress ??
        UserProgress(
          userId: userId,
          totalXp: 0,
          currentStreak: 0,
          lastPracticeDate: DateTime.fromMillisecondsSinceEpoch(0),
          completedLessonIds: [],
          achievedAchievementIds: [],
          completedChallengeIds: [],
        );

    final newCompleted = List<String>.from(oldProgress.completedLessonIds);
    if (!newCompleted.contains(lessonId)) newCompleted.add(lessonId);

    final updated = oldProgress.copyWith(
      completedLessonIds: newCompleted,
      lastPracticeDate: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('user_progress')
        .doc(userId)
        .set(updated.toJson());
    state = AsyncValue.data(
      (current ?? const UserState()).copyWith(progress: updated),
    );
  }
}

/// Public provider instance used across the app.
final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserState>>(
  (ref) {
    return UserNotifier(PersistenceService());
  },
);

/// Backwards-compatible provider that exposes the current User profile or null.
final currentUserProvider = Provider<User?>((ref) {
  final av = ref.watch(userProvider);
  return av.maybeWhen(data: (s) => s.profile, orElse: () => null);
});
