import 'package:flutter/material.dart';
import '../services/http_client_factory.dart';
import '../services/lock_service.dart';
import '../services/price_service.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool? trustUnverified;
  String? currency;
  bool? lockEnabled;
  bool deviceSupportsLock = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      isUnverifiedTlsAllowed(),
      getSelectedCurrency(),
      isLockEnabled(),
      isDeviceSecuritySupported(),
    ]);
    if (!mounted) return;
    setState(() {
      trustUnverified = results[0] as bool;
      currency = results[1] as String;
      lockEnabled = results[2] as bool;
      deviceSupportsLock = results[3] as bool;
    });
  }

  Future<void> _toggleLock(bool next) async {
    if (next) {
      if (!deviceSupportsLock) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Set up a screen lock or biometric on your phone first.',
            ),
          ),
        );
        return;
      }
      // Verify the user can actually authenticate before locking themselves out.
      final ok = await tryAuthenticate(reason: 'Confirm to enable app lock');
      if (!ok) return;
    }
    await setLockEnabled(next);
    if (mounted) setState(() => lockEnabled = next);
  }

  @override
  Widget build(BuildContext context) {
    final tls = trustUnverified;
    final cur = currency;
    final lock = lockEnabled;
    if (tls == null || cur == null || lock == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Display currency'),
            subtitle: const Text('Used for the fiat amount under the balance'),
            trailing: DropdownButton<String>(
              value: cur,
              items: [
                for (final c in supportedCurrencies)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (next) async {
                if (next == null) return;
                await setSelectedCurrency(next);
                if (mounted) setState(() => currency = next);
              },
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Lock app on launch'),
            subtitle: Text(
              deviceSupportsLock
                  ? 'Require biometric or device PIN/pattern to open EmberSpark.'
                  : 'No screen lock is set up on this device. '
                      'Configure one in system settings to enable this option.',
            ),
            value: lock,
            onChanged: deviceSupportsLock ? _toggleLock : null,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Allow unverified HTTPS'),
            subtitle: const Text(
              'Trust self-signed and incomplete-chain certificates. '
              'Required for some hobbyist Lightning servers and '
              '.onion services. Only enable for servers you trust.',
            ),
            value: tls,
            onChanged: (next) async {
              await setUnverifiedTlsAllowed(next);
              if (mounted) setState(() => trustUnverified = next);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
