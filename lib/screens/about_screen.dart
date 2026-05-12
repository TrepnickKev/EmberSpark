import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/update_service.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  static const _btcAddress = '3P7XsSqDJjJ5fCtcwSdiatrFFyq28aCZVJ';

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

  Future<void> _copyBtc(BuildContext context) async {
    await Clipboard.setData(
      const ClipboardData(text: AboutScreen._btcAddress),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Image.asset('images/Logo_icon.png', width: 96),
                const SizedBox(height: 12),
                const Text(
                  'EmberSpark',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'A small Lightning wallet for LNbits',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  '© 2026 Trepnick Solutions',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildVersionCard(),
          const SizedBox(height: 16),
          _buildDonateCard(context),
          const SizedBox(height: 16),
          _buildLicensesCard(context),
        ],
      ),
    );
  }

  Widget _buildVersionCard() {
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
                  i == null ? 'Version' : 'v${i.current}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (!checking)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Check again',
                    onPressed: _check,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _buildVersionStatus(i),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionStatus(VersionInfo? i) {
    if (checking || i == null) {
      return const Row(
        children: [
          SizedBox(
            height: 14,
            width: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text(
            'Checking for updates…',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }
    if (i.checkFailed) {
      return const Text(
        "Couldn't check for updates",
        style: TextStyle(color: Colors.grey),
      );
    }
    if (i.updateAvailable && i.latest != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              'Update available: v${i.latest}',
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Open release'),
            onPressed: _openRelease,
          ),
        ],
      );
    }
    return const Row(
      children: [
        Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
        SizedBox(width: 8),
        Text('Up to date', style: TextStyle(color: Colors.greenAccent)),
      ],
    );
  }

  Widget _buildDonateCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.favorite, color: Colors.orangeAccent),
                SizedBox(width: 8),
                Text(
                  'Support development',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'EmberSpark is built and maintained in spare time. '
              "If it makes your sats easier to manage, consider tossing "
              'a few on-chain BTC at the address below — every bit keeps '
              'the project alive. Thank you!',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: SelectableText(
                    AboutScreen._btcAddress,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy address',
                  onPressed: () => _copyBtc(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicensesCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.description_outlined),
        title: const Text('Open-source licenses'),
        subtitle: const Text('Flutter SDK and third-party packages'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showLicensePage(
          context: context,
          applicationName: 'EmberSpark',
          applicationVersion: info?.current,
          applicationLegalese: '© 2026 Trepnick Solutions',
          applicationIcon: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset('images/Logo_icon.png', width: 64),
          ),
        ),
      ),
    );
  }
}
