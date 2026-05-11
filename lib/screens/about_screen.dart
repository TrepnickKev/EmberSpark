import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _btcAddress = '3P7XsSqDJjJ5fCtcwSdiatrFFyq28aCZVJ';

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
          const SizedBox(height: 32),
          Card(
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
                          _btcAddress,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy address',
                        onPressed: () => _copy(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Open-source licenses'),
              subtitle: const Text(
                'Flutter SDK and third-party packages',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'EmberSpark',
                applicationLegalese: '© 2026 Trepnick Solutions',
                applicationIcon: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('images/Logo_icon.png', width: 64),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _btcAddress));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address copied')),
    );
  }
}
