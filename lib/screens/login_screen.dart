import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/lnbits_service.dart';
import '../services/wallet_account_service.dart';
import 'home_screen.dart';
import 'qr_scan_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.addFlow = false, this.initial});

  /// True when launched from the Wallets screen to add another wallet.
  /// On save, pops back to the caller (Wallets) instead of replacing to
  /// Home, so the new wallet shows up in the list immediately.
  final bool addFlow;

  /// When non-null, the screen is in **edit** mode: controllers pre-fill
  /// from this wallet, the title swaps to "Edit wallet", and Save calls
  /// `updateWallet` instead of `addWallet`. Always pops back on save.
  final WalletAccount? initial;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController nameController;
  late final TextEditingController urlController;
  late final TextEditingController adminKeyController;
  String? error;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initial?.label ?? '');
    urlController = TextEditingController(text: widget.initial?.url ?? '');
    adminKeyController =
        TextEditingController(text: widget.initial?.adminKey ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
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
    final name = nameController.text.trim();
    final labelArg = name.isEmpty ? null : name;
    if (_isEdit) {
      await updateWallet(
        widget.initial!.id,
        url: url,
        adminKey: admin,
        label: labelArg,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      return;
    }
    final account = await addWallet(
      url: url,
      adminKey: admin,
      label: labelArg,
    );
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
      appBar: AppBar(
        title: Text(_isEdit ? l10n.walletsEdit : l10n.loginTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.loginWalletNameLabel,
                  helperText: l10n.loginWalletNameHint,
                ),
              ),
              const SizedBox(height: 12),
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
