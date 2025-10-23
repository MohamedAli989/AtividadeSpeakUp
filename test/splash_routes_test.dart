import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pprincipal/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Splash navigates to Onboarding when not seen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'seenOnboarding': false});

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // splash visible
    expect(find.text('SpeakUp'), findsOneWidget);

    // wait for splash delay and navigation
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Onboarding screen contains welcome text
    expect(find.textContaining('Bem-vindo ao SpeakUp!'), findsOneWidget);
  });

  testWidgets(
    'Splash navigates to Terms when onboarding seen but terms not accepted',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'seenOnboarding': true,
        'acceptedTerms': false,
      });

      await tester.pumpWidget(const MyApp());
      await tester.pump();

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Terms screen AppBar title
      expect(find.text('Termos de Uso e LGPD'), findsOneWidget);
    },
  );
}
