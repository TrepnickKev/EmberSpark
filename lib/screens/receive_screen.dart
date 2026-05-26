import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../services/friendly_error.dart';
import '../services/wallet_backend.dart';
import '../services/nfc_service.dart';
import '../services/price_service.dart';
import '../widgets/stacked_action_button.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final amountCtrl = TextEditingController();
  final memoCtrl = TextEditingController();
  String? invoice;
  String? error;
  bool busy = false;

  // Currency selection: 'sats' or one of supportedCurrencies (USD/EUR/...).
  String currency = 'sats';
  // The user's preferred fiat from Settings — used for the sats→fiat preview.
  String displayCurrency = 'USD';
  Map<String, double>? rates;
  bool ratesLoading = true;

  @override
  void initState() {
    super.initState();
    amountCtrl.addListener(_onInputChanged);
    _loadInitial();
  }

  @override
  void dispose() {
    amountCtrl.removeListener(_onInputChanged);
    amountCtrl.dispose();
    memoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    final results = await Future.wait([getBtcRates(), getSelectedCurrency()]);
    if (!mounted) return;
    setState(() {
      rates = results[0] as Map<String, double>?;
      displayCurrency = results[1] as String;
      ratesLoading = false;
    });
  }

  void _onInputChanged() {
    // Re-render the preview as the user types (both directions).
    setState(() {});
  }

  /// Converts the current input to sats, or null if invalid / unparseable.
  int? _resolveSats() {
    final text = amountCtrl.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    if (currency == 'sats') {
      final n = int.tryParse(text);
      return (n != null && n > 0) ? n : null;
    }
    final value = double.tryParse(text);
    final rate = rates?[currency];
    if (value == null || value <= 0 || rate == null || rate <= 0) return null;
    final sats = (value / rate * 100000000).round();
    return sats > 0 ? sats : null;
  }

  /// Computes the fiat (in [displayCurrency]) equivalent of the sat amount
  /// the user is typing, or null if not in sats mode / invalid input / no
  /// rate available.
  double? _resolveFiatPreview() {
    if (currency != 'sats') return null;
    final sats = int.tryParse(amountCtrl.text.trim());
    if (sats == null || sats <= 0) return null;
    final rate = rates?[displayCurrency];
    if (rate == null || rate <= 0) return null;
    return sats / 100000000 * rate;
  }

  Future<void> _create() async {
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context)!;
    final sats = _resolveSats();
    if (sats == null) {
      setState(() => error = l10n.receiveAmountError);
      return;
    }
    setState(() {
      busy = true;
      error = null;
      invoice = null;
    });
    try {
      final WalletBackend svc = await loadWalletBackend();
      final bolt11 = await svc.createInvoice(
        amountSats: sats,
        memo: memoCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => invoice = bolt11);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = friendlyError(AppLocalizations.of(context)!, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _copy() async {
    if (invoice == null) return;
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: invoice!));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.receiveInvoiceCopied)));
  }

  Future<void> _share() async {
    if (invoice == null) return;
    final l10n = AppLocalizations.of(context)!;
    await SharePlus.instance.share(
      ShareParams(text: invoice!, subject: l10n.receiveShareSubject),
    );
  }

  Future<void> _writeNfc() async {
    if (invoice == null) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    NfcSession? session;
    try {
      session = await writeNdefUri(
        'lightning:${invoice!}',
        onSuccess: () {
          if (!mounted) return;
          Navigator.of(context, rootNavigator: true).pop();
          messenger.showSnackBar(SnackBar(content: Text(l10n.nfcWriteSuccess)));
        },
        onError: (_) {
          if (!mounted) return;
          Navigator.of(context, rootNavigator: true).pop();
          messenger.showSnackBar(SnackBar(content: Text(l10n.nfcWriteFailed)));
        },
      );
    } on NfcUnavailable {
      messenger.showSnackBar(SnackBar(content: Text(l10n.nfcUnavailable)));
      return;
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.nfcWriteFailed)));
      return;
    }
    if (!mounted) {
      await session.stop();
      return;
    }
    await _showNfcDialog(session);
  }

  Future<void> _showNfcDialog(NfcSession session) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(l10n.nfcHoldTag)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: Text(l10n.commonCancel),
          ),
        ],
      ),
    );
    // Dialog was popped one way or another — make sure no NFC session is left
    // running.
    await session.stop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSats = currency == 'sats';
    final fiatUnavailable =
        !isSats && (rates == null || rates![currency] == null);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.receiveTitle)),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: amountCtrl,
                        keyboardType: isSats
                            ? TextInputType.number
                            : const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          labelText: l10n.receiveAmount,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: currency,
                      items: [
                        DropdownMenuItem(
                          value: 'sats',
                          child: Text(l10n.receiveCurrencySats),
                        ),
                        for (final c in supportedCurrencies)
                          DropdownMenuItem(value: c, child: Text(c)),
                      ],
                      onChanged: (next) {
                        if (next == null) return;
                        setState(() => currency = next);
                      },
                    ),
                  ],
                ),
                _buildPreview(l10n, isSats, fiatUnavailable),
                TextField(
                  controller: memoCtrl,
                  decoration: InputDecoration(labelText: l10n.receiveMemo),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: busy || fiatUnavailable ? null : _create,
                  child: busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.receiveCreateInvoice),
                ),
                if (error != null) ...[
                  const SizedBox(height: 16),
                  Text(error!, style: const TextStyle(color: Colors.redAccent)),
                ],
                if (invoice != null) ...[
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: QrImageView(
                        data: invoice!,
                        size: 240,
                        backgroundColor: Colors.white,
                        embeddedImage: const AssetImage('images/Logo_icon.png'),
                        embeddedImageStyle: const QrEmbeddedImageStyle(
                          size: Size(48, 48),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      StackedActionButton(
                        icon: Icons.copy,
                        label: l10n.commonCopy,
                        onPressed: _copy,
                      ),
                      StackedActionButton(
                        icon: Icons.ios_share,
                        label: l10n.commonShare,
                        onPressed: _share,
                      ),
                      StackedActionButton(
                        icon: Icons.nfc,
                        label: l10n.commonNfc,
                        onPressed: _writeNfc,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    invoice!,
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(
    AppLocalizations l10n,
    bool isSats,
    bool fiatUnavailable,
  ) {
    if (ratesLoading && !isSats) {
      return const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 14,
            width: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (fiatUnavailable) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          l10n.receiveRatesUnavailable,
          style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
        ),
      );
    }
    if (isSats) {
      final fiat = _resolveFiatPreview();
      if (fiat == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          '≈ ${formatFiat(fiat, displayCurrency)}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      );
    }
    final sats = _resolveSats();
    if (sats == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        l10n.receiveSatsApprox(formatThousands(sats)),
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }
}
