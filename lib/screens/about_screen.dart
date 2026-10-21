import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../services/lightning_router.dart';
import '../services/update_service.dart';
import '../widgets/stacked_action_button.dart' show bitcoinOrange;

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  static const _btcAddress = 'bc1qcvm7vc3cqt3dazjj9pqvxdg0pxuxf3jtdaf5la';
  static const _lnDonation =
      'LNURL1DP68GURN8GHJ7MRWVF5HGUEWW3EX2URWD93KKTNYV5HKCMN4WFK8QTE08969GKTSW5QK9MSC';

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  VersionInfo? info;
  bool checking = true;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() => checking = true);
    final result = await checkForUpdate();
    if (!mounted) return;
    setState(() {
      info = result;
      checking = false;
    });
  }

  Future<void> _openRelease() async {
    final url = info?.releaseUrl;
    if (url == null) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _openGithub() async {
    await launchUrl(
      Uri.parse('https://github.com/TrepnickKev/EmberSpark'),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _openLicense() async {
    await launchUrl(
      Uri.parse('https://github.com/TrepnickKev/EmberSpark/blob/main/LICENSE'),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _copyBtc(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(const ClipboardData(text: AboutScreen._btcAddress));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.aboutAddressCopied)));
  }

  Future<void> _copyLn(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(const ClipboardData(text: AboutScreen._lnDonation));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.aboutAddressCopied)));
  }

  Future<void> _donateLn(BuildContext context) async {
    await routeLightningCode(Navigator.of(context), AboutScreen._lnDonation);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset('images/Logo_icon.png', width: 96),
                  const SizedBox(height: 12),
                  Text(
                    l10n.appTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.aboutTagline,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.aboutCopyright,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  // AGPL "appropriate legal notice": license + no warranty,
                  // tappable to read the full license text.
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: _openLicense,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Text(
                        l10n.aboutLicenseNotice,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildVersionCard(l10n),
            const SizedBox(height: 16),
            _buildDonateCard(context, l10n),
            const SizedBox(height: 16),
            _buildLicensesCard(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionCard(AppLocalizations l10n) {
    final i = info;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 8),
                Text(
                  i == null ? l10n.aboutVersionLabel : 'v${i.current}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (!checking)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: l10n.aboutCheckAgain,
                    onPressed: _check,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _buildVersionStatus(l10n, i),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionStatus(AppLocalizations l10n, VersionInfo? i) {
    if (checking || i == null) {
      return Row(
        children: [
          const SizedBox(
            height: 14,
            width: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text(
            l10n.aboutCheckingForUpdates,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      );
    }
    if (i.managedByStore) {
      return Text(
        l10n.aboutUpdatesViaStore,
        style: const TextStyle(color: Colors.grey),
      );
    }
    if (i.checkFailed) {
      return Text(
        l10n.aboutCheckFailed,
        style: const TextStyle(color: Colors.grey),
      );
    }
    if (i.updateAvailable && i.latest != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              l10n.aboutUpdateAvailable(i.latest!),
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(l10n.aboutOpenRelease),
            onPressed: _openRelease,
          ),
        ],
      );
    }
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
        const SizedBox(width: 8),
        Text(
          l10n.aboutUpToDate,
          style: const TextStyle(color: Colors.greenAccent),
        ),
      ],
    );
  }

  Widget _buildDonateCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.orangeAccent),
                const SizedBox(width: 8),
                Text(
                  l10n.aboutSupportDevelopment,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.aboutSupportBody),
            const SizedBox(height: 16),
            Text(
              l10n.aboutDonateMethods,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _donateLn(context),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: bitcoinOrange, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      AboutScreen._lnDonation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: l10n.aboutCopyAddress,
                    onPressed: () => _copyLn(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.currency_bitcoin,
                  color: bitcoinOrange,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: SelectableText(
                    AboutScreen._btcAddress,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: l10n.aboutCopyAddress,
                  onPressed: () => _copyBtc(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(l10n.aboutContributeOnGithub),
                onPressed: _openGithub,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicensesCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.description_outlined),
        title: Text(l10n.aboutLicensesTitle),
        subtitle: Text(l10n.aboutLicensesSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showLicensePage(
          context: context,
          applicationName: 'EmberSpark',
          applicationVersion: info?.current,
          applicationLegalese:
              '${l10n.aboutCopyright}\n${l10n.aboutLicenseNotice}',
          applicationIcon: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset('images/Logo_icon.png', width: 64),
          ),
        ),
      ),
    );
  }
}
