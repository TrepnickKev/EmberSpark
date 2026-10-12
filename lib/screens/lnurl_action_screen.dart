import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../services/avatar_seed.dart';
import '../services/contact_service.dart' show Contact;
import '../services/friendly_error.dart';
import '../services/http_client_factory.dart';
import '../services/lnbits_service.dart';
import '../services/wallet_backend.dart';
import '../services/lnurl.dart';
import '../services/lnurl_auth.dart';
import '../services/payment_feedback.dart';
import '../services/price_service.dart';
import '../services/wallet_account_service.dart';
import '../widgets/payment_route_header.dart';
import '../widgets/stacked_action_button.dart' show bitcoinOrange;
import '../widgets/wallet_avatar.dart';
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
  // True when the resolve failed because the withdraw voucher was already used.
  // Shown as a friendly icon + message instead of the raw error text.
  bool _alreadyUsed = false;
  bool busy = true;
  // The current wallet's avatar + name: the sender for a pay-from-contact
  // (shown in PaymentRouteHeader).
  ({String seed, String name})? senderInfo;

  // Withdraw target selection: every saved wallet can receive a withdraw, so
  // the target is switchable by swiping its avatar (like the home carousel).
  // Defaults to the active wallet.
  List<WalletAccount> _wallets = const [];
  Map<String, String> _walletSeeds = {};
  WalletAccount? _target;
  PageController? _targetPage;

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
    _loadSenderInfo();
    _loadWithdrawTargets();
  }

  Future<void> _loadSenderInfo() async {
    final info = await getOwnAvatarInfo();
    if (mounted && info.seed.isNotEmpty) {
      setState(() => senderInfo = info);
    }
  }

  /// Loads every saved wallet (for the withdraw target switcher) and its avatar
  /// seed, defaulting the target to the active wallet.
  Future<void> _loadWithdrawTargets() async {
    final wallets = await listWallets();
    final current = await getCurrentWallet();
    final seeds = await Future.wait(wallets.map(avatarSeedForAccount));
    if (!mounted) return;
    var index = wallets.indexWhere((w) => w.id == current?.id);
    if (index < 0) index = 0;
    setState(() {
      _wallets = wallets;
      _walletSeeds = {
        for (var i = 0; i < wallets.length; i++) wallets[i].id: seeds[i],
      };
      _target = wallets.isNotEmpty ? wallets[index] : null;
      if (wallets.length > 1) {
        _targetPage?.dispose();
        _targetPage = PageController(initialPage: index);
      }
    });
  }

  /// The wallet that receives the withdraw. Swipe the avatar to switch (same
  /// gesture as home) or tap it to open the chooser. A single wallet shows a
  /// static, non-interactive avatar.
  Widget _buildTargetSwitcher() {
    final target = _target;
    if (target == null) return const SizedBox.shrink();
    final multi = _wallets.length > 1 && _targetPage != null;
    final avatar = !multi
        ? WalletAvatar(_walletSeeds[target.id] ?? target.id, size: 88)
        : NotificationListener<ScrollNotification>(
            onNotification: (_) => true,
            child: SizedBox(
              width: 88,
              height: 88,
              child: PageView.builder(
                scrollDirection: Axis.vertical,
                controller: _targetPage,
                onPageChanged: (i) => setState(() => _target = _wallets[i]),
                itemCount: _wallets.length,
                itemBuilder: (_, i) => WalletAvatar(
                  _walletSeeds[_wallets[i].id] ?? _wallets[i].id,
                  size: 88,
                ),
              ),
            ),
          );
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        // Tap opens the chooser; a vertical drag still swipes the carousel
        // (tap and drag are distinct gestures).
        onTap: multi ? _pickTarget : null,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            avatar,
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    target.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                if (multi)
                  const Icon(Icons.expand_more, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom-sheet wallet chooser (alternative to swiping) for the withdraw
  /// target. Keeps the swipe carousel in sync on pick.
  Future<void> _pickTarget() async {
    final l10n = AppLocalizations.of(context)!;
    final chosen = await showModalBottomSheet<WalletAccount>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.withdrawChooseWallet,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            for (final w in _wallets)
              ListTile(
                leading: WalletAvatar(_walletSeeds[w.id] ?? w.id, size: 40),
                title: Text(w.label),
                trailing: w.id == _target?.id
                    ? const Icon(Icons.check, color: bitcoinOrange)
                    : null,
                onTap: () => Navigator.pop(context, w),
              ),
          ],
        ),
      ),
    );
    if (chosen == null || !mounted) return;
    setState(() => _target = chosen);
    final idx = _wallets.indexWhere((x) => x.id == chosen.id);
    if (idx >= 0 && (_targetPage?.hasClients ?? false)) {
      _targetPage!.jumpToPage(idx);
    }
  }

  @override
  void dispose() {
    amountCtrl.removeListener(_onAmountChanged);
    amountCtrl.dispose();
    commentCtrl.dispose();
    _targetPage?.dispose();
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
      // A fixed-amount withdraw (min == max) has only one valid value, so
      // prefill it. currency defaults to 'sats', so _resolveSats() parses it.
      if (i is LnurlWithdrawInfo &&
          i.minWithdrawableMsat == i.maxWithdrawableMsat) {
        amountCtrl.text = (i.maxWithdrawableMsat ~/ 1000).toString();
      }
      setState(() {
        info = i;
        busy = false;
        // Otherwise leave the amount blank so it (and the currency) are manual.
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _alreadyUsed = e is LnurlServiceErrorException && e.alreadyUsed;
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
      // Create the invoice on the CHOSEN target wallet's server so the funds
      // land there (its invoice/read key can create invoices).
      final t = _target;
      final WalletBackend svc = t == null
          ? await loadWalletBackend()
          : LNbitsService(
              baseUrl: t.url,
              adminKey: t.adminKey,
              readOnly: t.readOnly,
              client: await getHttpClient(),
            );
      final bolt11 = await svc.createInvoice(
        amountSats: sats,
        memo: i.description.isEmpty
            ? l10n.lnurlWithdrawDefaultMemo
            : i.description,
      );
      await submitWithdrawInvoice(i, bolt11);
      if (!mounted) return;
      // Switch the active wallet to the target so Home reflects the funds.
      if (t != null) {
        final current = await getCurrentWallet();
        if (current?.id != t.id) await setCurrentWalletId(t.id);
      }
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
    // An already-used withdraw voucher is not really an error the user can act
    // on, so show a calm icon + message instead of red text and a URL to copy.
    if (_alreadyUsed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 56,
                color: Theme.of(context).disabledColor,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.lnurlWithdrawAlreadyUsed,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }
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
    // A fixed-amount withdraw (min == max) is prefilled and must not be edited.
    final fixed = i is LnurlWithdrawInfo && minSats == maxSats;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Withdraw: show the wallet the funds land in; swipe the avatar to
          // switch it (same gesture as home), so a withdraw is visually clear.
          if (i is LnurlWithdrawInfo && _target != null) _buildTargetSwitcher(),
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
                  readOnly: fixed,
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
                onChanged: fixed
                    ? null
                    : (next) {
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

