// lib/features/4_profile/presentation/pages/profile_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pprincipal/core/utils/colors.dart';
import 'package:pprincipal/core/services/persistence_service.dart';
import 'package:pprincipal/features/4_profile/data/repositories/profile_repository_impl.dart';
import 'package:pprincipal/features/4_profile/presentation/providers/user_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final profile = userState.maybeWhen(
      data: (s) => s.profile,
      orElse: () => null,
    );

    if (profile == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = profile.name ?? 'Usuário';
    final email = profile.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.primary,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (_uploading) return;
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (ctx) {
                          return SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Tirar Foto'),
                                  onTap: () {
                                    Navigator.of(ctx).pop();
                                    _pickAndUpload(
                                      ImageSource.camera,
                                      profile.email,
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Escolher da Galeria'),
                                  onTap: () {
                                    Navigator.of(ctx).pop();
                                    _pickAndUpload(
                                      ImageSource.gallery,
                                      profile.email,
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 420),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: CircleAvatar(
                              key: ValueKey(profile.photoUrl ?? name),
                              radius: 60,
                              backgroundColor: AppColors.primary,
                              backgroundImage: profile.photoUrl != null
                                  ? NetworkImage(profile.photoUrl!)
                                        as ImageProvider
                                  : null,
                              child: profile.photoUrl == null
                                  ? Text(
                                      name.isNotEmpty
                                          ? name.substring(0, 1).toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        fontSize: 48,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        if (_uploading)
                          const SizedBox(
                            width: 120,
                            height: 120,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(email, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Statistics (2 cards side by side)
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 8),
                              Text('0 Dias'),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Ofensiva',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.flash_on, color: Colors.yellow),
                              SizedBox(width: 8),
                              Text('0 XP'),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text('Total', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons: Settings
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Configurações'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Ver Progresso Detalhado'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Progresso detalhado: em desenvolvimento'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(ImageSource source, String? userId) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 80,
      );
      if (picked == null) return;
      setState(() => _uploading = true);
      final file = File(picked.path);
      final repo = ProfileRepositoryImpl(PersistenceService());
      final publicUrl = await repo.uploadAvatar(file, userId ?? 'unknown');
      if (!mounted) return;
      if (publicUrl != null) {
        // Persist and update provider state so UI shows the new avatar immediately
        await ref.read(userProvider.notifier).setUserPhotoUrl(publicUrl);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto carregada com sucesso')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao carregar a foto')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao processar a imagem')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }
}
