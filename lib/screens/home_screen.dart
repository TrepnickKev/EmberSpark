import 'dart:async';

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/friendly_error.dart';
import '../services/lnbits_service.dart';
import '../services/lightning_router.dart';
import '../services/price_service.dart';
import '../services/avatar_seed.dart';
import '../services/my_contact_service.dart';
import '../services/payment_feedback.dart';
import '../services/unseen_incoming_service.dart';
import '../services/wallet_account_service.dart';
import '../widgets/flipping_avatar.dart';
import '../widgets/stacked_action_button.dart' show bitcoinOrange;
import 'about_screen.dart';
import 'bolt_card_screen.dart';
import 'contacts_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'my_contact_screen.dart';
import 'qr_scan_screen.dart';
import 'receive_screen.dart';
import 'send_to_screen.dart';
import 'settings_screen.dart';
import 'wallets_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int? balance;
  String? error;
  bool loading = false;
  String fiatCurrency = 'USD';
  double? fiatRate;
  WalletAccount? currentWallet;
  String? avatarSeed;
  MyContactKind? _defaultContactKind;
  bool _hasUnseenIncoming = false;

  Timer? _pollTimer;
  bool _polling = false;
  static const _pollInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPolling();
      _pollOnce();
    } else {
      _stopPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollOnce());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _pollOnce() async {
    if (loading || _polling || !mounted) return;
    _polling = true;
    try {
      final svc = await LNbitsService.fromStorage();
      final b = await svc.getBalanceSats();
      if (!mounted) return;
      final prev = balance;
      if (prev != null && b != prev) {
        _showPaymentNotification(b - prev);
      }
      setState(() {
        balance = b;
        if (error != null) error = null;
      });
      await _reconcileUnseen(b, currentWallet?.id);
    } catch (_) {
      // Stay quiet on poll errors so transient network blips don't spam.
    } finally {
      _polling = false;
    }
  }

  /// Updates the "payment received while away" badge from a freshly fetched
  /// [balance]. Compares against the wallet's persisted acknowledged-balance
  /// baseline (see unseen_incoming_service): shows the badge when the balance
  /// is above it, and lowers the baseline on spends so a send can't mask a
  /// later receive. Persists the baseline only when it changes.
  Future<void> _reconcileUnseen(int balance, String? walletId) async {
    if (walletId == null) return;
    final baseline = await getLastSeenBalanceFor(walletId);
    final r = evaluateUnseen(balance, baseline);
    if (r.baseline != baseline) {
      await setLastSeenBalanceFor(walletId, r.baseline);
    }
    if (mounted) setState(() => _hasUnseenIncoming = r.unseen);
  }

  void _showPaymentNotification(int delta) {
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    final l10n = AppLocalizations.of(context)!;
    final received = delta > 0;
    final amount = formatThousands(delta.abs());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(
              received ? Icons.arrow_downward : Icons.arrow_upward,
              color: received ? Colors.greenAccent : Colors.redAccent,
            ),
            const SizedBox(width: 8),
            Text(
              received
                  ? l10n.homeSatsReceived(amount)
                  : l10n.homeSatsSent(amount),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final svc = await LNbitsService.fromStorage();
      final results = await Future.wait([
        svc.getBalanceSats(),
        getSelectedCurrency(),
        getBtcRates(),
        getCurrentWallet(),
        getMyLightningAddress(),
        getMyBolt12Offer(),
        getMyLnurlpLink(),
        getMyDefaultContactKind(),
      ]);
      if (!mounted) return;
      final b = results[0] as int;
      final cur = results[1] as String;
      final rates = results[2] as Map<String, double>?;
      var w = results[3] as WalletAccount?;
      final myLnAddress = results[4] as String?;
      final myBolt12 = results[5] as String?;
      final myLnurlp = results[6] as String?;
      final defaultKind = results[7] as MyContactKind?;

      // Lazy-fetch the LNbits server-side wallet UUID on the first
      // successful load. Best-effort: any failure (404 on older servers,
      // wrong shape) is swallowed; avatar falls through to lower-priority
      // seeds.
      if (w != null &&
          (w.serverWalletId == null || w.serverWalletId!.isEmpty)) {
        try {
          final sid = await svc.getServerWalletId();
          await setServerWalletId(w.id, sid);
          w = w.copyWith(serverWalletId: sid);
        } catch (_) {
          // Ignore — keep the lower-priority avatar seed.
        }
      }

      final seed = avatarSeedForWallet(
        lnAddress: myLnAddress,
        bolt12: myBolt12,
        lnurlp: myLnurlp,
        serverWalletId: w?.serverWalletId,
        fallbackLocalId: w?.id ?? '',
        defaultKind: defaultKind,
      );

      if (!mounted) return;
      setState(() {
        balance = b;
        fiatCurrency = cur;
        fiatRate = rates?[cur];
        currentWallet = w;
        avatarSeed = seed.isEmpty ? null : seed;
        _defaultContactKind = defaultKind;
      });
      await _reconcileUnseen(b, w?.id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = friendlyError(AppLocalizations.of(context)!, e);
        // Endpoint unreachable: show the placeholder avatar, not the previous
        // wallet's (stale) one.
        avatarSeed = null;
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _refreshFiat() async {
    final cur = await getSelectedCurrency();
    final rates = await getBtcRates();
    if (!mounted) return;
    setState(() {
      fiatCurrency = cur;
      fiatRate = rates?[cur];
    });
  }

  Future<void> _logout() async {
    // Clear the active-wallet pointer only; saved wallets stay in the
    // list. Route to Wallets if any remain, otherwise Login.
    await setCurrentWalletId(null);
    if (!mounted) return;
    final wallets = await listWallets();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            wallets.isEmpty ? const LoginScreen() : const WalletsScreen(),
      ),
    );
  }

  Future<void> _openWallets() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WalletsScreen()),
    );
    if (mounted) _load();
  }

  Future<void> _scanAndRoute() async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
    if (code == null || !mounted) return;
    await routeLightningCode(Navigator.of(context), code);
    if (mounted) _load();
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
    return PopupMenuItem<String>(
      value: value,
      height: 52,
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset('images/Logo_icon.png'),
          ),
        ),
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: _hasUnseenIncoming
                ? const Badge(
                    backgroundColor: Colors.greenAccent,
                    child: Icon(Icons.history),
                  )
                : const Icon(Icons.history),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final id = currentWallet?.id;
              final b = balance;
              if (id != null && b != null) {
                await setLastSeenBalanceFor(id, b);
              }
              if (mounted) setState(() => _hasUnseenIncoming = false);
              navigator.push(
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loading ? null : _load,
          ),
          PopupMenuButton<String>(
            icon: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.menu,
                size: 22,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            onSelected: (v) async {
              if (v == 'contacts') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactsScreen()),
                );
              } else if (v == 'settings') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
                if (mounted) _refreshFiat();
              } else if (v == 'mycontact') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyContactScreen()),
                );
              } else if (v == 'boltcard') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BoltCardScreen()),
                );
              } else if (v == 'wallets') {
                _openWallets();
              } else if (v == 'logout') {
                _logout();
              }
            },
            itemBuilder: (_) => [
              _menuItem('mycontact', Icons.badge_outlined, l10n.homeMyContact),
              _menuItem('contacts', Icons.person_outline, l10n.homeContacts),
              _menuItem(
                'wallets',
                Icons.account_balance_wallet_outlined,
                l10n.walletsMenu,
              ),
              _menuItem(
                'boltcard',
                Icons.credit_card_outlined,
                l10n.homeBoltCard,
              ),
              _menuItem('settings', Icons.settings_outlined, l10n.homeSettings),
              _menuItem('logout', Icons.logout, l10n.homeLogout),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              color: avatarSeed == null ? bitcoinOrange : Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () =>
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MyContactScreen(initialKind: _defaultContactKind),
                      ),
                    ).then((_) {
                      if (mounted) _load();
                    }),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: avatarSeed == null
                      ? const Icon(Icons.person, size: 48, color: Colors.white)
                      : FlippingAvatar(
                          seed: avatarSeed!,
                          trigger: paymentSuccessTrigger,
                        ),
                ),
              ),
            ),
            if (currentWallet != null) ...[
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _openWallets,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currentWallet!.label,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.unfold_more,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (loading)
              const CircularProgressIndicator()
            else if (error != null)
              Text(
                error!,
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              )
            else
              ValueListenableBuilder<AmountDisplayMode>(
                valueListenable: amountDisplayMode,
                builder: (context, mode, _) {
                  final fiatAvailable = balance != null && fiatRate != null;
                  final showFiat =
                      mode == AmountDisplayMode.fiat && fiatAvailable;
                  final satsText =
                      '${formatThousands(balance ?? 0)} ${l10n.homeSatsUnit}';
                  final fiatText = fiatAvailable
                      ? formatFiat(
                          (balance! / 100000000) * fiatRate!,
                          fiatCurrency,
                        )
                      : null;
                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: fiatAvailable
                        ? () => toggleAmountDisplayMode()
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Column(
                        children: [
                          Text(
                            showFiat ? fiatText! : satsText,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (fiatAvailable) ...[
                            const SizedBox(height: 4),
                            Text(
                              showFiat ? satsText : fiatText!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(l10n.homeScan),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _scanAndRoute,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.upload),
                    label: Text(l10n.homeSend),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SendToScreen()),
                      );
                      if (mounted) _load();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: Text(l10n.homeReceive),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReceiveScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
