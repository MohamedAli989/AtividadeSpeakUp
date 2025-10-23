// lib/screens/privacy_screen.dart
import 'package:flutter/material.dart';
// colors unused in this file
import '../services/persistence_service.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _isLoading = true;
  bool _marketingConsent = false;

  @override
  void initState() {
    super.initState();
    _loadConsents();
  }

  Future<void> _loadConsents() async {
    setState(() => _isLoading = true);
    final svc = PersistenceService();
    final marketing = await svc.getMarketingConsent();
    if (!mounted) return;
    setState(() {
      _marketingConsent = marketing;
      _isLoading = false;
    });
  }

  Future<void> _updateMarketingConsent(bool value) async {
    final svc = PersistenceService();
    await svc.setMarketingConsent(value);
    if (!mounted) return;
    setState(() => _marketingConsent = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Consentimento de marketing concedido.'
              : 'Consentimento de marketing revogado.',
        ),
        backgroundColor: value ? Colors.green : Colors.orange,
      ),
    );
  }

  Future<void> _confirmDeleteUserData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar meus dados pessoais'),
        content: const Text(
          'Isso irá apagar o seu nome e e-mail armazenados localmente. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final svc = PersistenceService();
      await svc.removeUserData();
      await svc.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seus dados foram apagados.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacidade e Dados')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Seus Consentimentos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: SwitchListTile(
                    title: const Text('Comunicações de Marketing'),
                    value: _marketingConsent,
                    onChanged: (v) => _updateMarketingConsent(v),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    title: const Text('Termos de Uso e Política'),
                    subtitle: const Text(
                      'Visualizar os Termos e Política de Privacidade',
                    ),
                    onTap: () => Navigator.of(context).pushNamed('/terms'),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'Seus Dados Pessoais',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Seu nome e e-mail são salvos localmente usando SharedPreferences.',
                ),
                const SizedBox(height: 12),
                Card(
                  color: Colors.red.shade50,
                  child: ListTile(
                    leading: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Apagar Meus Dados Pessoais',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: _confirmDeleteUserData,
                  ),
                ),
              ],
            ),
    );
  }
}
