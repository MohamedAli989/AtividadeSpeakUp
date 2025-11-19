import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pprincipal/main.dart';
import 'package:pprincipal/core/services/persistence_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Entrar sets loggedIn and navigates to home', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'seenOnboarding': true,
      'acceptedTerms': true,
    });

    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // On Login screen
    expect(find.text('Acesse o SpeakUp'), findsOneWidget);

    // Fill valid credentials
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    await tester.tap(find.text('Entrar'));

    // Wait for simulated 2s login delay
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Should be at home
    expect(find.text('Próximas Lições'), findsOneWidget);

    // Verify loggedIn in persistence
    final svc = PersistenceService();
    expect(await svc.getLoggedIn(), isTrue);
  });
}
