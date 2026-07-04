import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/http_client_factory.dart';
import '../services/language_service.dart';
import '../services/lock_service.dart';
import '../services/price_service.dart';
import '../widgets/stacked_action_button.dart' show bitcoinOrange;
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
  String? language;

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
      getSelectedLanguageCode(),
    ]);
    if (!mounted) return;
    setState(() {
      trustUnverified = results[0] as bool;
      currency = results[1] as String;
      lockEnabled = results[2] as bool;
      deviceSupportsLock = results[3] as bool;
      language = results[4] as String;
    });
  }

  Future<void> _toggleLock(bool next) async {
    final l10n = AppLocalizations.of(context)!;
    if (next) {
      if (!deviceSupportsLock) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.settingsLockNeedSetup)));
        return;
      }
      // Verify the user can actually authenticate before locking themselves out.
      final ok = await tryAuthenticate(reason: l10n.settingsLockConfirmReason);
      if (!ok) return;
    }
    await setLockEnabled(next);
    if (mounted) setState(() => lockEnabled = next);
  }

  /// Settings-tile title in Bitcoin orange.
  Text _title(String text) => Text(
    text,
    style: const TextStyle(color: bitcoinOrange, fontWeight: FontWeight.w500),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tls = trustUnverified;
    final cur = currency;
    final lock = lockEnabled;
    final lang = language;
    if (tls == null || cur == null || lock == null || lang == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.settingsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          children: [
            ListTile(
              title: _title(l10n.settingsLanguage),
              subtitle: Text(l10n.settingsLanguageSubtitle),
              trailing: DropdownButton<String>(
                value: lang,
                items: [
                  DropdownMenuItem(
                    value: 'system',
                    child: Text(l10n.languageSystemDefault),
                  ),
                  const DropdownMenuItem(value: 'en', child: Text('English')),
                  const DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                  const DropdownMenuItem(value: 'es', child: Text('Español')),
                  const DropdownMenuItem(value: 'pt', child: Text('Português')),
                  const DropdownMenuItem(value: 'fr', child: Text('Français')),
                ],
                onChanged: (next) async {
                  if (next == null) return;
                  await setSelectedLanguage(next);
                  if (mounted) setState(() => language = next);
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: _title(l10n.settingsDisplayCurrency),
              subtitle: Text(l10n.settingsDisplayCurrencySubtitle),
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
              title: _title(l10n.settingsLockOnLaunch),
              subtitle: Text(
                deviceSupportsLock
                    ? l10n.settingsLockSubtitleEnabled
                    : l10n.settingsLockSubtitleUnavailable,
              ),
              value: lock,
              onChanged: deviceSupportsLock ? _toggleLock : null,
            ),
            const Divider(),
            SwitchListTile(
              title: _title(l10n.settingsTrustTls),
              subtitle: Text(l10n.settingsTrustTlsSubtitle),
              value: tls,
              onChanged: (next) async {
                await setUnverifiedTlsAllowed(next);
                if (mounted) setState(() => trustUnverified = next);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: _title(l10n.settingsAbout),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
