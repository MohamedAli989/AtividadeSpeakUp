import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pprincipal/main.dart';
import 'package:pprincipal/core/services/persistence_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Full app flow: splash -> login -> skip -> home -> drawer -> logout',
    (WidgetTester tester) async {
      // Start with onboarding and terms already seen, not logged in
      SharedPreferences.setMockInitialValues({
        'seenOnboarding': true,
        'acceptedTerms': true,
        // loggedIn not set or false
      });

      await tester.pumpWidget(const MyApp());

      // Splash shows immediately
      expect(find.text('SpeakUp'), findsOneWidget);
      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);

      // Wait for splash delay and navigation
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // After splash with not logged in, should navigate to LoginScreen
      expect(find.text('Acesse o SpeakUp'), findsOneWidget);

      // Tap 'Pular Login (para Teste)' and confirm the test name dialog
      await tester.tap(find.text('Pular Login (para Teste)'));
      await tester.pumpAndSettle();
      // Dialog appears; press OK without entering a name
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Now we should be at home
      expect(find.text('Primeiros passos'), findsOneWidget);

      // Open Settings tab and tap 'Sair'
      await tester.tap(find.text('Configurações'));
      await tester.pumpAndSettle();

      // Tap 'Sair' in settings
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      // Should be back to LoginScreen
      expect(find.text('Acesse o SpeakUp'), findsOneWidget);

      // Ensure loggedIn state is false
      final svc = PersistenceService();
      expect(await svc.getLoggedIn(), isFalse);
    },
  );
}
