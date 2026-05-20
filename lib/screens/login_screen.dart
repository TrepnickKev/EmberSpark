import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/lnbits_service.dart';
import '../services/wallet_account_service.dart';
import 'home_screen.dart';
import 'qr_scan_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.addFlow = false});

  /// True when launched from the Wallets screen to add another wallet.
  /// On save, pops back to the caller (Wallets) instead of replacing to
  /// Home, so the new wallet shows up in the list immediately.
  final bool addFlow;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final urlController = TextEditingController();
  final adminKeyController = TextEditingController();
  String? error;

  @override
  void dispose() {
    urlController.dispose();
    adminKeyController.dispose();
    super.dispose();
  }

  Future<void> _scanInto(TextEditingController target, String title) async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => QrScanScreen(title: title)),
    );
    if (code != null && mounted) {
      target.text = code.trim();
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final admin = adminKeyController.text.trim();
    if (admin.isEmpty) {
      setState(() => error = l10n.loginAdminKeyRequired);
      return;
    }
    final String url;
    try {
      url = LNbitsService.normalizeBaseUrl(urlController.text);
    } on FormatException catch (e) {
      setState(() => error = e.message);
      return;
    }
    final account = await addWallet(url: url, adminKey: admin);
    await setCurrentWalletId(account.id);
    if (!mounted) return;
    if (widget.addFlow) {
      Navigator.pop(context, true);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Widget _scanButton(
    TextEditingController target,
    String tooltip,
    String title,
  ) {
    return IconButton(
      tooltip: tooltip,
      icon: const Icon(Icons.qr_code_scanner),
      onPressed: () => _scanInto(target, title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: urlController,
                keyboardType: TextInputType.url,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: l10n.loginUrlLabel,
                  hintText: l10n.loginUrlHint,
                  suffixIcon: _scanButton(
                    urlController,
                    l10n.commonScanQr,
                    l10n.loginScanUrlTitle,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: adminKeyController,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: l10n.loginAdminKeyLabel,
                  helperText: l10n.loginAdminKeyHelper,
                  suffixIcon: _scanButton(
                    adminKeyController,
                    l10n.commonScanQr,
                    l10n.loginScanAdminTitle,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: Text(l10n.commonSave),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 16),
              Text(
                l10n.loginHint,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
