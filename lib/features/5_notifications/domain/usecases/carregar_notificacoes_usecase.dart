// lib/features/5_notifications/domain/usecases/carregar_notificacoes_usecase.dart
import '../entities/app_notification.dart';
import '../repositories/i_notification_repository.dart';

class CarregarNotificacoesUseCase {
  final INotificationRepository repository;

  CarregarNotificacoesUseCase(this.repository);

  Future<List<AppNotification>> call(String userId) async {
    return repository.carregarNotificacoes(userId);
  }
}

// (file cleaned; single implementation kept above)
