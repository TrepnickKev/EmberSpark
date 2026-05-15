import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/login_screen.dart';
import 'services/language_service.dart';
import 'services/lightning_router.dart';
import 'services/lock_service.dart';
import 'widgets/stacked_action_button.dart' show bitcoinOrange;

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadInitialLocale();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    final initial = await _appLinks.getInitialLink();
    if (initial != null) _handle(initial);
    _linkSub = _appLinks.uriLinkStream.listen(_handle);
  }

  Future<void> _handle(Uri uri) async {
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
          theme: ThemeData.dark(useMaterial3: true).copyWith(
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(foregroundColor: bitcoinOrange),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: bitcoinOrange),
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

class _Bootstrap extends StatelessWidget {
  const _Bootstrap();

  Future<bool> _hasCreds() async {
    const storage = FlutterSecureStorage();
    final url = await storage.read(key: 'url');
    final admin = await storage.read(key: 'admin_key');
    return url != null && url.isNotEmpty && admin != null && admin.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasCreds(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snap.data! ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
