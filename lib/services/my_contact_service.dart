import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage + validators for the user's own static destinations — a
/// Lightning address (`user@host.tld`) and/or a BOLT12 offer (`lno1…`)
/// that the user can share with others. Both are persisted under
/// `flutter_secure_storage` (same place as wallet credentials and other
/// per-user state). Either may be unset.

const _myAddressKey = 'my_ln_address';
const _myOfferKey = 'my_bolt12_offer';
const _myLnurlpKey = 'my_lnurlp_link';

Future<String?> getMyLightningAddress() async {
  const storage = FlutterSecureStorage();
  final v = await storage.read(key: _myAddressKey);
  if (v == null) return null;
  final t = v.trim();
  return t.isEmpty ? null : t;
}

Future<void> setMyLightningAddress(String? value) async {
  const storage = FlutterSecureStorage();
  if (value == null || value.trim().isEmpty) {
    await storage.delete(key: _myAddressKey);
  } else {
    await storage.write(key: _myAddressKey, value: value.trim());
  }
}

Future<String?> getMyBolt12Offer() async {
  const storage = FlutterSecureStorage();
  final v = await storage.read(key: _myOfferKey);
  if (v == null) return null;
  final t = v.trim();
  return t.isEmpty ? null : t;
}

Future<void> setMyBolt12Offer(String? value) async {
  const storage = FlutterSecureStorage();
  if (value == null || value.trim().isEmpty) {
    await storage.delete(key: _myOfferKey);
  } else {
    await storage.write(key: _myOfferKey, value: value.trim());
  }
}

Future<String?> getMyLnurlpLink() async {
  const storage = FlutterSecureStorage();
  final v = await storage.read(key: _myLnurlpKey);
  if (v == null) return null;
  final t = v.trim();
  return t.isEmpty ? null : t;
}

Future<void> setMyLnurlpLink(String? value) async {
  const storage = FlutterSecureStorage();
  if (value == null || value.trim().isEmpty) {
    await storage.delete(key: _myLnurlpKey);
  } else {
    await storage.write(key: _myLnurlpKey, value: value.trim());
  }
}

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
