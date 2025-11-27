// Optional minimal API usage: a lightweight fetch will run only when toggled
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pprincipal/features/3_content/data/datasources/content_remote_datasource.dart';
import 'package:pprincipal/features/4_profile/presentation/providers/user_provider.dart';
import 'package:pprincipal/features/3_content/domain/entities/vocabulary_item.dart';
import 'package:pprincipal/features/3_content/presentation/providers/vocabulary_usecase_providers.dart';
import 'package:pprincipal/features/3_content/presentation/providers/vocabulary_providers.dart';
import 'package:pprincipal/features/3_content/domain/entities/language.dart';

class VocabularyPage extends ConsumerStatefulWidget {
  const VocabularyPage({super.key});

  @override
  ConsumerState<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends ConsumerState<VocabularyPage> {
  // Example translations (English -> Portuguese). In production this could
  // be backed by a translation API or the existing vocabulary provider.
  final List<Map<String, String>> _translations = [
    {'en': 'hello', 'pt': 'olá'},
    {'en': 'goodbye', 'pt': 'tchau'},
    {'en': 'please', 'pt': 'por favor'},
    {'en': 'thank you', 'pt': 'obrigado'},
    {'en': 'yes', 'pt': 'sim'},
    {'en': 'no', 'pt': 'não'},
    {'en': 'friend', 'pt': 'amigo'},
    {'en': 'help', 'pt': 'ajuda'},
    {'en': 'morning', 'pt': 'manhã'},
    {'en': 'night', 'pt': 'noite'},
  ];

  late List<bool> _expanded;
  String _selectedInitial = 'All';
  // Minimal API support (optional). Provide an API key via:
  // --dart-define=GOOGLE_TRANSLATE_API_KEY=YOUR_KEY
  static const String _googleApiKey = String.fromEnvironment(
    'GOOGLE_TRANSLATE_API_KEY',
  );
  bool _useApi = false;
  // Prefetch control
  int _lastPrefetchedIndex = -1;
  final int _prefetchBatch = 4;
  // viewport prefetch tuning
  final int _prefetchDistance = 6;
  late ScrollController _scrollController;
  String _targetLanguage = 'pt';
  Map<String, String> _apiTranslations = {};
  // cache TTL (in days)
  static const Duration _cacheTTL = Duration(days: 7);

  @override
  void initState() {
    super.initState();
    _expanded = List<bool>.filled(_translations.length, false);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    // API disabled by default (hidden). Use the refresh action to force a fetch.
    _useApi = false;
    // load cached translations for current language (will validate TTL)
    // Call directly — no need for a post-frame callback.
    _loadCachedTranslations();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.maxScrollExtent <= 0) {
      return;
    }
    // viewport-based prefetch: estimate current visible index and prefetch when
    // we are within `_prefetchDistance` items of the last prefetched index.
    const approxItemHeight = 80.0;
    final currentIndex = (pos.pixels / approxItemHeight).floor();
    if (currentIndex + _prefetchDistance > _lastPrefetchedIndex) {
      _prefetchNextBatch();
    }
    // legacy trigger for near-bottom scrolling
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _prefetchNextBatch();
    }
  }

  Future<void> _prefetchNextBatch() async {
    if (!_useApi) {
      return;
    }
    final start = _lastPrefetchedIndex + 1;
    if (start >= _translations.length) {
      return;
    }
    final end = (start + _prefetchBatch).clamp(0, _translations.length);
    for (var i = start; i < end; i++) {
      final w = _translations[i]['en']!;
      if (!_apiTranslations.containsKey(w)) {
        await _fetchTranslationFor(w);
      }
      _lastPrefetchedIndex = i;
    }
  }

  Future<void> _fetchTranslations() async {
    if (_googleApiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma chave API informada (use --dart-define)'),
        ),
      );
      return;
    }
    try {
      final words = _translations.map((m) => m['en']!).toList();
      final uri = Uri.https(
        'translation.googleapis.com',
        '/language/translate/v2',
        {'key': _googleApiKey, 'target': _targetLanguage, 'source': 'en'},
      );
      final client = HttpClient();
      final req = await client.postUrl(uri);
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.write(jsonEncode({'q': words}));
      final resp = await req.close();
      final body = await resp.transform(utf8.decoder).join();
      final jsonResp = jsonDecode(body) as Map<String, dynamic>?;
      if (jsonResp != null && jsonResp['data'] != null) {
        final translations = (jsonResp['data']['translations'] as List)
            .map((t) => t['translatedText'] as String)
            .toList();
        final map = <String, String>{};
        for (var i = 0; i < words.length; i++) {
          map[words[i]] = translations[i];
        }
        if (mounted) {
          setState(() => _apiTranslations = map);
          await _saveCachedTranslations();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao buscar traduções: $e')),
        );
      }
    }
  }

  Future<void> _fetchTranslationFor(String word) async {
    if (_googleApiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma chave API informada (use --dart-define)'),
        ),
      );
      return;
    }
    try {
      final uri = Uri.https(
        'translation.googleapis.com',
        '/language/translate/v2',
        {'key': _googleApiKey, 'target': _targetLanguage, 'source': 'en'},
      );
      final client = HttpClient();
      final req = await client.postUrl(uri);
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.write(
        jsonEncode({
          'q': [word],
        }),
      );
      final resp = await req.close();
      final body = await resp.transform(utf8.decoder).join();
      final jsonResp = jsonDecode(body) as Map<String, dynamic>?;
      if (jsonResp != null && jsonResp['data'] != null) {
        final translations = (jsonResp['data']['translations'] as List)
            .map((t) => t['translatedText'] as String)
            .toList();
        if (translations.isNotEmpty) {
          if (mounted) {
            setState(() {
              _apiTranslations[word] = translations.first;
              _saveCachedTranslations();
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Falha ao buscar tradução: $e')));
      }
    }
  }

  Future<void> _saveCachedTranslations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'vocab_api_translations_$_targetLanguage';
      await prefs.setString(key, jsonEncode(_apiTranslations));
      await prefs.setInt('${key}_ts', DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  Future<void> _loadCachedTranslations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'vocab_api_translations_$_targetLanguage';
      final tsKey = '${key}_ts';
      final ts = prefs.getInt(tsKey);
      if (ts != null) {
        final saved = DateTime.fromMillisecondsSinceEpoch(ts);
        if (DateTime.now().difference(saved) > _cacheTTL) {
          // cache expired — clear and return
          await prefs.remove(key);
          await prefs.remove(tsKey);
          if (mounted) {
            setState(() => _apiTranslations = {});
          }
          return;
        }
      }
      final raw = prefs.getString(key);
      if (raw != null) {
        final map = Map<String, dynamic>.from(jsonDecode(raw));
        final casted = map.map((k, v) => MapEntry(k, v.toString()));
        if (mounted) {
          setState(() => _apiTranslations = casted);
        }
      }
    } catch (_) {}
  }

  Future<void> _onRefreshTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'vocab_api_translations_$_targetLanguage';
    final tsKey = '${key}_ts';
    await prefs.remove(key);
    await prefs.remove(tsKey);
    if (mounted) {
      setState(() => _apiTranslations = {});
    }
    if (_googleApiKey.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma chave API informada (use --dart-define)'),
          ),
        );
      }
      return;
    }
    // force a bulk fetch and save
    await _fetchTranslations();
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'es':
        return 'Espanhol';
      case 'fr':
        return 'Francês';
      case 'pt':
      default:
        return 'Português';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
        actions: [
          IconButton(
            tooltip: 'Atualizar traduções',
            icon: const Icon(Icons.refresh),
            onPressed: _onRefreshTranslations,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrImportDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        child: Column(
          children: [
            // Top controls: compact popup buttons for filter + language, and API toggle
            Row(
              children: [
                const Text(
                  'Filtro: ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Escolher inicial',
                  initialValue: _selectedInitial,
                  child: OutlinedButton(
                    onPressed: null,
                    child: Text(_selectedInitial),
                  ),
                  onSelected: (v) => setState(() => _selectedInitial = v),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'All', child: Text('All')),
                    ...List.generate(26, (i) {
                      final letter = String.fromCharCode(65 + i);
                      return PopupMenuItem(value: letter, child: Text(letter));
                    }),
                  ],
                ),
                const SizedBox(width: 12),
                const Text('Idioma: '),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Escolher idioma',
                  initialValue: _targetLanguage,
                  child: OutlinedButton(
                    onPressed: null,
                    child: Text(_languageLabel(_targetLanguage)),
                  ),
                  onSelected: (v) => setState(() => _targetLanguage = v),
                  itemBuilder: (ctx) => const [
                    PopupMenuItem(value: 'pt', child: Text('Português')),
                    PopupMenuItem(value: 'es', child: Text('Espanhol')),
                    PopupMenuItem(value: 'fr', child: Text('Francês')),
                  ],
                ),
                const SizedBox(width: 12),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: _filteredTranslations().length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final pair = _filteredTranslations()[index];
                  final globalIndex = _translations.indexWhere(
                    (t) => t['en'] == pair['en'],
                  );
                  final expanded = _expanded[globalIndex];
                  return Dismissible(
                    key: ValueKey(pair['id'] ?? '${pair['en']}_$index'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      final result = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Remover esta palavra?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Remover'),
                            ),
                          ],
                        ),
                      );
                      return result == true;
                    },
                    onDismissed: (direction) {
                      final removedId = pair['id'] ?? '${pair['en']}_$index';
                      final user = ref.read(currentUserProvider);
                      final userId = user?.email ?? 'u1';
                      final removedItem = VocabularyItem(
                        id: removedId,
                        userId: userId,
                        word: pair['en'] ?? '',
                        translation: pair['pt'] ?? '',
                        originalPhraseId: 'swipe',
                      );

                      // remove through notifier (which updates persistence)
                      ref
                          .read(vocabularyListProvider.notifier)
                          .removerItem(removedId);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Palavra removida.'),
                          action: SnackBarAction(
                            label: 'Desfazer',
                            onPressed: () async {
                              final salvar = ref.read(
                                salvarVocabularioUseCaseProvider,
                              );
                              await salvar(removedItem);
                            },
                          ),
                        ),
                      );
                    },
                    child: GestureDetector(
                      onTap: () async {
                        final willExpand = !_expanded[globalIndex];
                        if (willExpand &&
                            _useApi &&
                            !_apiTranslations.containsKey(pair['en']!)) {
                          await _fetchTranslationFor(pair['en']!);
                        }
                        setState(() => _expanded[globalIndex] = willExpand);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(12),
                        height: expanded ? 110 : 68,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: expanded
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: expanded ? 26 : 18,
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                pair['en']!.substring(0, 1).toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pair['en']!,
                                    style: TextStyle(
                                      fontSize: expanded ? 20 : 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _apiTranslations[pair['en']!] ??
                                        pair['pt']!,
                                    style: TextStyle(
                                      fontSize: expanded ? 18 : 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  if (expanded) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Exemplo: "${pair['en']!} everyone" → "${pair['pt']!} a todos"',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Filter is now a DropdownButton at top; helper removed.

  List<Map<String, String>> _filteredTranslations() {
    if (_selectedInitial == 'All') return _translations;
    return _translations
        .where((t) => t['en']!.toUpperCase().startsWith(_selectedInitial))
        .toList();
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
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Importação concluída')),
                        );
                      }
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
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Palavras adicionadas')),
                        );
                      }
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
