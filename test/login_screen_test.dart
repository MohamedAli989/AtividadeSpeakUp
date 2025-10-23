import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pprincipal/screens/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LoginScreen validation and skip login navigation', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          routes: {'/home': (context) => const Scaffold(body: Text('HOME'))},
          home: const LoginScreen(),
        ),
      ),
    );

    // Empty submit shows validation errors
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Campo obrigatório'), findsNWidgets(2));

    // Fill invalid email and short password
    await tester.enterText(find.byType(TextFormField).at(0), 'invalid');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('E-mail inválido'), findsOneWidget);
    expect(find.text('Mínimo 6 caracteres'), findsOneWidget);

    // Now use skip login and expect to navigate to /home
    await tester.tap(find.text('Pular Login (para Teste)'));
    await tester.pumpAndSettle();
    // Dialog appears; press OK to continue
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });
}
