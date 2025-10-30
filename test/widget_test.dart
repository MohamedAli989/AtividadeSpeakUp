// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pprincipal/screens/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SplashScreen shows app title and icon', (
    WidgetTester tester,
  ) async {
    // Provide mock SharedPreferences to avoid platform channel issues
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SplashScreen(),
          routes: {
            '/onboarding': (context) =>
                Scaffold(body: Center(child: Text('onboarding'))),
            '/terms': (context) => Scaffold(body: Center(child: Text('terms'))),
            '/login': (context) => Scaffold(body: Center(child: Text('login'))),
            '/home': (context) => Scaffold(body: Center(child: Text('home'))),
          },
        ),
      ),
    );
    await tester.pump();

    // Verify splash content is present immediately
    expect(find.text('SpeakUp'), findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);

    // Let the 2s splash delay run to completion so no timers remain pending
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
