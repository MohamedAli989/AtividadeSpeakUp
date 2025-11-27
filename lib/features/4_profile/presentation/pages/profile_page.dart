// lib/features/4_profile/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/core/services/persistence_service.dart';
import 'package:pprincipal/features/4_profile/data/dtos/user_dto.dart';
import 'package:pprincipal/core/utils/colors.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  bool _estaCarregando = true;
  bool _salvando = false;
  int? _avatarColorValue;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final persistence = PersistenceService();
    final name = await persistence.getUserName();
    final email = await persistence.getUserEmail();
    final desc = await persistence.getUserDescription();
    final avatar = await persistence.getUserAvatarColor();

    if (mounted) {
      setState(() {
        _nameController.text = name ?? '';
        _emailController.text = email ?? '';
        _descController.text = desc ?? '';
        _avatarColorValue = avatar;
        _estaCarregando = false;
      });
    }
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
    if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
    final regex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    return regex.hasMatch(v) ? null : 'E-mail inválido';
  }

  Future<void> _salvarPerfil() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      final persistence = PersistenceService();
      await persistence.setUserData(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );
      // Also store the full DTO for backward-compatible tests and callers.
      await persistence.setUserDto(
        UserDTO(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          loggedIn: true,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil salvo com sucesso!')),
        );
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _estaCarregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header stack
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Background header
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                      ),

                      // Avatar with white border
                      Positioned(
                        top: 180,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
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
                                    fontSize: 36,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // small edit photo button
                              Positioned(
                                right: 4,
                                bottom: 4,
                                child: Material(
                                  color: Colors.white,
                                  shape: const CircleBorder(),
                                  elevation: 2,
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: _showAvatarOptions,
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 90),

                  // Form body
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Seus Dados',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Nome Completo',
                              filled: true,
                              fillColor: Colors.grey[100],
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: _validateNotEmpty,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'E-mail',
                              filled: true,
                              fillColor: Colors.grey[100],
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: _validateEmail,
                          ),

                          const SizedBox(height: 18),

                          // Statistics row
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: const [
                                            Icon(
                                              Icons.local_fire_department,
                                              color: Colors.orange,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Dias Seguidos'),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          '0',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: const [
                                            Icon(
                                              Icons.flash_on,
                                              color: Colors.yellow,
                                            ),
                                            SizedBox(width: 8),
                                            Text('XP Total'),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          '0',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Save button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _salvando ? null : _salvarPerfil,
                              child: _salvando
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Salvar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

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
