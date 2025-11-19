import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/3_content/presentation/providers/vocabulary_providers.dart';
import 'package:pprincipal/features/3_content/presentation/widgets/vocabulary_list_item.dart';
import 'package:pprincipal/features/3_content/data/datasources/content_remote_datasource.dart';
import 'package:pprincipal/features/4_profile/presentation/providers/user_provider.dart';
import 'package:pprincipal/features/3_content/domain/entities/vocabulary_item.dart';
import 'package:pprincipal/features/3_content/presentation/providers/vocabulary_usecase_providers.dart';
import 'package:pprincipal/features/3_content/domain/entities/language.dart';

class VocabularyPage extends ConsumerWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(vocabularyListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Vocabulários')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrImportDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: items.isEmpty
          ? const Center(child: Text('Nenhum item de vocabulário.'))
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return VocabularyListItem(
                  item: item,
                  onSave: (updated) async {
                    final salvar = ref.read(salvarVocabularioUseCaseProvider);
                    await salvar(updated);
                  },
                );
              },
            ),
    );
  }
}

/// Show the manual add-words sheet (top-level so it can be called from helpers)
void _showAddWordsDialog(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: FutureBuilder<List<Language>>(
          future: ContentRemoteDataSource().loadLanguages(),
          builder: (context, snapshot) {
            final languages = snapshot.data ?? [];
            return _AddWordsSheet(ref: ref, languages: languages);
          },
        ),
      );
    },
  );
}

/// Sheet that asks whether to add manually or import CSV
void _showAddOrImportDialog(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Adicionar manualmente'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showAddWordsDialog(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Importar CSV / Colar texto'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (c) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(c).viewInsets.bottom,
                        left: 16,
                        right: 16,
                        top: 16,
                      ),
                      child: _ImportCsvSheet(ref: ref),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ImportCsvSheet extends StatefulWidget {
  final WidgetRef ref;
  const _ImportCsvSheet({required this.ref});
  @override
  State<_ImportCsvSheet> createState() => _ImportCsvSheetState();
}

class _ImportCsvSheetState extends State<_ImportCsvSheet> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedLanguageId;
  List<Language> _languages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    final langs = await ContentRemoteDataSource().loadLanguages();
    if (!mounted) return;
    setState(() {
      _languages = langs;
      _selectedLanguageId = langs.isNotEmpty ? langs.first.id : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Importar CSV',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_languages.isNotEmpty)
          DropdownButtonFormField<String>(
            initialValue: _selectedLanguageId,
            items: _languages
                .map((l) => DropdownMenuItem(value: l.id, child: Text(l.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedLanguageId = v),
            decoration: const InputDecoration(labelText: 'Escolher idioma'),
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Nenhum idioma disponível — será usado o padrão.'),
          ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.multiline,
          minLines: 6,
          maxLines: 20,
          decoration: const InputDecoration(
            hintText: 'Cole CSV aqui — cada linha: palavra, tradução',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                _controller.text = 'hello,olá\ngoodbye,tchau\nplease,por favor';
              },
              icon: const Icon(Icons.download),
              label: const Text('Exemplo'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      final salvar = widget.ref.read(
                        salvarVocabularioUseCaseProvider,
                      );
                      final user = widget.ref.read(currentUserProvider);
                      final userId = user?.email ?? 'u1';
                      final lines = _controller.text
                          .split(RegExp(r'\r?\n'))
                          .map((l) => l.trim())
                          .where((l) => l.isNotEmpty)
                          .toList();
                      var idx = DateTime.now().millisecondsSinceEpoch;
                      for (final line in lines) {
                        final parts = line.split(RegExp(r'[;,]'));
                        final word = (parts.isNotEmpty ? parts[0].trim() : '')
                            .replaceAll('"', '');
                        final translation =
                            (parts.length > 1 ? parts[1].trim() : '')
                                .replaceAll('"', '');
                        if (word.isEmpty) continue;
                        final item = VocabularyItem(
                          id: 'c${idx++}',
                          userId: userId,
                          word: word,
                          translation: translation,
                          originalPhraseId: 'import',
                        );
                        await salvar(item);
                      }
                      setState(() => _loading = false);
                      if (!mounted) return;
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Importação concluída')),
                        );
                      });
                    },
              child: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Importar'),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _AddWordsSheet extends StatefulWidget {
  final WidgetRef ref;
  final List<Language> languages;

  const _AddWordsSheet({required this.ref, required this.languages});

  @override
  State<_AddWordsSheet> createState() => _AddWordsSheetState();
}

class _AddWordsSheetState extends State<_AddWordsSheet> {
  String? _selectedLanguageId;
  final List<Map<String, String>> _entries = [
    {'word': '', 'translation': ''},
  ];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.languages.isNotEmpty) {
      _selectedLanguageId = widget.languages.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Adicionar palavras',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.languages.isNotEmpty) ...[
          DropdownButtonFormField<String>(
            initialValue: _selectedLanguageId,
            items: widget.languages
                .map((l) => DropdownMenuItem(value: l.id, child: Text(l.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedLanguageId = v),
            decoration: const InputDecoration(labelText: 'Escolher idioma'),
          ),
          const SizedBox(height: 12),
        ] else ...[
          const Text(
            'Nenhum idioma disponível; as palavras serão adicionadas no vocabulário padrão.',
          ),
          const SizedBox(height: 12),
        ],

        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _entries.length,
            itemBuilder: (context, index) {
              final entry = _entries[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: entry['word'],
                        decoration: const InputDecoration(labelText: 'Palavra'),
                        onChanged: (v) => entry['word'] = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: entry['translation'],
                        decoration: const InputDecoration(
                          labelText: 'Tradução',
                        ),
                        onChanged: (v) => entry['translation'] = v,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => setState(() => _entries.removeAt(index)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Row(
          children: [
            TextButton.icon(
              onPressed: () =>
                  setState(() => _entries.add({'word': '', 'translation': ''})),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar outro'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saving
                  ? null
                  : () async {
                      setState(() => _saving = true);
                      final user = widget.ref.read(currentUserProvider);
                      final userId = user?.email ?? 'u1';
                      final salvar = widget.ref.read(
                        salvarVocabularioUseCaseProvider,
                      );
                      var idx = DateTime.now().millisecondsSinceEpoch;
                      for (final e in _entries) {
                        final word = (e['word'] ?? '').trim();
                        final translation = (e['translation'] ?? '').trim();
                        if (word.isEmpty) continue;
                        final item = VocabularyItem(
                          id: 'm${idx++}',
                          userId: userId,
                          word: word,
                          translation: translation,
                          originalPhraseId: 'manual',
                        );
                        await salvar(item);
                      }
                      setState(() => _saving = false);
                      if (!mounted) return;
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Palavras adicionadas')),
                        );
                      });
                    },
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar todos'),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
