// lib/features/4_profile/presentation/pages/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/core/utils/colors.dart';
import 'package:pprincipal/core/presentation/providers/theme_provider.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:pprincipal/core/presentation/widgets/gradient_scaffold.dart';
import 'package:pprincipal/features/4_profile/presentation/providers/user_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final profile = userState.maybeWhen(
      data: (s) => s.profile,
      orElse: () => null,
    );
    final name = profile?.name ?? 'Usuário';
    final email = profile?.email ?? '';

    final themeState = ref.watch(themeProvider);
    final seed = themeState.seedColor;

    return GradientScaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Modern header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontSize: 28),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(email, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/profile_edit'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Geral
          Text('Geral', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Preferências de Estudo'),
            onTap: () => Navigator.pushNamed(context, '/user_settings'),
            dense: true,
          ),
          StatefulBuilder(
            builder: (context, setState) {
              bool notif = false;
              return SwitchListTile(
                value: notif,
                onChanged: (v) {
                  setState(() => notif = v);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notificações: alteração simulada'),
                    ),
                  );
                },
                title: const Text('Notificações'),
                secondary: const Icon(Icons.notifications),
              );
            },
          ),

          const SizedBox(height: 12),

          // Appearance / Palette
          Text('Aparência', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),

          // Palette row: show primary (seed-derived) and a button-like secondary preview
          Builder(
            builder: (ctx) {
              final core = CorePalette.of(seed.toARGB32());
              final primaryColor = Color(core.primary.get(40));
              final secondaryColor = Color(core.secondary.get(40));
              final onSecondary = Theme.of(context).colorScheme.onSecondary;
              return Row(
                children: [
                  // Primary circle
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Secondary button-like pill
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        // Apply the secondary-derived color as the new seed
                        ref
                            .read(themeProvider.notifier)
                            .setColor(secondaryColor);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Paleta aplicada')),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Secondary',
                              style: TextStyle(color: onSecondary),
                            ),
                            const Icon(Icons.palette, color: Colors.white30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          // Theme selector: Sun - Switch - Moon, plus a Default button to set System theme
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Center(
                  child: Switch(
                    value: themeState.mode == ThemeMode.dark,
                    onChanged: (v) {
                      ref
                          .read(themeProvider.notifier)
                          .setMode(v ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.nights_stay_outlined),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () =>
                    ref.read(themeProvider.notifier).setMode(ThemeMode.system),
                child: const Text('Default'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Seed color selector
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                const Text('Cores:'),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: [Colors.green, Colors.purple, Colors.orange].map((
                      c,
                    ) {
                      final selected =
                          themeState.seedColor.toARGB32() == c.toARGB32();
                      return GestureDetector(
                        onTap: () =>
                            ref.read(themeProvider.notifier).setColor(c),
                        child: AnimatedScale(
                          scale: selected ? 1.08 : 1.0,
                          duration: const Duration(milliseconds: 360),
                          curve: Curves.easeInOut,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 360),
                            curve: Curves.easeInOut,
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: selected
                                  ? Border.all(color: Colors.black, width: 2)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(31, 0, 0, 0),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sobre
          Text('Sobre', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Privacidade e Dados'),
            onTap: () => Navigator.pushNamed(context, '/privacy'),
            dense: true,
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Ajuda e Suporte'),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ajuda e Suporte (simulado)')),
            ),
            dense: true,
          ),

          const SizedBox(height: 12),

          // Conta
          Text('Conta', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await ref.read(userProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (r) => false,
                );
              }
            },
            dense: true,
          ),
        ],
      ),
    );
  }
}
