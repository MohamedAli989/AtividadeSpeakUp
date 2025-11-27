// Modern Settings screen implemented as a ConsumerWidget per request.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/core/utils/colors.dart';
import 'package:pprincipal/providers/user_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStateAsync = ref.watch(userProvider);
    // Ensure the Settings list is always present so tests and accessibility
    // can find the scrollable content even if the user state is loading/error.
    final user = userStateAsync.maybeWhen(data: (v) => v, orElse: () => null);
    final name = user?.profile?.name ?? 'Usuário';
    final email = user?.profile?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  child: Text(
                    name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        email,
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pushNamed('/profile'),
                  icon: const Icon(Icons.edit, color: Colors.white),
                ),
              ],
            ),
          ),

          // Conta section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Conta',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.person,
            iconBg: Colors.blue.shade50,
            title: 'Dados Pessoais',
            subtitle: 'Nome, E-mail',
            onTap: () => Navigator.of(context).pushNamed('/profile'),
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.tune,
            iconBg: Colors.orange.shade50,
            title: 'Preferências',
            subtitle: 'Meta diária',
            onTap: () => Navigator.of(context).pushNamed('/user_settings'),
          ),

          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Sobre',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.lock,
            iconBg: Colors.green.shade50,
            title: 'Privacidade',
            onTap: () => Navigator.of(context).pushNamed('/privacy'),
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.description,
            iconBg: Colors.grey.shade100,
            title: 'Termos de Uso',
            onTap: () => Navigator.of(context).pushNamed('/terms'),
          ),

          const SizedBox(height: 16),
          // Logout button
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Sair', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await ref.read(userProvider.notifier).logout();
                if (Navigator.of(context).mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (r) => false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: iconBg,
          child: Icon(icon, color: Colors.black54),
        ),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
