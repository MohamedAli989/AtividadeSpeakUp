// lib/features/5_notifications/presentation/providers/notification_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/5_notifications/domain/usecases/ouvir_contagem_nao_lidas_usecase.dart';
import 'package:pprincipal/features/5_notifications/data/repositories/notification_repository_impl.dart';
import 'package:pprincipal/core/services/persistence_service.dart';
import 'package:pprincipal/features/5_notifications/data/datasources/notification_remote_datasource.dart';

// Provider que expõe o repositório de notificações (INotificationRepository)
final _notificationRepositoryProvider = Provider((ref) {
  final remote = NotificationRemoteDataSource();
  final persistence = PersistenceService();
  return NotificationRepositoryImpl(remote, persistence);
});

final notificacoesNaoLidasUseCaseProvider = Provider((ref) {
  final repo = ref.watch(_notificationRepositoryProvider);
  return OuvirContagemNaoLidasUseCase(repo);
});

final notificacoesNaoLidasProvider = StreamProvider.family<int, String>((
  ref,
  userId,
) {
  final usecase = ref.watch(notificacoesNaoLidasUseCaseProvider);
  return usecase.call(userId);
});
