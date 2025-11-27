import 'package:flutter/material.dart';

/// Versão consolidada do diálogo de formulário de provider.
Future<void> showProviderFormDialog(
  BuildContext context, {
  required Map<String, String?> initialValues,
  required Future<void> Function(Map<String, String?>) onSave,
  String title = 'Editar fornecedor',
}) async {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController(
    text: initialValues['nome'] ?? '',
  );
  final contatoController = TextEditingController(
    text: initialValues['contato'] ?? '',
  );
  final enderecoController = TextEditingController(
    text: initialValues['endereco'] ?? '',
  );
  final taxIdController = TextEditingController(
    text: initialValues['taxId'] ?? '',
  );
  final imagemController = TextEditingController(
    text: initialValues['imagemUrl'] ?? '',
  );

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      var loading = false;
      return StatefulBuilder(
        builder: (c, setState) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nomeController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nome obrigatório'
                          : null,
                    ),
                    TextFormField(
                      controller: contatoController,
                      decoration: const InputDecoration(labelText: 'Contato'),
                    ),
                    TextFormField(
                      controller: enderecoController,
                      decoration: const InputDecoration(labelText: 'Endereço'),
                    ),
                    TextFormField(
                      controller: taxIdController,
                      decoration: const InputDecoration(labelText: 'Tax ID'),
                    ),
                    TextFormField(
                      controller: imagemController,
                      decoration: const InputDecoration(
                        labelText: 'URL da imagem',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: loading ? null : () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: loading
                    ? null
                    : () async {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        final payload = {
                          'nome': nomeController.text.trim(),
                          'contato': contatoController.text.trim(),
                          'endereco': enderecoController.text.trim(),
                          'taxId': taxIdController.text.trim(),
                          'imagemUrl': imagemController.text.trim(),
                        };
                        try {
                          setState(() => loading = true);
                          await onSave(payload);
                          if (ctx.mounted) Navigator.of(ctx).pop();
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Alterações salvas com sucesso'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao salvar: $e')),
                            );
                          }
                        } finally {
                          setState(() => loading = false);
                        }
                      },
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Salvar'),
              ),
            ],
          );
        },
      );
    },
  );

  nomeController.dispose();
  contatoController.dispose();
  enderecoController.dispose();
  taxIdController.dispose();
  imagemController.dispose();
}
