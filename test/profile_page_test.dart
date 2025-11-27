import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pprincipal/features/4_profile/presentation/pages/profile_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ProfilePage saves data and returns to previous screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                    child: const Text('OPEN'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    // Open the ProfilePage
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();

    // Try to save with empty fields -> shows validation (two fields)
    await tester.ensureVisible(find.text('Salvar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Campo obrigatório'), findsNWidgets(2));

    // Fill valid data and save
    await tester.enterText(find.byType(TextFormField).at(0), 'Bob');
    await tester.enterText(find.byType(TextFormField).at(1), 'bob@example.com');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    // SnackBar shown and page popped
    expect(find.text('Perfil salvo com sucesso!'), findsOneWidget);
    // After popping, the OPEN button should be visible again
    expect(find.text('OPEN'), findsOneWidget);
  });
}
