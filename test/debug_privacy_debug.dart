import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pprincipal/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('debug dump after opening settings', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'seenOnboarding': true,
      'acceptedTerms': true,
      'isLoggedIn': true,
      'userName': 'TestUser',
      'userEmail': 'test@example.com',
      'acceptedMarketing': true,
    });

    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Próximas Lições'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Dump widget tree to console for inspection
    debugDumpApp();
  });
}
