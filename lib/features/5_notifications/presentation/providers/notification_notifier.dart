// lib/features/5_notifications/presentation/providers/notification_notifier.dart
// Notifier que gerencia o estado das notificações na UI.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/5_notifications/domain/entities/app_notification.dart';
import 'package:pprincipal/features/5_notifications/domain/repositories/i_app_notification_repository.dart';
import 'package:pprincipal/features/5_notifications/data/repositories/app_notification_repository_impl.dart';
import 'package:pprincipal/services/persistence_service.dart';

class NotificationNotifier
    extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final IAppNotificationRepository _repository;
  final String userId;

  NotificationNotifier(this._repository, {required this.userId})
    : super(const AsyncValue.loading()) {
    carregar();
  }

  Future<void> carregar() async {
    try {
      state = const AsyncValue.loading();
      final list = await _repository.carregarTodas(userId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> adicionar(AppNotification n) async {
    try {
      await _repository.salvar(userId, n);
      await carregar();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> remover(String notificationId) async {
    try {
      await _repository.remover(userId, notificationId);
      await carregar();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> marcarComoLida(String notificationId) async {
    final current = state.maybeWhen(
      data: (s) => s,
      orElse: () => <AppNotification>[],
    );
    final item = current.firstWhere(
      (e) => e.id == notificationId,
      orElse: () => throw Exception('Notificação não encontrada'),
    );
    final updated = item.copyWith(lida: true);
    await adicionar(updated);
  }
}

// Provider privado que cria a implementação do repositório usando PersistenceService.
final _appNotificationRepoProvider = Provider<IAppNotificationRepository>((
  ref,
) {
  return AppNotificationRepositoryImpl(PersistenceService());
});

// StateNotifierProvider.family expõe o NotificationNotifier por userId.
final notificationNotifierProvider =
    StateNotifierProvider.family<
      NotificationNotifier,
      AsyncValue<List<AppNotification>>,
      String
    >((ref, userId) {
      final repo = ref.watch(_appNotificationRepoProvider);
      return NotificationNotifier(repo, userId: userId);
    });
