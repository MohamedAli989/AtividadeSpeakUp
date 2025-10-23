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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final svc = PersistenceService();
    final name = await svc.getUserName();
    final email = await svc.getUserEmail();
    if (mounted) {
      setState(() {
        _userName = name;
        _userEmail = email;
      });
    }
  }

  Drawer _buildAppDrawer() {
    final displayName = _userName ?? 'Bem-vindo(a)!';
    final displayEmail = _userEmail ?? 'Edite seu perfil';
    final initial = (_userName?.isNotEmpty == true)
        ? _userName!.trim()[0].toUpperCase()
        : 'S';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(displayName),
            accountEmail: Text(displayEmail),
            currentAccountPicture: CircleAvatar(child: Text(initial)),
            decoration: const BoxDecoration(color: AppColors.primarySlate),
          ),
          Tooltip(
            message: 'Editar seu perfil',
            child: ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar Perfil'),
              subtitle: const Text('Atualize seu nome e e-mail'),
              onTap: () async {
                Navigator.of(context).pop();
                final result = await Navigator.pushNamed(context, '/profile');
                if (result == true) {
                  await _loadUserData();
                }
              },
            ),
          ),
          Tooltip(
            message: 'Gerenciar privacidade e consentimentos',
            child: ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacidade & Consentimentos'),
              subtitle: const Text('Gerenciar consentimentos e apagar dados'),
              onTap: () {
                Navigator.of(context).pop();
                _showPrivacyDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPrivacyDialog() async {
    final svc = PersistenceService();
    bool marketing = await svc.getMarketingConsent();
    bool erasePII = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Privacidade & Consentimentos'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    value: marketing,
                    onChanged: (v) => setState(() => marketing = v ?? false),
                    title: const Text('Consentimento de Marketing'),
                  ),
                  CheckboxListTile(
                    value: erasePII,
                    onChanged: (v) => setState(() => erasePII = v ?? false),
                    title: const Text(
                      'Apagar meus dados pessoais (Nome/E-mail)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Alterar estas opções irá revogar ou conceder o consentimento de marketing e/ou apagar apenas os dados pessoais locais.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Apply changes
                    if (marketing) {
                      await svc.setMarketingConsent(true);
                    } else {
                      await svc.removeMarketingConsent();
                    }
                    if (erasePII) {
                      await svc.removeUserData();
                    }
                    Navigator.pop(context, true);
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      await _loadUserData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configurações de privacidade atualizadas.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
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
