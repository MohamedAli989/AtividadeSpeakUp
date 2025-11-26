// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pprincipal/core/app/app.dart' show AppWithProviders;

// Re-export App and AppWithProviders for backward compatibility with tests
export 'package:pprincipal/core/app/app.dart' show AppWithProviders;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase before running the app.
  try {
    await Firebase.initializeApp();
  } catch (e, st) {
    // If Firebase isn't configured (no firebase_options.dart or platform files),
    // fail gracefully and continue running the app so the rest of the UI is usable.
    // Recommend running `flutterfire configure` to generate platform config.
    // Keep the error visible in logs for debugging.
    // ignore: avoid_print
    print('Warning: Firebase.initializeApp() failed: $e\n$st');
  }

  // Start app inside a ProviderScope so Riverpod listeners work (acceptedTermsProvider).
  runApp(const ProviderScope(child: AppWithProviders()));
}

/// Shim to keep older tests/widgets using `MyApp` working.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) =>
      const ProviderScope(child: AppWithProviders());
}
