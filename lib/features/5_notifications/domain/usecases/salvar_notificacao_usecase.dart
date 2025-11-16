// lib/features/5_notifications/domain/usecases/salvar_notificacao_usecase.dart
// Usecase para salvar/atualizar uma notificação.

import '../repositories/i_app_notification_repository.dart';
import '../entities/app_notification.dart';

class SalvarNotificacaoUseCase {
  final IAppNotificationRepository repository;

  SalvarNotificacaoUseCase(this.repository);

  Future<void> call(String userId, AppNotification notificacao) async {
    await repository.salvar(userId, notificacao);
  }
}
