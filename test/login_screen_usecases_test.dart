import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pprincipal/features/2_auth/presentation/pages/login_screen.dart';
import 'package:pprincipal/features/3_content/presentation/pages/speakup_home_screen.dart';
import 'package:pprincipal/providers/user_provider.dart';
import 'package:pprincipal/services/persistence_service.dart';

/// Test helpers: mocks simples (sem dependência externa) para os usecases.
class MockPularLoginUseCase {
  int called = 0;
  Future<void> call() async {
    called += 1;
  }
}

class MockLoginUseCase {
  int called = 0;
  Future<void> call(String email, String password) async {
    called += 1;
  }
}

/// Fake `UserNotifier` que estende `UserNotifier` real para poder ser
/// retornado pela closure exigida por `userProvider.overrideWith(...)`.
class FakeUserNotifier extends UserNotifier {
  final MockPularLoginUseCase mockPular;

  FakeUserNotifier(this.mockPular) : super(PersistenceService()) {
    // override inicial de estado para evitar dependência de load() real
    state = const AsyncValue.data(UserState(profile: User(loggedIn: false)));
  }

  @override
  Future<void> load() async {
    // não faz nada — evita chamadas ao Firestore durante o teste
    return;
  }

  @override
  Future<void> setLoggedIn(bool value) async {
    await mockPular.call();
    await super.setLoggedIn(value);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Pular Login chama PularLoginUseCase e navega para Home', (
    WidgetTester tester,
  ) async {
    // garante SharedPreferences em modo mock
    SharedPreferences.setMockInitialValues({});

    final mockPular = MockPularLoginUseCase();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // substitui o provider de usuário pelo fake que usa o mock
          userProvider.overrideWith((ref) => FakeUserNotifier(mockPular)),
        ],
        child: MaterialApp(
          routes: {'/home': (context) => const SpeakUpHomeScreen()},
          home: const LoginScreen(),
        ),
      ),
    );

    // Toca o botão "Pular Login (para Teste)"
    await tester.tap(find.text('Pular Login (para Teste)'));
    await tester.pumpAndSettle();

    // Dialog aparece; pressione OK para confirmar pular
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Verifica se o mock foi chamado
    expect(mockPular.called, equals(1));

    // Verifica navegação para a tela Home (SpeakUpHomeScreen)
    expect(find.byType(SpeakUpHomeScreen), findsOneWidget);
  });
}
