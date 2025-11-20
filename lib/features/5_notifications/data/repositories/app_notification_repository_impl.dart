// lib/features/5_notifications/data/repositories/app_notification_repository_impl.dart
// Implementação do repositório de notificações usando PersistenceService.

import 'package:pprincipal/core/services/persistence_service.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/i_app_notification_repository.dart';

class AppNotificationRepositoryImpl implements IAppNotificationRepository {
  final PersistenceService _svc;

  AppNotificationRepositoryImpl(this._svc);

  @override
  Future<List<AppNotification>> carregarTodas(String userId) async {
    final list = await _svc.getAppNotifications(userId);
    return list;
  }

  @override
  Future<void> salvar(String userId, AppNotification notificacao) async {
    await _svc.addAppNotification(userId, notificacao);
  }

  @override
  Future<void> remover(String userId, String notificationId) async {
    await _svc.removeAppNotification(userId, notificationId);
  }
}
