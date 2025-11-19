import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pprincipal/main.dart';
import 'package:pprincipal/core/services/persistence_service.dart';

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
    expect(find.text('Próximas Lições'), findsOneWidget);

    // Open Settings tab by tapping the settings icon
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    // Scroll the Settings ListView until 'Privacidade & Consentimentos' is visible and tap it
    await tester.scrollUntilVisible(
      find.text('Privacidade & Consentimentos'),
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacidade & Consentimentos'));
    await tester.pumpAndSettle();

    // Verify the marketing switch exists and is initially checked
    expect(find.text('Comunicações de Marketing'), findsOneWidget);

    // Toggle marketing consent (SwitchListTile)
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    // Tap the 'Apagar Meus Dados Pessoais' ListTile to confirm deletion
    await tester.scrollUntilVisible(
      find.text('Apagar Meus Dados Pessoais'),
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar Meus Dados Pessoais'));
    await tester.pumpAndSettle();

    // In the confirmation dialog press 'Apagar'
    await tester.tap(find.text('Apagar'));
    await tester.pumpAndSettle();

    // Verify changes in PersistenceService
    final svc = PersistenceService();
    expect(await svc.getMarketingConsent(), isFalse);
    expect(await svc.getUserName(), isNull);
    expect(await svc.getUserEmail(), isNull);
  });
}
