// lib/features/5_notifications/domain/usecases/ouvir_contagem_nao_lidas_usecase.dart
import 'dart:async';
import '../repositories/i_notification_repository.dart';

class OuvirContagemNaoLidasUseCase {
  final INotificationRepository repository;

  OuvirContagemNaoLidasUseCase(this.repository);

  Stream<int> call(String userId) {
    return repository.ouvirContagemNaoLidas(userId);
  }
}
