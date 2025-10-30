import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pprincipal/providers/accepted_terms_provider.dart';

void main() {
  test('AcceptedTermsNotifier persists and updates state', () async {
    // Ensure shared_preferences uses an in-memory mock.
    SharedPreferences.setMockInitialValues({});

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initially should be false (default)
    expect(container.read(acceptedTermsProvider), isFalse);

    // Accept the terms
    await container.read(acceptedTermsProvider.notifier).setAccepted(true);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('acceptedTerms'), isTrue);
    expect(container.read(acceptedTermsProvider), isTrue);
  });
}
