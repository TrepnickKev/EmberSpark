import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../services/bolt11.dart';
import '../services/friendly_error.dart';
import '../services/my_contact_service.dart';
import '../services/payment_feedback.dart';
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

  // The wallet's pinned default identity (reusable receive code) and its
  // value, shown as a static QR above the amount-invoice form. Null when no
  // default is configured.
  MyContactKind? _defaultKind;
  String? _defaultValue;

  // Currency selection: 'sats' or one of supportedCurrencies (USD/EUR/...).
  String currency = 'sats';
  // The user's preferred fiat from Settings — used for the sats→fiat preview.
  String displayCurrency = 'USD';
  Map<String, double>? rates;
  bool ratesLoading = true;

  // Polls the displayed invoice for settlement so we can auto-return to
  // home with the coin-flip when it's paid.
  Timer? _paidPollTimer;

  @override
  void initState() {
    super.initState();
    amountCtrl.addListener(_onInputChanged);
    _loadInitial();
  }

  @override
  void dispose() {
    _paidPollTimer?.cancel();
    amountCtrl.removeListener(_onInputChanged);
    amountCtrl.dispose();
    memoCtrl.dispose();
    super.dispose();
  }

  void _startPaidPolling(String bolt11) {
    _paidPollTimer?.cancel();
    final hash = decodeBolt11(bolt11)?.paymentHash ?? '';
    if (hash.isEmpty) return;
    _paidPollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        final svc = await loadWalletBackend();
        final paid = await svc.isInvoicePaid(hash);
        if (!paid || !mounted) return;
        _paidPollTimer?.cancel();
        signalPaymentSuccess();
        Navigator.popUntil(context, (r) => r.isFirst);
      } catch (_) {
        // Transient poll error — keep trying on the next tick.
      }
    });
  }

  Future<void> _loadInitial() async {
    final results = await Future.wait([getBtcRates(), getSelectedCurrency()]);
    final kind = await getMyDefaultContactKind();
    final lnAddr = await getMyLightningAddress();
    final bolt12 = await getMyBolt12Offer();
    final lnurlp = await getMyLnurlpLink();

    // Prefer the pinned default identity. When none is pinned (or its value
    // is gone), fall back to the highest-priority configured identity, the
    // same order avatarSeedForWallet uses: LN address > BOLT12 > LNURL-pay.
    // The getters already return null for an empty/unset value.
    MyContactKind? resolvedKind;
    String? value;
    if (kind != null) {
      resolvedKind = kind;
      value = switch (kind) {
        MyContactKind.lnAddress => lnAddr,
        MyContactKind.lnurlp => lnurlp,
        MyContactKind.bolt12 => bolt12,
      };
    }
    if (value == null) {
      if (lnAddr != null) {
        resolvedKind = MyContactKind.lnAddress;
        value = lnAddr;
      } else if (bolt12 != null) {
        resolvedKind = MyContactKind.bolt12;
        value = bolt12;
      } else if (lnurlp != null) {
        resolvedKind = MyContactKind.lnurlp;
        value = lnurlp;
      }
    }
    if (!mounted) return;
    setState(() {
      rates = results[0] as Map<String, double>?;
      displayCurrency = results[1] as String;
      _defaultKind = resolvedKind;
      _defaultValue = value;
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
    _paidPollTimer?.cancel();
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
      _startPaidPolling(bolt11);
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

  Future<void> _copyIdentity() async {
    if (_defaultValue == null) return;
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: _defaultValue!));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.myContactCopied)));
  }

  Future<void> _shareIdentity() async {
    if (_defaultValue == null) return;
    final l10n = AppLocalizations.of(context)!;
    await SharePlus.instance.share(
      ShareParams(text: _defaultValue!, subject: l10n.myContactShareSubject),
    );
  }

  Future<void> _writeNfc() async {
    if (invoice == null) return;
    await _writeNfcFor(invoice!);
  }

  Future<void> _writeNfcFor(String value) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    NfcSession? session;
    try {
      session = await writeNdefUri(
        'lightning:$value',
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
                if (invoice == null) _buildIdentitySection(l10n),
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

  String _kindTitle(AppLocalizations l10n, MyContactKind k) => switch (k) {
    MyContactKind.lnAddress => l10n.myContactLnAddressSection,
    MyContactKind.lnurlp => l10n.myContactLnurlpSection,
    MyContactKind.bolt12 => l10n.myContactBolt12Section,
  };

  /// The wallet's pinned default identity rendered as a reusable, amount-less
  /// receive QR above the invoice form. Hidden when no default is configured.
  Widget _buildIdentitySection(AppLocalizations l10n) {
    final value = _defaultValue;
    final kind = _defaultKind;
    if (value == null || kind == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.receiveReusableAddress,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          _kindTitle(l10n, kind),
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: QrImageView(
              data: 'lightning:$value',
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
              onPressed: _copyIdentity,
            ),
            StackedActionButton(
              icon: Icons.ios_share,
              label: l10n.commonShare,
              onPressed: _shareIdentity,
            ),
            StackedActionButton(
              icon: Icons.nfc,
              label: l10n.commonNfc,
              onPressed: () => _writeNfcFor(value),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SelectableText(value, style: const TextStyle(fontSize: 11)),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(),
        ),
      ],
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
          formatFiatApprox(fiat, displayCurrency),
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
