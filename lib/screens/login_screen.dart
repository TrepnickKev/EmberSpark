import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/http_client_factory.dart';
import '../services/lnbits_service.dart';
import '../services/my_contact_service.dart';
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
  bool _disclaimerShown = false;

  bool get _isEdit => widget.initial != null;

  /// True only for the first-install onboarding instance (no wallet yet), not
  /// when adding another wallet or editing one.
  bool get _isOnboarding => !widget.addFlow && widget.initial == null;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initial?.label ?? '');
    urlController = TextEditingController(text: widget.initial?.url ?? '');
    adminKeyController = TextEditingController(
      text: widget.initial?.adminKey ?? '',
    );
    if (_isOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showDisclaimer());
    }
  }

  /// Sets expectations on first install: EmberSpark is only useful to someone
  /// with their own LNbits server (or given access to one). Shown once over the
  /// setup screen; must be acknowledged.
  Future<void> _showDisclaimer() async {
    if (_disclaimerShown || !mounted) return;
    _disclaimerShown = true;
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.disclaimerTitle),
        content: Text(l10n.disclaimerBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.disclaimerAck),
          ),
        ],
      ),
    );
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
      final connChanged =
          url != widget.initial!.url || admin != widget.initial!.adminKey;
      await updateWallet(
        widget.initial!.id,
        url: url,
        adminKey: admin,
        label: labelArg,
      );
      // Re-detect the Lightning Address only when the connection changed, so a
      // label-only edit doesn't clobber a manually set address.
      if (connChanged) {
        await _importLightningAddress(
          walletId: widget.initial!.id,
          url: url,
          adminKey: admin,
          overwrite: true,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
      return;
    }
    final account = await addWallet(url: url, adminKey: admin, label: labelArg);
    await setCurrentWalletId(account.id);
    await _importLightningAddress(
      walletId: account.id,
      url: url,
      adminKey: admin,
      overwrite: false,
    );
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

  /// Detects an existing Lightning Address for the given wallet: if the server's
  /// lnurlp extension has a pay link with a username, adopt it as that wallet's
  /// Lightning Address so the user doesn't have to type it. Runs when a wallet
  /// is created and when its connection is edited.
  ///
  /// With [overwrite] false (create) it never clobbers an existing value. With
  /// [overwrite] true (connection-changed edit) it replaces the stored address,
  /// and if the now-reachable server has no Lightning Address it clears the
  /// stale one. Bounded and silent on an unreachable server / timeout, which
  /// leaves the stored value untouched.
  Future<void> _importLightningAddress({
    required String walletId,
    required String url,
    required String adminKey,
    required bool overwrite,
  }) async {
    try {
      if (!overwrite &&
          ((await getMyLightningAddressFor(walletId))?.isNotEmpty ?? false)) {
        return;
      }
      final svc = LNbitsService(
        baseUrl: url,
        adminKey: adminKey,
        client: await getHttpClient(),
      );
      List<Map<String, dynamic>> links;
      try {
        links =
            await svc.listLnurlpLinks().timeout(const Duration(seconds: 6));
      } on LnurlpExtensionDisabled {
        links = const []; // reachable server, just no lnurlp extension
      }
      String? username;
      for (final l in links) {
        final u = (l['username'] as String?)?.trim() ?? '';
        if (u.isNotEmpty) {
          username = u;
          break;
        }
      }
      final host = Uri.parse(url).host;
      if (username != null && host.isNotEmpty) {
        await setMyLightningAddressFor(walletId, '$username@$host');
      } else if (overwrite) {
        // Connection changed and the reachable server has no Lightning Address:
        // drop the stale one so the identity reflects the current wallet.
        await setMyLightningAddressFor(walletId, null);
      }
    } catch (_) {
      // Unreachable server / timeout / other: leave the stored value untouched.
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
      appBar: AppBar(title: Text(_isEdit ? l10n.walletsEdit : l10n.loginTitle)),
      body: SafeArea(
        top: false,
        child: Padding(
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
                ElevatedButton(onPressed: _save, child: Text(l10n.commonSave)),
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
      ),
    );
  }
}
