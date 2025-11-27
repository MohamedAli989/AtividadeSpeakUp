import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pprincipal/features/3_content/presentation/dialogs/provider_actions_dialog.dart';

void main() {
  testWidgets('Diálogo mostra opções Editar/Remover/Fechar e delega ações', (
    WidgetTester tester,
  ) async {
    var editCalled = false;
    var removeCalled = false;

    Future<void> fakeShowForm(BuildContext ctx) async {
      // Simula abrir um formulário de edição.
      editCalled = true;
    }

    Future<void> fakeRemove() async {
      removeCalled = true;
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showProviderActionsDialog(
                      context,
                      title: 'Item X',
                      showProviderFormDialog: fakeShowForm,
                      onRemove: fakeRemove,
                    );
                  },
                  child: const Text('Abrir'),
                ),
              ),
            );
          },
        ),
      ),
    );

    // Abrir o diálogo
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    // Verifica as três opções
    expect(find.text('Editar'), findsOneWidget);
    expect(find.text('Remover'), findsOneWidget);
    expect(find.text('Fechar'), findsOneWidget);

    // Testa Editar delega para showProviderFormDialog
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    expect(editCalled, isTrue);

    // Reabrir
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    // Testa Remover abre confirmação e delega onRemove quando confirmado
    await tester.tap(find.text('Remover'));
    await tester.pumpAndSettle();

    // Confirmação deve aparecer
    expect(find.text('Confirmar remoção'), findsOneWidget);
    expect(
      find.text('Remover'),
      findsWidgets,
    ); // botão na confirmação também existe

    // Pressiona o botão 'Remover' na confirmação
    // Usa the last matching 'Remover' which is inside dialog
    await tester.tap(find.text('Remover').last);
    await tester.pumpAndSettle();
    expect(removeCalled, isTrue);

    // Reabrir e testar Fechar
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Item X'), findsNothing);
  });
}
