import 'package:flutter/material.dart';

/// Mostra um diálogo com ações para um item (Editar / Remover / Fechar).
///
/// - [title]: título do diálogo (por exemplo, nome do item ou 'Ações').
/// - [showProviderFormDialog]: opcional, função que abre o formulário de edição
///   (se disponível). Recebe o [BuildContext] e deve retornar um [Future].
/// - [onEdit]: opcional, callback alternativo para edição quando não houver
///   `showProviderFormDialog` disponível.
/// - [onRemove]: callback obrigatório que realiza a remoção do item (ou delega
///   a um DAO). A confirmação final de remoção é exibida aqui antes de chamar
///   esse callback.
Future<void> showProviderActionsDialog(
  BuildContext context, {
  String? title,
  Future<void> Function(BuildContext context)? showProviderFormDialog,
  Future<void> Function()? onEdit,
  required Future<void> Function() onRemove,
}) async {
  // Diálogo principal com as opções; não-dismissable tocando fora.
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        title: Text(title ?? 'Ações'),
        content: const Text('Escolha uma ação para este item.'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              // Preferir chamar o formulário específico quando fornecido.
              if (showProviderFormDialog != null) {
                await showProviderFormDialog(context);
                return;
              }
              if (onEdit != null) {
                await onEdit();
              }
            },
            child: const Text('Editar'),
          ),
          TextButton(
            onPressed: () async {
              // Fecha o diálogo principal antes de abrir a confirmação.
              Navigator.of(ctx).pop();

              // Pergunta de confirmação (não-dismissable tocando fora).
              final confirm = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (c2) {
                  return AlertDialog(
                    title: const Text('Confirmar remoção'),
                    content: const Text(
                      'Tem certeza que deseja remover este item? Esta ação não pode ser desfeita.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(c2).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(c2).pop(true),
                        child: const Text('Remover'),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                await onRemove();
              }
            },
            child: const Text('Remover'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fechar'),
          ),
        ],
      );
    },
  );
}

/// Exemplo de uso (comentado):
///
/// await showProviderActionsDialog(context,
///   title: 'Fornecedor X',
///   showProviderFormDialog: (ctx) => showProviderFormDialog(ctx, fornecedor),
///   onRemove: () async { await dao.removerFornecedor(fornecedor.id); },
/// );
