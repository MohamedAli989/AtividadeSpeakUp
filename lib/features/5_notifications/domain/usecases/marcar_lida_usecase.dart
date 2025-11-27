// lib/features/5_notifications/domain/usecases/marcar_lida_usecase.dart
import '../repositories/i_notification_repository.dart';

class MarcarLidaUseCase {
  final INotificationRepository repository;

  MarcarLidaUseCase(this.repository);

  Future<void> call(String notificacaoId) async {
    return repository.marcarComoLida(notificacaoId);
  }
}
