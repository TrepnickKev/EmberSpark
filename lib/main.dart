import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/login_screen.dart';
import 'screens/wallets_screen.dart';
import 'services/language_service.dart';
import 'services/lightning_router.dart';
import 'services/lock_service.dart';
import 'services/nfc_coordinator.dart';
import 'services/price_service.dart';
import 'services/received_notify_service.dart';
import 'services/wallet_account_service.dart';
import 'widgets/stacked_action_button.dart' show bitcoinOrange;

final navigatorKey = GlobalKey<NavigatorState>();

/// Lets the home screen learn when it becomes visible again (a screen above it
/// was popped) so it can play the payment coin-flip once it is the current
/// route, rather than while it is covered. See HomeScreen's RouteAware.
final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadInitialLocale();
  await loadAmountDisplayMode();
  await migrateLegacyStorageIfNeeded();
  // Opt-in received-payment notifications: register the WorkManager callback,
  // then re-schedule the periodic poll if the user has it enabled (survives
  // process death without a boot receiver). All Android-guarded internally.
  await initReceivedNotify();
  if (await isReceivedNotifyEnabled()) {
    await enableReceivedNotifyTask();
    await applyNotifySound();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Route ambient NFC taps through the app's navigator, and start capturing
    // while foregrounded so a tapped card is handled in-app (no OS chooser).
    NfcCoordinator.instance.configure(
      navigator: () => navigatorKey.currentState,
    );
    NfcCoordinator.instance.onForeground();
    _initDeepLinks();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      NfcCoordinator.instance.onForeground();
    } else {
      NfcCoordinator.instance.onBackground();
    }
  }

  Future<void> _initDeepLinks() async {
    final initial = await _appLinks.getInitialLink();
    if (initial != null) _handle(initial);
    _linkSub = _appLinks.uriLinkStream.listen(_handle);
  }

  String? _lastLinkUri;
  DateTime? _lastLinkAt;

  Future<void> _handle(Uri uri) async {
    // On a cold start (Android singleTask) the launching link arrives via
    // BOTH getInitialLink() and uriLinkStream, which would push the same
    // screen twice and require two back taps. Ignore an identical link that
    // repeats within a short window so one back tap is enough. Set before the
    // first await so two near-simultaneous invocations are both caught.
    final s = uri.toString();
    final now = DateTime.now();
    if (_lastLinkUri == s &&
        _lastLinkAt != null &&
        now.difference(_lastLinkAt!) < const Duration(seconds: 3)) {
      return;
    }
    _lastLinkUri = s;
    _lastLinkAt = now;

    if (!await haveCredentials()) {
      _toast();
      return;
    }
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    await routeLightningCode(nav, uri.toString());
  }

  void _toast() {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    final l10n = AppLocalizations.of(ctx);
    final msg = l10n?.appSetupFirstToast ?? 'Set up the wallet first';
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NfcCoordinator.instance.onBackground();
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        return MaterialApp(
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
          navigatorKey: navigatorKey,
          navigatorObservers: [routeObserver],
          theme: ThemeData.dark(useMaterial3: true).copyWith(
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(foregroundColor: bitcoinOrange),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: bitcoinOrange),
            ),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected) ? Colors.white : null,
              ),
              trackColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected) ? bitcoinOrange : null,
              ),
            ),
            tabBarTheme: const TabBarThemeData(
              labelColor: Colors.white,
              indicatorColor: Colors.white,
            ),
          ),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const _LockGate(),
        );
      },
    );
  }
}

class _LockGate extends StatefulWidget {
  const _LockGate();

  @override
  State<_LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<_LockGate> {
  bool? _lockEnabled;
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    isLockEnabled().then((v) {
      if (mounted) setState(() => _lockEnabled = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _lockEnabled;
    if (enabled == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!enabled || _unlocked) return const _Bootstrap();
    return LockScreen(
      onUnlocked: () => setState(() => _unlocked = true),
    );
  }
}

enum _BootRoute { home, wallets, login }

class _Bootstrap extends StatelessWidget {
  const _Bootstrap();

  Future<_BootRoute> _route() async {
    if (await getCurrentWallet() != null) return _BootRoute.home;
    final list = await listWallets();
    return list.isEmpty ? _BootRoute.login : _BootRoute.wallets;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BootRoute>(
      future: _route(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return switch (snap.data!) {
          _BootRoute.home => const HomeScreen(),
          _BootRoute.wallets => const WalletsScreen(),
          _BootRoute.login => const LoginScreen(),
        };
      },
    );
  }
}
