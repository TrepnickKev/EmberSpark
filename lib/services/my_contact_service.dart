import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'wallet_account_service.dart';

/// Storage + validators for the active wallet's static destinations — a
/// Lightning address, a BOLT12 offer, and/or an LNURL-pay link that the
/// user can share with others. Each value is keyed by the active wallet's
/// id (`my_ln_address__<walletId>` and friends) so switching wallets shows
/// that wallet's identities, not the previous one's.
///
/// When no wallet is active (`current_wallet_id` unset), getters return
/// null and setters are no-ops — the My-Contact screen isn't reachable in
/// that state anyway.

Future<String?> _readScoped(String Function(String walletId) keyFor) async {
  final id = await getCurrentWalletId();
  if (id == null) return null;
  const storage = FlutterSecureStorage();
  final v = await storage.read(key: keyFor(id));
  if (v == null) return null;
  final t = v.trim();
  return t.isEmpty ? null : t;
}

Future<void> _writeScoped(
  String Function(String walletId) keyFor,
  String? value,
) async {
  final id = await getCurrentWalletId();
  if (id == null) return;
  const storage = FlutterSecureStorage();
  if (value == null || value.trim().isEmpty) {
    await storage.delete(key: keyFor(id));
  } else {
    await storage.write(key: keyFor(id), value: value.trim());
  }
}

Future<String?> getMyLightningAddress() => _readScoped(myLnAddressKey);
Future<void> setMyLightningAddress(String? value) =>
    _writeScoped(myLnAddressKey, value);

Future<String?> getMyBolt12Offer() => _readScoped(myBolt12OfferKey);
Future<void> setMyBolt12Offer(String? value) =>
    _writeScoped(myBolt12OfferKey, value);

Future<String?> getMyLnurlpLink() => _readScoped(myLnurlpLinkKey);
Future<void> setMyLnurlpLink(String? value) =>
    _writeScoped(myLnurlpLinkKey, value);

/// True for strings shaped like a Lightning address (`name@host.tld`):
/// exactly one `@`, no whitespace, host contains a `.` and doesn't start
/// or end with one. Tolerant of a `lightning:` / `lnurl:` prefix.
bool isMyLightningAddress(String s) {
  final clean = s
      .trim()
      .replaceFirst(RegExp(r'^(lightning|lnurl):', caseSensitive: false), '');
  if (clean.isEmpty || clean.contains(' ')) return false;
  final parts = clean.split('@');
  if (parts.length != 2) return false;
  final user = parts[0];
  final host = parts[1];
  if (user.isEmpty || host.isEmpty) return false;
  if (!host.contains('.') || host.startsWith('.') || host.endsWith('.')) {
    return false;
  }
  return true;
}

/// True for strings shaped like a BOLT12 offer (`lno1…`). Tolerant of a
/// `lightning:` prefix. 15-char minimum filters obvious garbage.
bool isMyBolt12Offer(String s) {
  final clean =
      s.trim().replaceFirst(RegExp(r'^lightning:', caseSensitive: false), '');
  return clean.toLowerCase().startsWith('lno1') && clean.length >= 15;
}

/// True for strings shaped like an LNURL-pay link (`lnurl1…`). Tolerant of
/// a `lightning:` / `lnurl:` prefix. 15-char minimum filters obvious
/// garbage.
bool isMyLnurlpLink(String s) {
  final clean = s
      .trim()
      .replaceFirst(RegExp(r'^(lightning|lnurl):', caseSensitive: false), '');
  return clean.toLowerCase().startsWith('lnurl1') && clean.length >= 15;
}
