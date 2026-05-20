import 'package:flutter/material.dart';
import '../screens/bolt12_action_screen.dart';
import '../screens/lnurl_action_screen.dart';
import '../screens/send_screen.dart';
import 'wallet_account_service.dart';

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
  } else if (lower.startsWith('lno1') || lower.startsWith('lni1')) {
    await navigator.push(
      MaterialPageRoute(builder: (_) => Bolt12ActionScreen(code: clean)),
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

/// True when [input] looks like one of the destination kinds the wallet
/// can pay (BOLT11 / BOLT12 / LNURL / Lightning address). Used by the
/// "new contact" form to reject obvious garbage at entry time. Liberal
/// by design — we don't decode TLVs here, just check prefixes and shape.
bool isLikelyLightningDestination(String input) {
  final clean = input
      .trim()
      .replaceFirst(RegExp(r'^(lightning|lnurl):', caseSensitive: false), '');
  if (clean.isEmpty) return false;
  final lower = clean.toLowerCase();

  // Bech32-encoded BOLT11 / BOLT12 / LNURL. Require enough characters to
  // rule out garbage like "lnbc" alone — real strings are far longer, but
  // 15 chars is a safe lower bound that won't trip on novelties.
  const minBech32Length = 15;
  if ((lower.startsWith('lnbc') ||
          lower.startsWith('lno1') ||
          lower.startsWith('lni1') ||
          lower.startsWith('lnurl')) &&
      clean.length >= minBech32Length) {
    return true;
  }

  // Lightning address: name@host.tld
  final at = clean.indexOf('@');
  if (at > 0 && at < clean.length - 1 && !clean.contains(' ')) {
    final host = clean.substring(at + 1);
    if (host.contains('.') && !host.startsWith('.') && !host.endsWith('.')) {
      return true;
    }
  }
  return false;
}

/// Whether the user has an active wallet to handle a deep link.
Future<bool> haveCredentials() async => (await getCurrentWallet()) != null;
