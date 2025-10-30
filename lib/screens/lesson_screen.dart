// lib/screens/lesson_screen.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../services/content_service.dart';
import '../models/phrase.dart';
import '../utils/colors.dart';

class LessonScreen extends StatefulWidget {
  final String lessonId;
  final String title;
  const LessonScreen({super.key, required this.lessonId, required this.title});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  // Audio recorder instance
  final Record _audioRecorder = Record();
  bool _isRecording = false; // control recording state
  String? _audioPath; // last saved audio path
  String? _recordingPhraseId;
  List<Phrase> _phrases = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPhrases();
  }

  Future<void> _loadPhrases() async {
    setState(() {
      _loading = true;
    });
    final svc = ContentService();
    final phrases = await svc.loadPhrasesForLesson(widget.lessonId);
    if (!mounted) return;
    setState(() {
      _phrases = phrases;
      _loading = false;
    });
  }

  Future<void> _handleRecording(Phrase phrase) async {
    final messenger = ScaffoldMessenger.of(context);

    // If currently recording this phrase -> stop
    if (_isRecording && _recordingPhraseId == phrase.id) {
      try {
        final savedPath = await _audioRecorder.stop();
        if (!mounted) return;
        setState(() {
          _isRecording = false;
          _recordingPhraseId = null;
          _audioPath = savedPath;
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text('Gravação salva em ${_audioPath ?? 'desconhecido'}'),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Erro ao salvar gravação.')),
        );
      }
      return;
    }

    // Request permission using permission_handler
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Permissão de microfone necessária.')),
      );
      return;
    }

    // Check Record permission (redundant but safe)
    if (!await _audioRecorder.hasPermission()) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Permissão do gravador negada.')),
      );
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/recording_${phrase.id}_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(path: path, encoder: AudioEncoder.aacLc);
      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _recordingPhraseId = phrase.id;
        _audioPath = path;
      });
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Erro ao iniciar gravação.')),
      );
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _phrases.length,
              itemBuilder: (context, index) {
                final p = _phrases[index];
                final recordingThis =
                    _isRecording && _recordingPhraseId == p.id;
                return ListTile(
                  title: Text(p.text),
                  subtitle: _audioPath != null && _recordingPhraseId == p.id
                      ? Text('Última gravação: ${_audioPath!.split('/').last}')
                      : null,
                  trailing: IconButton(
                    icon: Icon(
                      recordingThis ? Icons.stop : Icons.mic,
                      color: recordingThis
                          ? Colors.red
                          : AppColors.primaryViolet,
                    ),
                    onPressed: () => _handleRecording(p),
                  ),
                );
              },
            ),
    );
  }
}
