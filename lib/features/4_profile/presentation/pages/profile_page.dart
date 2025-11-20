// lib/features/4_profile/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pprincipal/providers/user_provider.dart';
import 'package:pprincipal/core/services/persistence_service.dart';
import 'package:pprincipal/core/utils/colors.dart';

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
  bool _estaCarregando = true;
  bool _salvando = false;

  int? _avatarColorValue;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    setState(() => _estaCarregando = true);
    await ref.read(userProvider.notifier).load();
    final user = ref.read(currentUserProvider);
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
    _descController.text = user?.description ?? '';
    // load avatar color (if user previously chose)
    try {
      final c = await PersistenceService().getUserAvatarColor();
      if (mounted) {
        setState(() => _avatarColorValue = c);
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _estaCarregando = false);
    }
  }

  Future<void> _salvarPerfil() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _salvando = true);
    await ref
        .read(userProvider.notifier)
        .setUserData(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
        );
    await ref
        .read(userProvider.notifier)
        .setUserDescription(_descController.text.trim());
    if (!mounted) {
      return;
    }
    setState(() => _salvando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil salvo com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context, true);
  }

  Future<void> _salvarDescricao() async {
    setState(() => _salvando = true);
    await ref
        .read(userProvider.notifier)
        .setUserDescription(_descController.text.trim());
    if (!mounted) {
      return;
    }
    setState(() => _salvando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Descrição salva com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
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
      backgroundColor: Colors.grey.shade100,
      body: _estaCarregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Top gradient + avatar stack
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF7B61FF), Color(0xFFD65BFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 28,
                        left: 8,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                      Positioned(
                        top: 66,
                        child: GestureDetector(
                          onTap: _showAvatarOptions,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 36,
                              backgroundColor: Color(
                                _avatarColorValue ??
                                    AppColors.primaryBlue.toARGB32(),
                              ),
                              child: Text(
                                (_nameController.text.isNotEmpty
                                        ? _nameController.text.substring(0, 1)
                                        : 'U')
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Move the editable form up so Save is immediately accessible in tests
                  Padding(
                    padding: const EdgeInsets.all(12.0),
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
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _emailController,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _descController,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'Descrição (opcional)',
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),
                          const Center(
                            child: Text(
                              'Seus dados são salvos localmente neste dispositivo e não são compartilhados.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                              onPressed: _salvando ? null : _salvarPerfil,
                              child: _salvando
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Salvar'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // subtle divider between editable form and public profile card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(color: Colors.grey.shade300, height: 24),
                  ),

                  // White card with name, subtitle and quick actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      margin: const EdgeInsets.only(top: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    _nameController.text.isNotEmpty
                                        ? _nameController.text
                                        : 'Usuário',
                                    style: GoogleFonts.lato(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Stanford University',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _quickAction(Icons.timer, '5 Min'),
                                _quickAction(Icons.message, 'Mensagens'),
                                _quickAction(Icons.location_on, 'Local'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  // Replace previous Interests/Friends with simplified profile blocks
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.pink.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Usuário',
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Texto provisório abaixo do nome (descrição rápida).',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      // show same edit form (scroll up) — we simply focus name
                                      // For now, scroll to top by popping and reopening is unnecessary.
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Visualizar / Editar informações básicas',
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      child: Text(
                                        'Visualizar / Editar informações básicas',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Descrição pessoal (opcional):',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 100),
                            child: TextField(
                              controller: _descController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText:
                                    'Escreva uma breve descrição sobre você',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _salvando ? null : _salvarDescricao,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Salvar descrição'),
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () =>
                                  setState(() => _descController.clear()),
                              child: const Text('Limpar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Section list
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.shield_outlined),
                                title: const Text(
                                  'Privacidade & Consentimentos',
                                ),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Abrir Privacidade'),
                                    ),
                                  );
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.info_outline),
                                title: const Text('Sobre o aplicativo'),
                                subtitle: const Text('Versão de exemplo'),
                                onTap: () {},
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.exit_to_app),
                                title: const Text('Sair'),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Saindo...')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _quickAction(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey.shade100,
          child: Icon(icon, color: Colors.black54, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
        ),
      ],
    );
  }

  // (Removed unused interest/friend helper widgets — replaced by simplified UI above.)

  Future<void> _showAvatarOptions() async {
    final colors = [
      AppColors.primaryBlue,
      Colors.pink,
      Colors.green,
      Colors.orange,
      Colors.grey,
    ];
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Escolher cor do avatar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: colors.map((c) {
                  return GestureDetector(
                    onTap: () async {
                      final navigator = Navigator.of(ctx);
                      await PersistenceService().setUserAvatarColor(
                        c.toARGB32(),
                      );
                      if (mounted) {
                        setState(() => _avatarColorValue = c.toARGB32());
                      }
                      navigator.pop();
                    },
                    child: CircleAvatar(backgroundColor: c, radius: 22),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final navigator = Navigator.of(ctx);
                      await PersistenceService().removeUserAvatarColor();
                      if (mounted) {
                        setState(() => _avatarColorValue = null);
                      }
                      navigator.pop();
                    },
                    child: const Text('Remover cor'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Upload de imagem não implementado'),
                        ),
                      );
                    },
                    child: const Text('Upload imagem'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
