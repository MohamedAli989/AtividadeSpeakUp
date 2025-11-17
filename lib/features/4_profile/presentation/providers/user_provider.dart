import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/core/services/persistence_service.dart';
import 'package:pprincipal/features/4_profile/data/mappers/provide_mapper.dart';
import 'package:pprincipal/features/3_content/domain/entities/user_progress.dart';
import 'package:pprincipal/features/4_profile/domain/entities/user_profile.dart';

// UserProfile entity moved to domain/entities and imported above.

class UserState {
  final UserProfile? profile;
  final UserProgress? progress;

  const UserState({this.profile, this.progress});

  UserState copyWith({User? profile, UserProgress? progress}) {
    return UserState(
      profile: profile ?? this.profile,
      progress: progress ?? this.progress,
    );
  }
}

class UserNotifier extends StateNotifier<AsyncValue<UserState>> {
  final PersistenceService _svc;

  UserNotifier(this._svc) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final dto = await _svc.getUserDto();
      UserProfile? profile;
      if (dto != null) {
        profile = ProvideMapper.fromDto(dto);
      } else {
        final name = await _svc.getUserName();
        final email = await _svc.getUserEmail();
        final description = await _svc.getUserDescription();
        final loggedIn = await _svc.getLoggedIn();
        profile = UserProfile(
          name: name,
          email: email,
          description: description,
          loggedIn: loggedIn,
        );
      }

      UserProgress? progress;
      final userId = profile.email;
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

  Future<bool> getSeenOnboarding() => _svc.getSeenOnboarding();
  Future<bool> getAcceptedTerms() => _svc.getAcceptedTerms();
  Future<void> setAcceptedTerms(bool value) => _svc.setAcceptedTerms(value);

  Future<bool> getMarketingConsent() => _svc.getMarketingConsent();
  Future<void> setMarketingConsent(bool value) =>
      _svc.setMarketingConsent(value);
  Future<void> removeMarketingConsent() => _svc.removeMarketingConsent();

  Future<void> setUserData({
    required String name,
    required String email,
  }) async {
    final current = state.maybeWhen(data: (s) => s, orElse: () => null);
    final updatedProfile = (current?.profile ?? const User()).copyWith(
      name: name,
      email: email,
    );
    final dto = ProvideMapper.toDto(updatedProfile);
    await _svc.setUserDto(dto);
    state = AsyncValue.data(
      (current ?? const UserState()).copyWith(profile: updatedProfile),
    );
  }

  Future<void> setUserName(String name) async {
    final current = state.maybeWhen(data: (s) => s, orElse: () => null);
    final updated = (current?.profile ?? const UserProfile()).copyWith(
      name: name,
    );
    await _svc.setUserDto(ProvideMapper.toDto(updated));
    state = AsyncValue.data(
      (current ?? const UserState()).copyWith(profile: updated),
    );
  }

  Future<void> setUserDescription(String? description) async {
    final current = state.maybeWhen(data: (s) => s, orElse: () => null);
    final updated = (current?.profile ?? const UserProfile()).copyWith(
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
    final updated = (current?.profile ?? const UserProfile()).copyWith(
      loggedIn: value,
    );
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
    final updated = (current?.profile ?? const UserProfile()).copyWith(
      loggedIn: false,
      name: null,
      email: null,
    );
    state = AsyncValue.data(
      (current ?? const UserState()).copyWith(profile: updated),
    );
  }

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

    await FirebaseFirestore.instance
        .collection('user_progress')
        .doc(userId)
        .set(updated.toJson());
    state = AsyncValue.data(
      (current ?? const UserState()).copyWith(progress: updated),
    );
  }

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

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserState>>(
  (ref) {
    return UserNotifier(PersistenceService());
  },
);

final currentUserProvider = Provider<User?>((ref) {
  final av = ref.watch(userProvider);
  return av.maybeWhen(data: (s) => s.profile, orElse: () => null);
});
