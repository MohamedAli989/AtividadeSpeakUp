// lib/features/4_profile/presentation/pages/user_settings_page.dart
// Página para visualizar e editar as configurações do utilizador.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/4_profile/presentation/providers/user_settings_notifier.dart';
import 'package:pprincipal/features/4_profile/domain/entities/user_settings.dart';
import 'package:pprincipal/features/4_profile/presentation/providers/user_provider.dart';

class UserSettingsPage extends ConsumerStatefulWidget {
  const UserSettingsPage({super.key});

  @override
  ConsumerState<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends ConsumerState<UserSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _idiomaCtl = TextEditingController();
  final _metaCtl = TextEditingController();
  final _velCtl = TextEditingController();
  String? _horaLembrete;

  @override
  void dispose() {
    _idiomaCtl.dispose();
    _metaCtl.dispose();
    _velCtl.dispose();
    super.dispose();
  }

  Future<void> _pickHora(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _horaLembrete == null
          ? TimeOfDay.now()
          : TimeOfDay(
              hour: int.parse(_horaLembrete!.split(':')[0]),
              minute: int.parse(_horaLembrete!.split(':')[1]),
            ),
    );
    if (time != null) {
      setState(() {
        _horaLembrete = time.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null || user.email == null) {
      return const Scaffold(
        body: Center(child: Text('Utilizador não encontrado')),
      );
    }
    final userId = user.email!;

    final state = ref.watch(userSettingsNotifierProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações do Utilizador')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro: $e')),
        data: (settings) {
          // Inicializa campos se ainda não preenchidos
          if (_idiomaCtl.text.isEmpty) {
            _idiomaCtl.text = settings.idiomaAtivoId;
          }
          if (_metaCtl.text.isEmpty) {
            _metaCtl.text = settings.metaDiariaMinutos.toString();
          }
          if (_velCtl.text.isEmpty) {
            _velCtl.text = settings.velocidadeReproducao.toString();
          }
          _horaLembrete ??= settings.horaLembrete;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _metaCtl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Meta diária (minutos)',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Informe a meta diária';
                      }
                      final n = int.tryParse(v);
                      if (n == null || n <= 0) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _idiomaCtl,
                    decoration: const InputDecoration(
                      labelText: 'Idioma ativo (ex: en-US)',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Informe o idioma';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _velCtl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Velocidade de reprodução (ex: 1.0)',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Informe a velocidade';
                      }
                      final d = double.tryParse(v.replaceAll(',', '.'));
                      if (d == null || d <= 0) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Hora do lembrete: ${_horaLembrete ?? 'Desativado'}',
                        ),
                      ),
                      TextButton(
                        onPressed: () => _pickHora(context),
                        child: const Text('Escolher'),
                      ),
                      if (_horaLembrete != null)
                        IconButton(
                          onPressed: () => setState(() => _horaLembrete = null),
                          icon: const Icon(Icons.clear),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      final nova = UserSettings(
                        userId: userId,
                        metaDiariaMinutos: int.parse(_metaCtl.text),
                        idiomaAtivoId: _idiomaCtl.text.trim(),
                        velocidadeReproducao: double.parse(
                          _velCtl.text.replaceAll(',', '.'),
                        ),
                        horaLembrete: _horaLembrete,
                      );
                      await ref
                          .read(userSettingsNotifierProvider(userId).notifier)
                          .salvar(nova);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Configurações salvas')),
                        );
                      }
                    },
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
