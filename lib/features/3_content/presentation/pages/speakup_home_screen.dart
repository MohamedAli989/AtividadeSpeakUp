import 'package:flutter/material.dart';
// removed google_fonts usage to use system font
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
import 'package:pprincipal/features/3_content/presentation/pages/vocabulary_page.dart';
import 'package:pprincipal/features/4_profile/presentation/pages/settings_screen.dart';
import 'package:pprincipal/features/5_notifications/presentation/pages/notifications_list_page.dart';

class SpeakUpHomeScreen extends ConsumerStatefulWidget {
  const SpeakUpHomeScreen({super.key});

  @override
  ConsumerState<SpeakUpHomeScreen> createState() => _SpeakUpHomeScreenState();
}

class _SpeakUpHomeScreenState extends ConsumerState<SpeakUpHomeScreen> {
  bool _isRecording = false;
  int _selectedIndex = 0;
  // Build options on demand in `build` to avoid using `context` in initState.
  List<Widget> get _widgetOptions => <Widget>[
    _buildActivitiesTabContent(),
    const VocabularyPage(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load user data directly in initState (safe to call read here).
    ref.read(userProvider.notifier).load();
    // Do not build widgets here; they are constructed in `build` via getter.
  }

  Future<void> _handleMicPermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      if (!mounted) {
        return;
      }
      setState(() => _isRecording = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gravando...'),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _isRecording = false);
        }
      });
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão do microfone negada.')),
      );
    }
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Future<Map<String, dynamic>> _fetchHomeData() async {
    final svc = ContentRemoteDataSource();
    final languages = await svc.loadLanguages();
    final languageId = languages.isNotEmpty ? languages.first.id : '';
    final modules = await svc.loadModules(languageId);
    return {'languageId': languageId, 'modules': modules};
  }

  Widget _construirCarregamentoShimmer() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(width: 220, padding: const EdgeInsets.all(12.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildActivitiesHorizontalBar() {
    final eng = ['Introdução', 'Saudações', 'Perguntas'];
    final esp = ['Introducción', 'Saludos', 'Preguntas'];

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        children: [miniCard('Inglês', eng), miniCard('Espanhol', esp)],
      ),
    );
  }

  Widget miniCard(String title, List<String> items) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12.0),
      child: Card(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                ...items
                    .take(3)
                    .map(
                      (e) =>
                          Text(e, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
              ],
            ),
          ),
        ),
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
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                LessonScreen(lessonId: lesson.id, title: lesson.title),
          ),
        ),
        onLongPress: () async {
          await showProviderActionsDialog(
            context,
            title: lesson.title,
            showProviderFormDialog: (ctx) async {
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
      elevation: 8,
      color: AppColors.primarySlate,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Lição atual',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              '"Hello, how are you today?"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton.small(
              heroTag: 'practice_mic',
              onPressed: _handleMicPermission,
              backgroundColor: _isRecording
                  ? Colors.green
                  : AppColors.primaryViolet,
              child: Icon(
                _isRecording ? Icons.check : Icons.mic,
                color: AppColors.textLight,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesTabContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalBar = _buildActivitiesHorizontalBar();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                color: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  'Resumo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -8),
                child: _buildPracticeCard(),
              ),
              const SizedBox(height: 28),
              Text(
                'Próximas Lições',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primarySlate,
                ),
              ),
              const SizedBox(height: 12),
              horizontalBar,
              const SizedBox(height: 12),
              FutureBuilder<Map<String, dynamic>>(
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
                    return const Center(
                      child: Text('Nenhuma lição disponível.'),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                              if (snap.connectionState !=
                                  ConnectionState.done) {
                                return _construirCarregamentoShimmer();
                              }
                              final lessons = snap.data ?? [];
                              if (lessons.isEmpty) {
                                return const SizedBox.shrink();
                              }
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
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Text('SpeakUp', style: newMethod()),
              backgroundColor: Colors.white,
              elevation: 1,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    final user = ref.read(currentUserProvider);
                    final userId = user?.email ?? '';
                    if (userId.isEmpty) {
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NotificationsListPage(userId: userId),
                      ),
                    );
                  },
                ),
              ],
            )
          : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _onItemTapped(0),
              ),
              title: Text(
                _selectedIndex == 1 ? 'Vocabulário' : 'Configurações',
              ),
              backgroundColor: AppColors.surface,
              elevation: 0,
            ),
      body: _widgetOptions.elementAt(
        _selectedIndex < _widgetOptions.length ? _selectedIndex : 0,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Atividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Vocabulário',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  TextStyle newMethod() {
    return const TextStyle(
      color: AppColors.primarySlate,
      fontWeight: FontWeight.bold,
    );
  }
}
