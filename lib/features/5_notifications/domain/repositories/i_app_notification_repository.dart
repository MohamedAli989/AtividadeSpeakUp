// lib/features/5_notifications/domain/repositories/i_app_notification_repository.dart
// Abstração do repositório para gerenciar notificações da aplicação.

import '../entities/app_notification.dart';

abstract class IAppNotificationRepository {
  /// Carrega todas as notificações do utilizador identificado por [userId].
  Future<List<AppNotification>> carregarTodas(String userId);

  /// Salva/atualiza uma notificação para [userId].
  Future<void> salvar(String userId, AppNotification notificacao);

  /// Remove a notificação com [notificationId] para o [userId].
  Future<void> remover(String userId, String notificationId);
}
