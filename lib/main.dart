// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/core/app/app.dart' show AppWithProviders;

// Re-export App and AppWithProviders for backward compatibility with tests
export 'package:pprincipal/core/app/app.dart' show AppWithProviders;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
