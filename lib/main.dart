// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pprincipal/core/app/app.dart' show AppWithProviders;

// Re-export App and AppWithProviders for backward compatibility with tests
export 'package:pprincipal/core/app/app.dart' show AppWithProviders;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment and initialize Supabase
  try {
    await dotenv.load(fileName: '.env');
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  } catch (e, st) {
    // ignore: avoid_print
    print('Warning: Supabase.initialize() failed: $e\n$st');
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
