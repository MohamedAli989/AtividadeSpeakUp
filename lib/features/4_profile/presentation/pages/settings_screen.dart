// lib/features/4_profile/presentation/pages/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/services/persistence_service.dart';
import 'package:pprincipal/providers/user_provider.dart';
import 'package:pprincipal/features/4_profile/presentation/pages/profile_page.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _descController = TextEditingController();
  bool _loading = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    await ref.read(userProvider.notifier).load();
    final desc = await PersistenceService().getUserDescription();
    if (!mounted) return;
    _descController.text = desc ?? '';
    setState(() => _loading = false);
  }

  Future<void> _saveDescription() async {
    final messenger = ScaffoldMessenger.of(context);
    await PersistenceService().setUserDescription(_descController.text.trim());
    if (!mounted) return;
    setState(() => _saved = true);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Descrição salva.'),
        backgroundColor: Colors.green,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _saved = false);
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: const [
                      Icon(Icons.tab),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Abas disponíveis: Atividades • Configurações',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Usuário',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Texto provisório abaixo do nome (descrição rápida).',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfilePage(),
                              ),
                            );
                            if (result == true) {
                              await ref.read(userProvider.notifier).load();
                            }
                          },
                          child: const Text(
                            'Visualizar / Editar informações básicas',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Descrição pessoal (opcional):',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Escreva uma breve descrição sobre você',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _saveDescription,
                            child: const Text('Salvar descrição'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              _descController.text = '';
                            },
                            child: const Text('Limpar'),
                          ),
                          const SizedBox(width: 12),
                          if (_saved)
                            Row(
                              children: const [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Salvo',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacidade & Consentimentos'),
                onTap: () => Navigator.of(context).pushNamed('/privacy'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Sobre o aplicativo'),
                subtitle: const Text('Versão de exemplo'),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () async {
                  final svc = PersistenceService();
                  final navigator = Navigator.of(context);
                  await svc.logout();
                  if (!mounted) return;
                  navigator.pushNamedAndRemoveUntil('/login', (r) => false);
                },
              ),
            ],
          );
  }
}
