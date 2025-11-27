// lib/features/5_notifications/domain/repositories/i_notification_repository.dart
// Interface de repositório conforme solicitado: fornece operações básicas
// para carregar, marcar como lida e ouvir contagem de não-lidas.

import 'dart:async';
import '../entities/app_notification.dart';

abstract class INotificationRepository {
  /// Carrega as notificações do utilizador identificado por [userId].
  Future<List<AppNotification>> carregarNotificacoes(String userId);

  /// Marca a notificação [notificacaoId] como lida.
  Future<void> marcarComoLida(String notificacaoId);

  /// Retorna um stream com a contagem de notificações não-lidas para o
  /// utilizador [userId]. Emite um inteiro sempre que a contagem mudar.
  Stream<int> ouvirContagemNaoLidas(String userId);
}
