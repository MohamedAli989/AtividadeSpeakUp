// lib/features/4_profile/presentation/providers/user_settings_notifier.dart
// StateNotifier que gerencia carregamento e edição de UserSettings.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/4_profile/domain/entities/user_settings.dart';
import 'package:pprincipal/features/4_profile/domain/repositories/i_profile_repository.dart';
import 'package:pprincipal/features/4_profile/data/repositories/profile_repository_impl.dart';
import 'package:pprincipal/core/services/persistence_service.dart';

class UserSettingsNotifier extends StateNotifier<AsyncValue<UserSettings>> {
  final IProfileRepository _repository;
  final String userId;

  UserSettingsNotifier(this._repository, {required this.userId})
    : super(const AsyncValue.loading()) {
    carregar();
  }

  Future<void> carregar() async {
    try {
      state = const AsyncValue.loading();
      final s = await _repository.carregarConfiguracoes(userId);
      state = AsyncValue.data(s);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> salvar(UserSettings settings) async {
    try {
      await _repository.salvarConfiguracoes(settings);
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final _userSettingsRepoProvider = Provider<IProfileRepository>((ref) {
  return ProfileRepositoryImpl(PersistenceService());
});

final userSettingsNotifierProvider =
    StateNotifierProvider.family<
      UserSettingsNotifier,
      AsyncValue<UserSettings>,
      String
    >((ref, userId) {
      final repo = ref.watch(_userSettingsRepoProvider);
      return UserSettingsNotifier(repo, userId: userId);
    });
