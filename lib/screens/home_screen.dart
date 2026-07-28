import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../main.dart' show routeObserver;
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
import '../widgets/read_only_badge.dart';
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

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, RouteAware {
  int? balance;
  String? error;
  bool loading = false;
  String fiatCurrency = 'USD';
  double? fiatRate;
  WalletAccount? currentWallet;
  String? avatarSeed;
  MyContactKind? _defaultContactKind;
  bool _hasUnseenIncoming = false;

  // Swipe-to-switch avatar carousel: all wallets, their avatar seeds, and the
  // active wallet's index. The controller is created lazily once the multi-
  // wallet view first shows, at the active index.
  List<WalletAccount> _wallets = const [];
  Map<String, String> _walletSeeds = const {};
  int _walletIndex = 0;
  // Signature (joined wallet ids) of the set the carousel controller was built
  // for; a change means recreate the controller + key so it re-lands correctly.
  String _walletSig = '';
  PageController? _avatarPage;
  // A never-firing flip trigger for the non-active carousel pages.
  final ValueNotifier<int> _noFlip = ValueNotifier<int>(0);
  // Drives the active avatar's coin-flip. Home bumps this itself once it is the
  // current route again (see didPopNext) rather than letting a pay/withdraw
  // screen fire the global trigger while home is covered (its ticker is muted)
  // and about to reload. _flipSeen tracks the last global success we've played.
  final ValueNotifier<int> _avatarFlip = ValueNotifier<int>(0);
  int _flipSeen = 0;

  Timer? _pollTimer;
  bool _polling = false;
  static const _pollInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _flipSeen = paymentSuccessTrigger.value;
    _load();
    _startPolling();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) routeObserver.subscribe(this, route);
  }

  /// A screen above home was popped, so home is the current route again. If a
  /// payment succeeded while we were covered, play the coin-flip now (on the
  /// visible avatar) instead of having missed it under the muted ticker.
  @override
  void didPopNext() {
    if (!mounted) return;
    if (paymentSuccessTrigger.value != _flipSeen) {
      _flipSeen = paymentSuccessTrigger.value;
      _avatarFlip.value++;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _stopPolling();
    _avatarPage?.dispose();
    _noFlip.dispose();
    _avatarFlip.dispose();
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

      // All wallets + their avatar seeds for the swipe-to-switch carousel.
      final wallets = await listWallets();
      final computedSeeds = await Future.wait(
        wallets.map(avatarSeedForAccount),
      );
      final seeds = <String, String>{
        for (var i = 0; i < wallets.length; i++)
          wallets[i].id: computedSeeds[i],
      };
      final idx = wallets.indexWhere((x) => x.id == w?.id);
      final walletIndex = idx < 0 ? 0 : idx;

      if (!mounted) return;
      // Rebuild the carousel controller (at the active index) whenever the
      // wallet SET changes — add/remove/reorder — so it always lands on the
      // active wallet's avatar. The PageView is keyed by this signature so a
      // fresh element honours the new controller's initialPage; the old
      // controller is disposed after the frame (once its old PageView is gone)
      // to avoid an attach conflict.
      final walletSig = wallets.map((x) => x.id).join(',');
      if (wallets.length > 1 && (_avatarPage == null || walletSig != _walletSig)) {
        final old = _avatarPage;
        _avatarPage = PageController(initialPage: walletIndex);
        if (old != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
        }
      }
      setState(() {
        balance = b;
        fiatCurrency = cur;
        fiatRate = rates?[cur];
        currentWallet = w;
        avatarSeed = seed.isEmpty ? null : seed;
        _defaultContactKind = defaultKind;
        _wallets = wallets;
        _walletSeeds = seeds;
        _walletIndex = walletIndex;
        _walletSig = walletSig;
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

  Future<void> _onWalletPageChanged(int i) async {
    if (i < 0 || i >= _wallets.length) return;
    final target = _wallets[i];
    if (target.id == currentWallet?.id) return;
    await setCurrentWalletId(target.id);
    if (mounted) await _load();
  }

  void _openMyContact() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyContactScreen(initialKind: _defaultContactKind),
      ),
    ).then((_) {
      if (mounted) _load();
    });
  }

  /// The 88x88 avatar: a vertical wallet carousel when there's more than one
  /// wallet (swipe up/down to switch), otherwise the single avatar.
  Widget _buildAvatarSwitcher() {
    if (_wallets.length <= 1 || _avatarPage == null) {
      return _avatarBubble(
        avatarSeed,
        _avatarFlip,
        avatarKey: ValueKey('avatar-${currentWallet?.id}'),
      );
    }
    // Swallow the carousel's scroll notifications so they never reach the
    // Scaffold's ScrollNotificationObserver — otherwise the AppBar treats a
    // non-zero page offset as "content scrolled under" and tints itself,
    // making the top bar's colour depend on the selected wallet's page index.
    return NotificationListener<ScrollNotification>(
      onNotification: (_) => true,
      child: SizedBox(
        width: 88,
        height: 88,
        child: PageView.builder(
          key: ValueKey(_walletSig),
          scrollDirection: Axis.vertical,
          controller: _avatarPage,
          onPageChanged: _onWalletPageChanged,
          itemCount: _wallets.length,
          itemBuilder: (_, i) {
            final w = _wallets[i];
            final seed = _walletSeeds[w.id];
            return _avatarBubble(
              (seed == null || seed.isEmpty) ? null : seed,
              i == _walletIndex ? _avatarFlip : _noFlip,
              avatarKey: ValueKey('avatar-${w.id}'),
            );
          },
        ),
      ),
    );
  }

  Widget _avatarBubble(
    String? seed,
    ValueListenable<int> trigger, {
    Key? avatarKey,
  }) {
    return Material(
      color: seed == null ? bitcoinOrange : Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _openMyContact,
        child: SizedBox(
          width: 88,
          height: 88,
          child: seed == null
              ? const Icon(Icons.person, size: 48, color: Colors.white)
              : FlippingAvatar(key: avatarKey, seed: seed, trigger: trigger),
        ),
      ),
    );
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
    final readOnly = currentWallet?.readOnly ?? false;
    return Scaffold(
      appBar: AppBar(
        // Pin the bar colour hard so it can't drift between wallets: fixed
        // background, no surface tint, and no elevation change when the avatar
        // carousel (a PageView) reports a non-zero scroll offset.
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
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
            _buildAvatarSwitcher(),
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
                      if (readOnly) readOnlyBadge(l10n),
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
            // Fixed height so the amount area doesn't reflow (which would
            // shove the buttons around in this centered Column) when it swaps
            // between the loading spinner, an error, or the balance — e.g. the
            // brief `loading` state while swiping to switch wallets. Sized to
            // fit the tallest state (the two-line sats + fiat amount).
            SizedBox(
              height: 100,
              child: Center(
                child: loading
                    ? const CircularProgressIndicator()
                    : error != null
                        ? Text(
                            error!,
                            style: const TextStyle(color: Colors.redAccent),
                            textAlign: TextAlign.center,
                          )
                        : ValueListenableBuilder<AmountDisplayMode>(
                            valueListenable: amountDisplayMode,
                            builder: (context, mode, _) {
                              final fiatAvailable =
                                  balance != null && fiatRate != null;
                              final showFiat = mode == AmountDisplayMode.fiat &&
                                  fiatAvailable;
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
                                    mainAxisSize: MainAxisSize.min,
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
              ),
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
                    // Read-only wallets (invoice/read key) can't send.
                    onPressed: readOnly
                        ? null
                        : () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SendToScreen(),
                              ),
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
