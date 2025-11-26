// lib/features/5_notifications/presentation/pages/notifications_list_page.dart
// Tela simples que lista notificações e permite ação básica.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/5_notifications/presentation/providers/notification_notifier.dart';
import 'package:pprincipal/features/5_notifications/domain/entities/app_notification.dart';

class NotificationsListPage extends ConsumerWidget {
  final String userId;

  const NotificationsListPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(notificationNotifierProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Cria uma notificação de exemplo
          final nova = AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            titulo: 'Lembrete de prática',
            corpo: 'Hora de praticar por 10 minutos!',
            agendadaPara: null,
          );
          await ref
              .read(notificationNotifierProvider(userId).notifier)
              .adicionar(nova);
        },
        child: const Icon(Icons.add),
      ),
      body: provider.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Nenhuma notificação.'));
          }
          return ListView.builder(
            itemCount: list.length,
            cacheExtent: 400,
            itemBuilder: (context, index) {
              final n = list[index];
              return RepaintBoundary(
                child: ListTile(
                  title: Text(n.titulo),
                  subtitle: Text(n.corpo),
                  trailing: n.lida ? const Icon(Icons.done) : null,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NotificationDetailPage(
                          userId: userId,
                          notificacao: n,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}

class NotificationDetailPage extends ConsumerWidget {
  final String userId;
  final AppNotification notificacao;

  const NotificationDetailPage({
    super.key,
    required this.userId,
    required this.notificacao,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(notificacao.titulo)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notificacao.corpo, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: notificacao.lida
                      ? null
                      : () async {
                          await ref
                              .read(
                                notificationNotifierProvider(userId).notifier,
                              )
                              .marcarComoLida(notificacao.id);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                  child: const Text('Marcar como lida'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(notificationNotifierProvider(userId).notifier)
                        .remover(notificacao.id);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Remover'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
