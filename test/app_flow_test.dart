import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pprincipal/main.dart';
import 'package:pprincipal/features/1_onboarding/presentation/pages/onboarding_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App flow: Splash -> Onboarding with empty SharedPreferences', (
    WidgetTester tester,
  ) async {
    // Limpa SharedPreferences para simular primeiro uso
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: AppWithProviders()));

    // Aguarda transições de splash e rotas
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Deve ter navegado para OnboardingScreen
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
