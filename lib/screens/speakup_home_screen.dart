// lib/screens/speakup_home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/colors.dart';
import '../services/content_service.dart';
import '../models/lesson.dart';
import '../models/module.dart';
import '../models/daily_challenge.dart';
import '../providers/user_provider.dart';
import 'lesson_screen.dart';
import 'settings_screen.dart';

class SpeakUpHomeScreen extends ConsumerStatefulWidget {
  const SpeakUpHomeScreen({super.key});

  @override
  ConsumerState<SpeakUpHomeScreen> createState() => _SpeakUpHomeScreenState();
}

class _SpeakUpHomeScreenState extends ConsumerState<SpeakUpHomeScreen> {
  bool _isRecording = false;
  // Dados do home serão carregados via FutureBuilder na aba de atividades.
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
        if (mounted) {
          setState(() => _isRecording = false);
        }
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
    // ensure provider loads cached user data
    Future.microtask(() => ref.read(userProvider.notifier).load());
    _widgetOptions = <Widget>[
      _buildActivitiesTabContent(),
      const SettingsScreen(),
    ];
  }

  Future<Map<String, dynamic>> _fetchHomeData() async {
    final svc = ContentService();
    final languages = await svc.loadLanguages();
    final languageId = languages.isNotEmpty ? languages.first.id : '';
    final modules = await svc.loadModules(languageId);
    final challenge = await svc.getTodaysChallenge(languageId);
    return {
      'languageId': languageId,
      'modules': modules,
      'challenge': challenge,
    };
  }

  // Drawer removido - configurações movidas para a SettingsScreen (aba
  // inferior)

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

  Widget _buildActivitiesTabContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Primeiros passos',
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
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erro ao carregar atividades.'),
                  );
                }
                final data = snapshot.data!;
                final modules = data['modules'] as List<Module>? ?? [];
                final DailyChallenge? challenge =
                    data['challenge'] as DailyChallenge?;

                if (modules.isEmpty) {
                  return const Center(child: Text('Nenhuma lição disponível.'));
                }

                return ListView.separated(
                  itemCount: modules.length + (challenge != null ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    // If challenge exists, show it at top (index 0)
                    if (challenge != null && index == 0) {
                      return _buildDailyChallengeCard(challenge);
                    }
                    final moduleIndex = challenge != null ? index - 1 : index;
                    final module = modules[moduleIndex];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            module.title,
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        FutureBuilder<List<Lesson>>(
                          future: ContentService().loadLessonsForModule(
                            module.id,
                          ),
                          builder: (context, snap) {
                            if (snap.connectionState != ConnectionState.done) {
                              return const SizedBox(
                                height: 48,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
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
          const SizedBox(height: 12),
          _buildPracticeCard(),
          const SizedBox(height: 20),
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
            // Ícone: microfone com check.
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

  Widget _buildDailyChallengeCard(DailyChallenge challenge) {
    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Desafio do dia',
              style: GoogleFonts.lato(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(challenge.title, style: GoogleFonts.lato(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'XP bônus: ${challenge.xpBonus}',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
