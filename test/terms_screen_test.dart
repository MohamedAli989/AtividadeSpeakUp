import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/screens/terms_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'continue button disabled until checkbox checked and persists acceptance',
    (tester) async {
      // Initialize mock shared preferences so PersistenceService writes succeed.
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TermsScreen())),
      );

      // Button should be disabled initially
      final elevatedFinder = find.byType(ElevatedButton);
      expect(elevatedFinder, findsOneWidget);
      final ElevatedButton elevated = tester.widget(elevatedFinder);
      expect(elevated.onPressed, isNull);

      // Tap the checkbox
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      // Now button should be enabled
      final ElevatedButton elevatedAfter = tester.widget(elevatedFinder);
      expect(elevatedAfter.onPressed, isNotNull);

      // Tap the button
      await tester.tap(elevatedFinder);
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('acceptedTerms'), isTrue);
    },
  );
}
