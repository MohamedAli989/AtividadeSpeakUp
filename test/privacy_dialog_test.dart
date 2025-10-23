import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pprincipal/main.dart';
import 'package:pprincipal/services/persistence_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Privacy dialog revokes marketing and can erase PII', (
    WidgetTester tester,
  ) async {
    // Set initial prefs: app ready and logged in with user data and marketing consent
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

    // At home
    expect(find.text('Primeiros passos'), findsOneWidget);

    // Open drawer
    final Finder menu = find.byTooltip('Open navigation menu');
    await tester.tap(menu);
    await tester.pumpAndSettle();

    // Open privacy dialog
    await tester.tap(find.text('Privacidade & Consentimentos'));
    await tester.pumpAndSettle();

    // Initially marketing checkbox should be checked
    expect(find.text('Consentimento de Marketing'), findsOneWidget);

    // Uncheck marketing
    await tester.tap(find.byType(CheckboxListTile).at(0));
    await tester.pumpAndSettle();

    // Check erase PII
    await tester.tap(find.byType(CheckboxListTile).at(1));
    await tester.pumpAndSettle();

    // Confirm
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    // Verify changes in PersistenceService
    final svc = PersistenceService();
    expect(await svc.getMarketingConsent(), isFalse);
    expect(await svc.getUserName(), isNull);
    expect(await svc.getUserEmail(), isNull);
  });
}
