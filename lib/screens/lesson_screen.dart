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
  final _recorder = Record();
  String? _recordingPath;
  String? _recordingPhraseId;
  bool _isRecording = false;
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

  Future<void> _toggleRecord(String phraseId) async {
    if (_isRecording && _recordingPhraseId == phraseId) {
      // stop
      await _recorder.stop();
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _recordingPhraseId = null;
      });
      return;
    }

    // request permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão de microfone necessária.')),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final filePath =
        '${dir.path}/${widget.lessonId}_${phraseId}_${DateTime.now().millisecondsSinceEpoch}.m4a';

    try {
      await _recorder.start(path: filePath, encoder: AudioEncoder.aacLc);
      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _recordingPhraseId = phraseId;
        _recordingPath = filePath;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao iniciar gravação.')),
      );
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
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
                  subtitle: _recordingPath != null && _recordingPhraseId == p.id
                      ? Text(
                          'Última gravação: ${_recordingPath!.split('/').last}',
                        )
                      : null,
                  trailing: IconButton(
                    icon: Icon(
                      recordingThis ? Icons.stop : Icons.mic,
                      color: recordingThis
                          ? Colors.red
                          : AppColors.primaryViolet,
                    ),
                    onPressed: () => _toggleRecord(p.id),
                  ),
                );
              },
            ),
    );
  }
}
