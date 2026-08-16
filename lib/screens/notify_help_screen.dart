import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../widgets/stacked_action_button.dart' show bitcoinOrange;

/// Advanced help for self-hosters who want instant push instead of the built-in
/// periodic background poll: wire an LNbits payment to a self-hosted ntfy topic.
class NotifyHelpScreen extends StatelessWidget {
  const NotifyHelpScreen({super.key});

  static const _exampleTopic = 'https://ntfy.sh/your-private-topic';

  Future<void> _copyExample(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(const ClipboardData(text: _exampleTopic));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.notifyHelpCopied)));
  }

  Future<void> _openNtfy() async {
    await launchUrl(
      Uri.parse('https://ntfy.sh'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifyHelpTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _card(
              icon: Icons.notifications_active_outlined,
              title: l10n.notifyHelpTitle,
              body: l10n.notifyHelpIntro,
            ),
            const SizedBox(height: 16),
            _card(
              icon: Icons.bolt,
              title: l10n.notifyHelpHowTitle,
              body: l10n.notifyHelpHowBody,
            ),
            const SizedBox(height: 16),
            _stepsCard(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: bitcoinOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }

  Widget _stepsCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist, color: bitcoinOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.notifyHelpStepsTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.notifyHelpStepsBody),
            const SizedBox(height: 16),
            Text(
              l10n.notifyHelpExampleLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
                  child: SelectableText(
                    _exampleTopic,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: l10n.notifyHelpCopied,
                  onPressed: () => _copyExample(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.notifyHelpPrivacyNote,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.notifyHelpCoverageNote,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(l10n.notifyHelpOpenNtfy),
                onPressed: _openNtfy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
