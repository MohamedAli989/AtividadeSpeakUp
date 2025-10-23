// lib/screens/speakup_home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/colors.dart';
import '../services/content_service.dart';
import '../models/lesson.dart';
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
  List<Lesson> _lessons = [];
  bool _loadingLessons = true;
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
    _loadLessons();
    // ensure provider loads cached user data
    Future.microtask(() => ref.read(userProvider.notifier).load());
    _widgetOptions = <Widget>[
      _buildActivitiesTabContent(),
      const SettingsScreen(),
    ];
  }

  Future<void> _loadLessons() async {
    setState(() => _loadingLessons = true);
    final svc = ContentService();
    try {
      final lessons = await svc.loadLessons();
      if (!mounted) return;
      setState(() {
        _lessons = lessons;
        _loadingLessons = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingLessons = false);
    }
  }

  // Drawer removed - settings moved to SettingsScreen (bottom tab)

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
            child: _loadingLessons
                ? const Center(child: CircularProgressIndicator())
                : _lessons.isEmpty
                ? const Center(child: Text('Nenhuma lição disponível.'))
                : ListView.separated(
                    itemCount: _lessons.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final lesson = _lessons[index];
                      return _buildLessonCard(lesson);
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
}
