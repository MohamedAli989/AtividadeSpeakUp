import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/3_content/domain/entities/vocabulary_item.dart';

/// Diálogo para editar/ criar um `VocabularyItem`.
///
/// Não realiza persistência por si só — espera um callback `onSave` que
/// persista o item (por exemplo, invocando um UseCase ou um provider).
Future<void> showVocabularyFormDialog(
  BuildContext context, {
  required VocabularyItem item,
  required Future<void> Function(VocabularyItem) onSave,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => VocabularyFormDialog(item: item, onSave: onSave),
  );
}

class VocabularyFormDialog extends ConsumerStatefulWidget {
  final VocabularyItem item;
  final Future<void> Function(VocabularyItem) onSave;

  const VocabularyFormDialog({
    super.key,
    required this.item,
    required this.onSave,
  });

  @override
  VocabularyFormDialogState createState() => VocabularyFormDialogState();
}

class VocabularyFormDialogState extends ConsumerState<VocabularyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _wordCtrl;
  late TextEditingController _translationCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _wordCtrl = TextEditingController(text: widget.item.word);
    _translationCtrl = TextEditingController(text: widget.item.translation);
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _translationCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    final updated = VocabularyItem(
      id: widget.item.id,
      userId: widget.item.userId,
      word: _wordCtrl.text.trim(),
      translation: _translationCtrl.text.trim(),
      originalPhraseId: widget.item.originalPhraseId,
      audioUrl: widget.item.audioUrl,
    );

    try {
      await widget.onSave(updated);
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vocabulário atualizado!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar palavra'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _wordCtrl,
                decoration: const InputDecoration(labelText: 'Palavra'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Campo obrigatório'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _translationCtrl,
                decoration: const InputDecoration(labelText: 'Tradução'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Campo obrigatório'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _loading ? null : _onSave,
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}
