// lib/features/5_notifications/data/repositories/notification_repository_impl.dart
// Implementação do repositório de notificações usando Firestore + PersistenceService

import 'package:pprincipal/features/5_notifications/domain/entities/app_notification.dart';
import 'package:pprincipal/features/5_notifications/domain/repositories/i_notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import 'package:pprincipal/core/services/persistence_service.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final NotificationRemoteDataSource _remote;
  final PersistenceService _persistence;

  NotificationRepositoryImpl(this._remote, this._persistence);

  @override
  Future<List<AppNotification>> carregarNotificacoes(String userId) async {
    try {
      return await _remote.fetchNotifications(userId);
    } catch (_) {
      // fallback to local persistence if remote fails
      return await _persistence.getAppNotifications(userId);
    }
  }

  @override
  Future<void> marcarComoLida(String notificacaoId) async {
    // try to mark remote and update local
    final userId = await _persistence.getUserEmail() ?? '';
    if (userId.isEmpty) return;
    await _remote.markAsRead(userId, notificacaoId);
    // local persistence helper will remove or update the flag
    // For simplicity, load, update and save list
    final list = await _persistence.getAppNotifications(userId);
    final updated = list.map((n) {
      if (n.id == notificacaoId) return n.copyWith(isRead: true);
      return n;
    }).toList();
    await _persistence.setAppNotifications(userId, updated);
  }

  @override
  Stream<int> ouvirContagemNaoLidas(String userId) {
    return _remote.watchUnreadCount(userId);
  }
}
