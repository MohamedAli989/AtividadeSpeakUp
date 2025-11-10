// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/colors.dart';
import '../providers/user_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _estaCarregando = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
    final email = v.trim();
    final regex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    if (!regex.hasMatch(email)) return 'E-mail inválido';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Campo obrigatório';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _estaCarregando = true);
    await Future.delayed(const Duration(seconds: 2));
    await ref.read(userProvider.notifier).setLoggedIn(true);
    if (!mounted) return;
    setState(() => _estaCarregando = false);
    Navigator.of(context).pushReplacementNamed('/home');
  }

  Future<void> _skipLogin() async {
    // Solicita um nome de exibição para tornar o fluxo de teste mais
    // amigável
    final name = await showDialog<String?>(
      context: context,
      builder: (context) {
        final ctl = TextEditingController();
        return AlertDialog(
          title: const Text('Escolha um nome para teste'),
          content: TextField(
            controller: ctl,
            decoration: const InputDecoration(hintText: 'Nome (opcional)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, ctl.text.trim()),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (name != null && name.isNotEmpty) {
      await ref.read(userProvider.notifier).setUserName(name);
    }

    await ref.read(userProvider.notifier).setLoggedIn(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.mic_rounded,
                          size: 80,
                          color: AppColors.primaryViolet,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Acesse o SpeakUp',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: Icon(Icons.email),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _estaCarregando ? null : _login,
                            icon: _estaCarregando
                                ? const SizedBox.shrink()
                                : const Icon(Icons.login),
                            label: _estaCarregando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Entrar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: TextButton(
                            onPressed: _skipLogin,
                            child: const Text('Pular Login (para Teste)'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
