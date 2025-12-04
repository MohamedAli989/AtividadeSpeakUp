// lib/core/presentation/widgets/gradient_scaffold.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/core/presentation/providers/theme_provider.dart';

class GradientScaffold extends ConsumerWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const GradientScaffold({
    super.key,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seed = ref.watch(themeProvider).seedColor;
    final surface = Theme.of(context).colorScheme.surface;
    // create a semi-transparent/tinted version of the seed color using Color.lerp
    final semiSeed =
        Color.lerp(seed, Colors.transparent, 0.5) ?? seed.withAlpha(128);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [semiSeed, surface],
          ),
        ),
        child: body,
      ),
    );
  }
}
