import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../screens/lnurl_action_screen.dart';
import '../screens/send_screen.dart';

/// Classifies a Lightning string (BOLT11 / LNURL / Lightning address) and
/// pushes the appropriate flow on [navigator]. Used by both the in-app QR
/// scanner and Android deep-link intents.
Future<void> routeLightningCode(
  NavigatorState navigator,
  String code,
) async {
  final clean = code.trim().replaceFirst(
    RegExp(r'^(lightning|lnurl):', caseSensitive: false),
    '',
  );
  final lower = clean.toLowerCase();

  if (lower.startsWith('lnbc')) {
    await navigator.push(
      MaterialPageRoute(builder: (_) => SendScreen(initialInvoice: clean)),
    );
  } else if (lower.startsWith('lnurl') ||
      (clean.contains('@') && clean.contains('.'))) {
    await navigator.push(
      MaterialPageRoute(builder: (_) => LnurlActionScreen(code: clean)),
    );
  } else {
    final ctx = navigator.context;
    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(const SnackBar(content: Text('Unrecognized Lightning code')));
  }
}

/// Whether the user has the credentials needed to handle a deep link.
Future<bool> haveCredentials() async {
  const storage = FlutterSecureStorage();
  final url = await storage.read(key: 'url');
  final admin = await storage.read(key: 'admin_key');
  return url != null && url.isNotEmpty && admin != null && admin.isNotEmpty;
}
