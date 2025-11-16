// lib/features/5_notifications/domain/usecases/remover_notificacao_usecase.dart
// Usecase para remover uma notificação.

import '../repositories/i_app_notification_repository.dart';

class RemoverNotificacaoUseCase {
  final IAppNotificationRepository repository;

  RemoverNotificacaoUseCase(this.repository);

  Future<void> call(String userId, String notificationId) async {
    await repository.remover(userId, notificationId);
  }
}
