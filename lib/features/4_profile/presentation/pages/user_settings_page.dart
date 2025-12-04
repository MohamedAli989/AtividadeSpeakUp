import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/4_profile/presentation/providers/user_settings_notifier.dart';
import 'package:pprincipal/features/4_profile/presentation/providers/user_provider.dart';
import 'package:pprincipal/features/4_profile/domain/entities/user_settings.dart';
import 'package:pprincipal/core/utils/colors.dart';

class UserSettingsPage extends ConsumerWidget {
  const UserSettingsPage({super.key});

  static const List<int> _options = [5, 10, 15, 20, 30];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Preferências de Estudo')),
        body: const Center(child: Text('Nenhum utilizador autenticado.')),
      );
    }

    final settingsAsync = ref.watch(
      userSettingsNotifierProvider(user.email ?? user.name ?? ''),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Preferências de Estudo')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro: $e')),
        data: (settings) => _buildContent(context, ref, settings),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    UserSettings settings,
  ) {
    final notifier = ref.read(
      userSettingsNotifierProvider(settings.userId).notifier,
    );

    Future<void> save(UserSettings s) async {
      try {
        await notifier.salvar(s);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Preferências salvas'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao salvar preferências'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: AppColors.primary.withAlpha((0.9 * 255).round()),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Meta diária',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${settings.metaDiariaMinutos} min',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<int>(
                      value: settings.metaDiariaMinutos,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: _options
                          .map(
                            (o) => DropdownMenuItem<int>(
                              value: o,
                              child: Text('$o minutos'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        save(settings.copyWith(metaDiariaMinutos: v));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: settings.horaLembrete != null,
                  title: const Text('Lembretes Diários'),
                  subtitle: Text(settings.horaLembrete ?? 'Desativado'),
                  onChanged: (v) async {
                    final updated = settings.copyWith(
                      horaLembrete: v ? '18:00' : null,
                    );
                    await save(updated);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text('Velocidade de reprodução'),
                  subtitle: Text('${settings.velocidadeReproducao}x'),
                  onTap: () async {
                    final choices = [1.0, 1.25, 1.5];
                    final current = settings.velocidadeReproducao;
                    final next =
                        choices[(choices.indexOf(current) + 1) %
                            choices.length];
                    await save(settings.copyWith(velocidadeReproducao: next));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
