import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../services/avatar_seed.dart';
import '../services/contact_service.dart' show Contact;
import '../services/friendly_error.dart';
import '../services/wallet_backend.dart';
import '../services/lnurl.dart';
import '../services/lnurl_auth.dart';
import '../services/payment_feedback.dart';
import '../services/price_service.dart';
import '../services/wallet_account_service.dart';
import '../widgets/payment_route_header.dart';
import 'send_screen.dart';

/// Resolves a scanned LNURL or Lightning address and runs the appropriate
/// pay or withdraw flow.
class LnurlActionScreen extends StatefulWidget {
  const LnurlActionScreen({super.key, required this.code, this.fromContact});

  final String code;
  final Contact? fromContact;

  @override
  State<LnurlActionScreen> createState() => _LnurlActionScreenState();
}

class _LnurlActionScreenState extends State<LnurlActionScreen> {
  final amountCtrl = TextEditingController();
  final commentCtrl = TextEditingController();
  LnurlInfo? info;
  String? error;
  String? resolvedUrl;
  // True when we stopped a read-only wallet from paying. The resolved URL /
  // Copy URL block is then irrelevant (not a server problem), so it is hidden.
  bool readOnlyBlocked = false;
  bool busy = true;
  ({String seed, String name})? senderInfo;

  Map<String, double>? rates;
  String displayCurrency = 'USD';
  bool ratesLoading = true;

  // Amount-entry currency for the pay case: 'sats' or a supportedCurrencies
  // code. Lets the user type the amount in fiat and convert to sats.
  String currency = 'sats';

  @override
  void initState() {
    super.initState();
    amountCtrl.addListener(_onAmountChanged);
    _resolve();
    _loadRates();
    if (widget.fromContact != null) {
      _loadSenderInfo();
    }
  }

  Future<void> _loadSenderInfo() async {
    final info = await getOwnAvatarInfo();
    if (mounted && info.seed.isNotEmpty) {
      setState(() => senderInfo = info);
    }
  }

  @override
  void dispose() {
    amountCtrl.removeListener(_onAmountChanged);
    amountCtrl.dispose();
    commentCtrl.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadRates() async {
    final results = await Future.wait([getBtcRates(), getSelectedCurrency()]);
    if (!mounted) return;
    setState(() {
      rates = results[0] as Map<String, double>?;
      displayCurrency = results[1] as String;
      ratesLoading = false;
    });
  }

  Future<void> _resolve() async {
    try {
      final url = widget.code.contains('@')
          ? lightningAddressToUrl(widget.code)
          : decodeLnurl(widget.code);
      resolvedUrl = url;

      // LNURL-auth is detected from the URL's query params (no fetch yet).
      final auth = tryParseLnurlAuth(url);
      if (auth != null) {
        if (!mounted) return;
        setState(() {
          info = auth;
          busy = false;
        });
        return;
      }

      final i = await fetchLnurl(url);
      if (!mounted) return;
      // A read-only wallet cannot pay. Block the LNURL-pay case here, before
      // showing an amount form the user can't submit. Withdraw (Bolt Card /
      // receive) and auth stay available.
      if (i is LnurlPayInfo && ((await getCurrentWallet())?.readOnly ?? false)) {
        if (!mounted) return;
        setState(() {
          error = AppLocalizations.of(context)!.errorReadOnlyWallet;
          readOnlyBlocked = true;
          busy = false;
        });
        return;
      }
      if (!mounted) return;
      setState(() {
        info = i;
        busy = false;
        // Leave the amount blank so it (and the currency) are set manually.
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = friendlyError(AppLocalizations.of(context)!, e);
        busy = false;
      });
    }
  }

  Future<void> _submitAuth(LnurlAuthInfo i) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await performLnurlAuth(i);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.lnurlAuthSuccess(i.host))));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = friendlyError(AppLocalizations.of(context)!, e);
        busy = false;
      });
    }
  }

  Future<void> _submitPay(LnurlPayInfo i) async {
    final l10n = AppLocalizations.of(context)!;
    final sats = _resolveSats();
    if (sats == null || sats <= 0) {
      setState(() => error = l10n.lnurlAmountPositive);
      return;
    }
    final msat = sats * 1000;
    if (msat < i.minSendableMsat || msat > i.maxSendableMsat) {
      setState(
        () => error = l10n.lnurlAmountOutOfRange(
          i.minSendableMsat ~/ 1000,
          i.maxSendableMsat ~/ 1000,
        ),
      );
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final comment = commentCtrl.text.trim();
      final bolt11 = await requestPayInvoice(
        i,
        msat,
        comment: comment.isEmpty ? null : comment,
      );
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SendScreen(
            initialInvoice: bolt11,
            fromContact: widget.fromContact,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = friendlyError(AppLocalizations.of(context)!, e);
        busy = false;
      });
    }
  }

  Future<void> _submitWithdraw(LnurlWithdrawInfo i) async {
    final l10n = AppLocalizations.of(context)!;
    final sats = _resolveSats();
    if (sats == null || sats <= 0) {
      setState(() => error = l10n.lnurlAmountPositive);
      return;
    }
    final msat = sats * 1000;
    if (msat < i.minWithdrawableMsat || msat > i.maxWithdrawableMsat) {
      setState(
        () => error = l10n.lnurlAmountOutOfRange(
          i.minWithdrawableMsat ~/ 1000,
          i.maxWithdrawableMsat ~/ 1000,
        ),
      );
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final WalletBackend svc = await loadWalletBackend();
      final bolt11 = await svc.createInvoice(
        amountSats: sats,
        memo: i.description.isEmpty
            ? l10n.lnurlWithdrawDefaultMemo
            : i.description,
      );
      await submitWithdrawInvoice(i, bolt11);
      if (!mounted) return;
      signalPaymentSuccess();
      Navigator.popUntil(context, (r) => r.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = friendlyError(AppLocalizations.of(context)!, e);
        busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final i = info;
    final title = switch (i) {
      LnurlWithdrawInfo() => l10n.lnurlTitleWithdraw,
      LnurlPayInfo() => l10n.lnurlTitlePay,
      LnurlAuthInfo() => l10n.lnurlTitleAuthenticate,
      null => l10n.lnurlTitleGeneric,
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: busy && i == null
              ? const Center(child: CircularProgressIndicator())
              : i == null
              ? _buildError(l10n)
              : _buildForm(l10n, i),
        ),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          error ?? l10n.commonUnknownError,
          style: const TextStyle(color: Colors.redAccent),
        ),
        if (resolvedUrl != null && !readOnlyBlocked) ...[
          const SizedBox(height: 24),
          Text(
            l10n.lnurlResolvedExplain,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          SelectableText(resolvedUrl!, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.copy),
              label: Text(l10n.lnurlCopyUrl),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: resolvedUrl!));
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.lnurlUrlCopied)));
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildForm(AppLocalizations l10n, LnurlInfo i) {
    return switch (i) {
      LnurlAuthInfo() => _buildAuthForm(l10n, i),
      LnurlPayInfo() || LnurlWithdrawInfo() => _buildAmountForm(l10n, i),
    };
  }

  Widget _buildAuthForm(AppLocalizations l10n, LnurlAuthInfo i) {
    final header = switch (i.action) {
      'register' => l10n.lnurlAuthRegisterAt(i.host),
      'link' => l10n.lnurlAuthLinkAt(i.host),
      'auth' => l10n.lnurlAuthAuthenticateAt(i.host),
      _ => l10n.lnurlAuthLoginAt(i.host),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          header,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.lnurlAuthExplain,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: busy ? null : () => _submitAuth(i),
          child: busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.lnurlAuthConfirm),
        ),
        if (error != null) ...[
          const SizedBox(height: 16),
          Text(error!, style: const TextStyle(color: Colors.redAccent)),
        ],
      ],
    );
  }

  /// Converts the amount field to sats based on the selected [currency].
  /// Returns null on empty / invalid input or a missing fiat rate.
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

  /// Conversion preview under the amount field (pay or withdraw): shows the
  /// fiat equivalent when entering sats, or the sats equivalent when entering
  /// fiat.
  Widget _buildAmountPreview(AppLocalizations l10n) {
    const style = TextStyle(color: Colors.grey, fontSize: 12);
    if (ratesLoading) {
      return const SizedBox(
        height: 14,
        width: 14,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (currency == 'sats') {
      final sats = int.tryParse(amountCtrl.text.trim()) ?? 0;
      if (sats <= 0) return const SizedBox.shrink();
      final rate = rates?[displayCurrency];
      if (rate == null) return Text(l10n.receiveRatesUnavailable, style: style);
      return Text(formatFiatApprox(sats / 1e8 * rate, displayCurrency),
          style: style);
    }
    final sats = _resolveSats();
    if (sats == null) {
      final rate = rates?[currency];
      if (rate == null) return Text(l10n.receiveRatesUnavailable, style: style);
      return const SizedBox.shrink();
    }
    return Text(l10n.receiveSatsApprox(formatThousands(sats)), style: style);
  }

  Widget _buildAmountForm(AppLocalizations l10n, LnurlInfo i) {
    final desc = switch (i) {
      LnurlPayInfo(:final description) => description,
      LnurlWithdrawInfo(:final description) => description,
      LnurlAuthInfo() => '',
    };
    final (minSats, maxSats) = switch (i) {
      LnurlPayInfo(:final minSendableMsat, :final maxSendableMsat) => (
        minSendableMsat ~/ 1000,
        maxSendableMsat ~/ 1000,
      ),
      LnurlWithdrawInfo(
        :final minWithdrawableMsat,
        :final maxWithdrawableMsat,
      ) =>
        (minWithdrawableMsat ~/ 1000, maxWithdrawableMsat ~/ 1000),
      LnurlAuthInfo() => (0, 0),
    };
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (i is LnurlPayInfo &&
              widget.fromContact != null &&
              senderInfo != null)
            PaymentRouteHeader(
              senderSeed: senderInfo!.seed,
              senderName: senderInfo!.name,
              recipientSeed: normalizeDestination(
                widget.fromContact!.destination,
              ),
              recipientName: widget.fromContact!.name,
            ),
          // Remote LNURL text/plain metadata ("Payment to xxx"). Hidden when
          // paying a saved contact — the avatar row above already shows the
          // contact's name as the user saved it, and this remote text is
          // untranslatable and often lower-cased by the payee's server.
          if (desc.isNotEmpty && widget.fromContact == null) ...[
            Text(desc),
            const SizedBox(height: 12),
          ],
          Text(
            l10n.lnurlAmountRange(minSats, maxSats),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          // Amount input with a sats/fiat selector (same for pay and withdraw):
          // the user can type in sats or in a fiat currency, converted to sats.
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: amountCtrl,
                  keyboardType: currency == 'sats'
                      ? TextInputType.number
                      : const TextInputType.numberWithOptions(decimal: true),
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(labelText: l10n.commonAmount),
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
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _buildAmountPreview(l10n),
          ),
          if (i is LnurlPayInfo && i.commentAllowed > 0) ...[
            const SizedBox(height: 12),
            TextField(
              controller: commentCtrl,
              maxLength: i.commentAllowed,
              decoration: InputDecoration(
                labelText: l10n.lnurlCommentLabel,
                helperText: l10n.lnurlCommentHelp(i.commentAllowed),
              ),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: busy
                ? null
                : () => switch (i) {
                    LnurlPayInfo() => _submitPay(i),
                    LnurlWithdrawInfo() => _submitWithdraw(i),
                    LnurlAuthInfo() => _submitAuth(i),
                  },
            child: busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    i is LnurlPayInfo
                        ? l10n.lnurlGetAndPay
                        : l10n.lnurlWithdraw,
                  ),
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            Text(error!, style: const TextStyle(color: Colors.redAccent)),
          ],
        ],
      ),
    );
  }
}

