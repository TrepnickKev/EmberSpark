import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/friendly_error.dart';
import '../services/lnbits_service.dart';
import '../services/lightning_router.dart';
import '../services/price_service.dart';
import 'contacts_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'qr_scan_screen.dart';
import 'receive_screen.dart';
import 'send_to_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  int? balance;
  String? error;
  bool loading = false;
  String fiatCurrency = 'USD';
  double? fiatRate;

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
    } catch (_) {
      // Stay quiet on poll errors so transient network blips don't spam.
    } finally {
      _polling = false;
    }
  }

  void _showPaymentNotification(int delta) {
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
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
            Text(received ? 'Received $amount sats' : 'Sent $amount sats'),
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
      ]);
      if (!mounted) return;
      final b = results[0] as int;
      final cur = results[1] as String;
      final rates = results[2] as Map<String, double>?;
      setState(() {
        balance = b;
        fiatCurrency = cur;
        fiatRate = rates?[cur];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => error = friendlyError(e));
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
    // Wallet credentials only — keep contacts, LNURL-auth seed, lock /
    // currency / TLS settings across logouts.
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'url');
    await storage.delete(key: 'admin_key');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
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

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label,
  ) {
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
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset('images/Logo_icon.png'),
        ),
        title: const Text('EmberSpark'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loading ? null : _load,
          ),
          PopupMenuButton<String>(
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
              } else if (v == 'logout') {
                _logout();
              }
            },
            itemBuilder: (_) => [
              _menuItem('contacts', Icons.person_outline, 'Contacts'),
              _menuItem('settings', Icons.settings_outlined, 'Settings'),
              _menuItem('logout', Icons.logout, 'Log out'),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const CircularProgressIndicator()
            else if (error != null)
              Text(
                error!,
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              )
            else
              Column(
                children: [
                  Text(
                    '${formatThousands(balance ?? 0)} sats',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (balance != null && fiatRate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      formatFiat(
                        (balance! / 100000000) * fiatRate!,
                        fiatCurrency,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR'),
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
                    label: const Text('Send'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
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
                    label: const Text('Receive'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReceiveScreen(),
                      ),
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
