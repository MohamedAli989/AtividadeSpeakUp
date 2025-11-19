// lib/features/3_content/presentation/pages/speakup_home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pprincipal/core/utils/colors.dart';
import 'package:pprincipal/features/3_content/data/datasources/content_remote_datasource.dart';
import 'package:pprincipal/features/3_content/presentation/dialogs/provider_actions_dialog.dart';
import 'package:pprincipal/features/3_content/domain/entities/lesson.dart';
import 'package:pprincipal/features/3_content/domain/entities/module.dart';
import 'package:pprincipal/features/4_profile/presentation/providers/user_provider.dart';
import 'package:pprincipal/features/3_content/presentation/pages/lesson_screen.dart';
import 'package:pprincipal/features/4_profile/presentation/pages/settings_screen.dart';
import 'package:pprincipal/features/5_notifications/presentation/providers/notification_provider.dart';
import 'package:pprincipal/features/5_notifications/presentation/pages/notifications_list_page.dart';

class SpeakUpHomeScreen extends ConsumerStatefulWidget {
  const SpeakUpHomeScreen({super.key});

  @override
  ConsumerState<SpeakUpHomeScreen> createState() => _SpeakUpHomeScreenState();
}

class _SpeakUpHomeScreenState extends ConsumerState<SpeakUpHomeScreen> {
  bool _isRecording = false;
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions;

  Future<void> _handleMicPermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      if (!mounted) return;
      setState(() {
        _isRecording = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gravando...'),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isRecording = false);
      });
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão do microfone negada.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(userProvider.notifier).load());
    _widgetOptions = <Widget>[
      _buildActivitiesTabContent(),
      const SettingsScreen(),
    ];
  }

  Future<Map<String, dynamic>> _fetchHomeData() async {
    final svc = ContentRemoteDataSource();
    final languages = await svc.loadLanguages();
    final languageId = languages.isNotEmpty ? languages.first.id : '';
    final modules = await svc.loadModules(languageId);
    return {'languageId': languageId, 'modules': modules};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'SpeakUp',
          style: GoogleFonts.lato(
            color: AppColors.primarySlate,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) {
              final user = ref.watch(currentUserProvider);
              final userId = user?.email ?? '';
              final contagemAsync = ref.watch(
                notificacoesNaoLidasProvider(userId),
              );
              return IconButton(
                onPressed: () {
                  if (userId.isEmpty) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NotificationsListPage(userId: userId),
                    ),
                  );
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined),
                    Positioned(
                      right: -6,
                      top: -6,
                      child: contagemAsync.maybeWhen(
                        data: (c) => c > 0
                            ? Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 20,
                                  minHeight: 20,
                                ),
                                child: Center(
                                  child: Text(
                                    c.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        orElse: () => const SizedBox.shrink(),
                        loading: () => Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Atividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Configurações',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _construirCarregamentoShimmer() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActivitiesTabContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPracticeCard(),
          const SizedBox(height: 20),
          Text(
            'Próximas Lições',
            style: GoogleFonts.lato(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primarySlate,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _fetchHomeData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return _construirCarregamentoShimmer();
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erro ao carregar atividades.'),
                  );
                }
                final data = snapshot.data!;
                final modules = data['modules'] as List<Module>? ?? [];
                if (modules.isEmpty) {
                  return const Center(child: Text('Nenhuma lição disponível.'));
                }
                return ListView.builder(
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            module.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        FutureBuilder<List<Lesson>>(
                          future: ContentRemoteDataSource()
                              .loadLessonsForModule(module.id),
                          builder: (context, snap) {
                            if (snap.connectionState != ConnectionState.done) {
                              return _construirCarregamentoShimmer();
                            }
                            final lessons = snap.data ?? [];
                            if (lessons.isEmpty) return const SizedBox.shrink();
                            return Column(
                              children: lessons
                                  .map((l) => _buildLessonCard(l))
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(Lesson lesson) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue,
          child: const Icon(Icons.menu_book, color: Colors.white),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(lesson.subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  LessonScreen(lessonId: lesson.id, title: lesson.title),
            ),
          );
        },
        onLongPress: () async {
          await showProviderActionsDialog(
            context,
            title: lesson.title,
            // Delega a edição para um formulário (exemplo de delegação):
            showProviderFormDialog: (ctx) async {
              // Aqui apenas mostramos um placeholder; em produção passe a
              // função real que abre o formulário de edição.
              await showDialog<void>(
                context: ctx,
                builder: (dctx) => AlertDialog(
                  title: const Text('Editar lição'),
                  content: const Text(
                    'Abrir formulário de edição para a lição.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dctx).pop(),
                      child: const Text('Fechar'),
                    ),
                  ],
                ),
              );
            },
            onRemove: () async {
              // Placeholder de remoção: aqui você deve chamar o DAO/UseCase.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Remoção solicitada')),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPracticeCard() {
    return Card(
      color: AppColors.primarySlate,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Frase guiada para prática:',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '"Hello, how are you today?"',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            FloatingActionButton(
              onPressed: _handleMicPermission,
              backgroundColor: _isRecording
                  ? Colors.green
                  : AppColors.primaryViolet,
              child: Icon(
                _isRecording ? Icons.check : Icons.mic,
                color: AppColors.textLight,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
