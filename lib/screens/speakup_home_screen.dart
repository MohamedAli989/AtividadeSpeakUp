// lib/screens/speakup_home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/colors.dart';

class SpeakUpHomeScreen extends StatefulWidget {
  const SpeakUpHomeScreen({super.key});

  @override
  State<SpeakUpHomeScreen> createState() => _SpeakUpHomeScreenState();
}

class _SpeakUpHomeScreenState extends State<SpeakUpHomeScreen> {
  bool _isRecording = false;

  Future<void> _handleMicPermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      setState(() => _isRecording = true);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão do microfone negada.')),
      );
    }
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
      ),
      body: Padding(
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
            _buildLessonCard(
              title: 'Saudações',
              subtitle: 'Pratique cumprimentos comuns.',
              icon: Icons.waving_hand,
              color: AppColors.primaryBlue,
            ),
            const Spacer(),
            _buildPracticeCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {}, // Navegaria para a tela da lição
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
