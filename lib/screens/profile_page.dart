// lib/screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _descController = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    // Carrega via persistência gerenciada pelo provider
    await ref.read(userProvider.notifier).load();
    final user = ref.read(currentUserProvider);
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
    _descController.text = user?.description ?? '';
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await ref
        .read(userProvider.notifier)
        .setUserData(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
        );
    await ref
        .read(userProvider.notifier)
        .setUserDescription(_descController.text.trim());
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil salvo com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String? _validateNotEmpty(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null;

  String? _validateEmail(String? v) {
    final err = _validateNotEmpty(v);
    if (err != null) return err;
    final value = v!.trim();
    final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    if (!emailRegex.hasMatch(value)) return 'E-mail inválido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo',
                      ),
                      validator: _validateNotEmpty,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Descrição (opcional)',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Seus dados são salvos localmente neste dispositivo e não são compartilhados.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Salvar'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
