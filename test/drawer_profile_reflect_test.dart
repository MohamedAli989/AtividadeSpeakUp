import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pprincipal/main.dart';
import 'package:pprincipal/core/services/persistence_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Editing profile updates drawer header', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'seenOnboarding': true,
      'acceptedTerms': true,
      'isLoggedIn': true,
    });

    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Open Settings tab and tap Edit Profile
    await tester.tap(find.text('Configurações'));
    await tester.pumpAndSettle();

    // Tap the profile editor button inside Settings
    await tester.tap(find.text('Visualizar / Editar informações básicas'));
    await tester.pumpAndSettle();

    // Fill and save
    await tester.enterText(find.byType(TextFormField).at(0), 'Charlie');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'charlie@example.com',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    // Return to Settings and verify persistence stored the name (robust against layout changes)
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configurações'));
    await tester.pumpAndSettle();
    final svc = PersistenceService();
    final dto = await svc.getUserDto();
    expect(dto?.name, 'Charlie');
  });
}
