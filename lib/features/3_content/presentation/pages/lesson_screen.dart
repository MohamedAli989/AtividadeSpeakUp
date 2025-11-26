// lib/features/3_content/presentation/pages/lesson_screen.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/3_content/data/datasources/content_remote_datasource.dart';
import 'package:pprincipal/core/services/practice_service.dart';
import 'package:pprincipal/features/3_content/domain/entities/practice_attempt.dart';
import 'package:pprincipal/features/4_profile/presentation/providers/user_provider.dart';
import 'package:pprincipal/features/3_content/domain/entities/phrase.dart';
import 'package:pprincipal/core/utils/colors.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final String title;
  const LessonScreen({super.key, required this.lessonId, required this.title});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  final Record _audioRecorder = Record();
  bool _isRecording = false;
  String? _audioPath;
  String? _recordingPhraseId;
  List<Phrase> _phrases = [];
  bool _loading = true;
  int _selectedPhraseIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPhrases();
  }

  Future<void> _loadPhrases() async {
    setState(() {
      _loading = true;
    });
    final svc = ContentRemoteDataSource();
    final phrases = await svc.loadPhrasesForLesson(widget.lessonId);
    if (!mounted) return;
    setState(() {
      _phrases = phrases;
      _loading = false;
    });
  }

  Future<void> _handleRecording(Phrase phrase) async {
    final messenger = ScaffoldMessenger.of(context);
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
        try {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Analisando sua pronúncia...'),
              duration: Duration(seconds: 2),
            ),
          );
          final user = ref.read(currentUserProvider);
          final userId = user?.email ?? 'anonymous';
          final attempt = PracticeAttempt(
            id: 'pa_${DateTime.now().millisecondsSinceEpoch}',
            userId: userId,
            phraseId: phrase.id,
            lessonId: widget.lessonId,
            audioUrl: _audioPath ?? '',
            timestamp: DateTime.now(),
          );
          final feedback = await PracticeService().saveUserPractice(
            attempt,
            ref,
          );
          if (feedback != null) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  'Prática salva! Sua nota foi: ${feedback.overallScore.round()}%',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Prática salva, mas a análise falhou.'),
              ),
            );
          }
        } catch (e) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Erro ao processar a análise.')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Erro ao salvar gravação.')),
        );
      }
      return;
    }

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Permissão de microfone necessária.')),
      );
      return;
    }

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

  Widget _construirCarregamentoShimmer() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedPhrase = _phrases.isNotEmpty
        ? _phrases[_selectedPhraseIndex]
        : null;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _loading
          ? _construirCarregamentoShimmer()
          : Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        selectedPhrase?.text ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    itemCount: _phrases.length,
                    itemBuilder: (context, index) {
                      final p = _phrases[index];
                      final isSelected = index == _selectedPhraseIndex;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            p.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle:
                              isSelected &&
                                  _audioPath != null &&
                                  _recordingPhraseId == p.id
                              ? Text(
                                  'Última gravação: ${_audioPath!.split('/').last}',
                                )
                              : null,
                          trailing: Icon(
                            isSelected ? Icons.volume_up : Icons.mic_none,
                            color: isSelected ? AppColors.primary : Colors.grey,
                          ),
                          onTap: () {
                            setState(() {
                              _selectedPhraseIndex = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 88),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: _isRecording ? Colors.red : AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(38), blurRadius: 16),
          ],
        ),
        child: IconButton(
          iconSize: 40,
          color: Colors.white,
          icon: Icon(_isRecording ? Icons.stop : Icons.mic),
          onPressed: selectedPhrase == null
              ? null
              : () => _handleRecording(selectedPhrase),
        ),
      ),
    );
  }
}
