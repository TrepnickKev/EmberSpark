import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// One saved LNbits wallet on this device. Held in the `wallets_v1` JSON
/// list; the active wallet's id is pointed to by `current_wallet_id`.
///
/// "My Contact" values (LN address, BOLT12 offer, LNURL-pay link) are NOT
/// fields here — they live in flat keys suffixed by [id] so a single field
/// edit doesn't have to rewrite the whole list.
class WalletAccount {
  final String id;
  final String label;
  final String url;
  final String adminKey;

  /// LNbits server-side wallet UUID. Populated lazily on first successful
  /// `_load` after add. Stable across devices — used as a cross-device
  /// avatar seed fallback when no public identifier is set under My
  /// Contact yet. Null when never fetched (older LNbits server, network
  /// error, or fresh wallet).
  final String? serverWalletId;

  const WalletAccount({
    required this.id,
    required this.label,
    required this.url,
    required this.adminKey,
    this.serverWalletId,
  });

  WalletAccount copyWith({String? label, String? serverWalletId}) =>
      WalletAccount(
        id: id,
        label: label ?? this.label,
        url: url,
        adminKey: adminKey,
        serverWalletId: serverWalletId ?? this.serverWalletId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'url': url,
        'adminKey': adminKey,
        if (serverWalletId != null) 'serverWalletId': serverWalletId,
      };

  factory WalletAccount.fromJson(Map<String, dynamic> j) => WalletAccount(
        id: j['id'] as String,
        label: j['label'] as String,
        url: j['url'] as String,
        adminKey: j['adminKey'] as String,
        serverWalletId: j['serverWalletId'] as String?,
      );
}

const _walletsKey = 'wallets_v1';
const _currentIdKey = 'current_wallet_id';

// Legacy flat keys, migrated once on startup then deleted.
const _legacyUrlKey = 'url';
const _legacyAdminKey = 'admin_key';
const _legacyLnAddressKey = 'my_ln_address';
const _legacyBolt12Key = 'my_bolt12_offer';
const _legacyLnurlpKey = 'my_lnurlp_link';

String myLnAddressKey(String walletId) => 'my_ln_address__$walletId';
String myBolt12OfferKey(String walletId) => 'my_bolt12_offer__$walletId';
String myLnurlpLinkKey(String walletId) => 'my_lnurlp_link__$walletId';
String myDefaultContactKindKey(String walletId) =>
    'my_default_contact_kind__$walletId';
String lastSeenBalanceKey(String walletId) => 'last_seen_balance__$walletId';

Future<List<WalletAccount>> listWallets() async {
  const storage = FlutterSecureStorage();
  final raw = await storage.read(key: _walletsKey);
  if (raw == null || raw.isEmpty) return const [];
  final decoded = jsonDecode(raw);
  if (decoded is! List) return const [];
  return decoded
      .whereType<Map<String, dynamic>>()
      .map(WalletAccount.fromJson)
      .toList();
}

Future<String?> getCurrentWalletId() async {
  const storage = FlutterSecureStorage();
  final v = await storage.read(key: _currentIdKey);
  return (v == null || v.isEmpty) ? null : v;
}

Future<WalletAccount?> getCurrentWallet() async {
  final id = await getCurrentWalletId();
  if (id == null) return null;
  final list = await listWallets();
  for (final w in list) {
    if (w.id == id) return w;
  }
  return null;
}

Future<void> setCurrentWalletId(String? id) async {
  const storage = FlutterSecureStorage();
  if (id == null || id.isEmpty) {
    await storage.delete(key: _currentIdKey);
  } else {
    await storage.write(key: _currentIdKey, value: id);
  }
}

Future<void> _writeWallets(List<WalletAccount> wallets) async {
  const storage = FlutterSecureStorage();
  final json = jsonEncode(wallets.map((w) => w.toJson()).toList());
  await storage.write(key: _walletsKey, value: json);
}

/// Adds a wallet. If a wallet with the same (url, adminKey) already exists,
/// returns the existing record without creating a duplicate.
Future<WalletAccount> addWallet({
  required String url,
  required String adminKey,
  String? label,
}) async {
  final wallets = await listWallets();
  for (final w in wallets) {
    if (w.url == url && w.adminKey == adminKey) return w;
  }
  final fallbackLabel = (label != null && label.trim().isNotEmpty)
      ? label.trim()
      : _defaultLabelFromUrl(url);
  final w = WalletAccount(
    id: _generateWalletId(),
    label: fallbackLabel,
    url: url,
    adminKey: adminKey,
  );
  await _writeWallets([...wallets, w]);
  return w;
}

/// Caches the LNbits server-side wallet UUID on the local record. Called
/// lazily from Home on first successful `_load` so the avatar can seed
/// from a cross-device-stable id even without a public identifier.
Future<void> setServerWalletId(String id, String serverWalletId) async {
  if (serverWalletId.trim().isEmpty) return;
  final wallets = await listWallets();
  final next = [
    for (final w in wallets)
      w.id == id ? w.copyWith(serverWalletId: serverWalletId) : w,
  ];
  await _writeWallets(next);
}

/// Updates a wallet's connection details and/or label in place. Clears
/// the cached `serverWalletId` when (url, adminKey) changes — that
/// cache is keyed by the connection, so it'd be stale after the edit
/// and Home._load will re-fetch lazily.
Future<void> updateWallet(
  String id, {
  required String url,
  required String adminKey,
  String? label,
}) async {
  final wallets = await listWallets();
  final next = [...wallets];
  for (var i = 0; i < next.length; i++) {
    final w = next[i];
    if (w.id != id) continue;
    final connChanged = w.url != url || w.adminKey != adminKey;
    final newLabel = (label != null && label.trim().isNotEmpty)
        ? label.trim()
        : w.label;
    next[i] = WalletAccount(
      id: w.id,
      label: newLabel,
      url: url,
      adminKey: adminKey,
      serverWalletId: connChanged ? null : w.serverWalletId,
    );
    break;
  }
  await _writeWallets(next);
}

/// Removes the wallet and its per-wallet "My Contact" entries. If it was
/// the active wallet, auto-selects the first remaining wallet as active so
/// the rest of the app always has a usable wallet; if none remain, leaves
/// `current_wallet_id` unset (caller routes to the setup screen).
Future<void> removeWallet(String id) async {
  const storage = FlutterSecureStorage();
  final wallets = await listWallets();
  final next = wallets.where((w) => w.id != id).toList();
  await _writeWallets(next);
  await storage.delete(key: myLnAddressKey(id));
  await storage.delete(key: myBolt12OfferKey(id));
  await storage.delete(key: myLnurlpLinkKey(id));
  await storage.delete(key: myDefaultContactKindKey(id));
  await storage.delete(key: lastSeenBalanceKey(id));
  final currentId = await getCurrentWalletId();
  if (currentId == id) {
    if (next.isNotEmpty) {
      await storage.write(key: _currentIdKey, value: next.first.id);
    } else {
      await storage.delete(key: _currentIdKey);
    }
  }
}

/// One-shot migration from the pre-multi-wallet flat-key layout. Idempotent:
/// reading `wallets_v1` short-circuits after the first run. Call once at
/// startup, before any other LNbits or My-Contact access.
Future<void> migrateLegacyStorageIfNeeded() async {
  const storage = FlutterSecureStorage();
  final existing = await storage.read(key: _walletsKey);
  if (existing != null) return;

  final url = (await storage.read(key: _legacyUrlKey))?.trim() ?? '';
  final admin = (await storage.read(key: _legacyAdminKey))?.trim() ?? '';
  if (url.isEmpty || admin.isEmpty) {
    await _writeWallets(const []);
    return;
  }

  final w = WalletAccount(
    id: _generateWalletId(),
    label: _defaultLabelFromUrl(url),
    url: url,
    adminKey: admin,
  );

  final legacyAddress = await storage.read(key: _legacyLnAddressKey);
  final legacyOffer = await storage.read(key: _legacyBolt12Key);
  final legacyLnurlp = await storage.read(key: _legacyLnurlpKey);

  if (legacyAddress != null && legacyAddress.isNotEmpty) {
    await storage.write(key: myLnAddressKey(w.id), value: legacyAddress);
  }
  if (legacyOffer != null && legacyOffer.isNotEmpty) {
    await storage.write(key: myBolt12OfferKey(w.id), value: legacyOffer);
  }
  if (legacyLnurlp != null && legacyLnurlp.isNotEmpty) {
    await storage.write(key: myLnurlpLinkKey(w.id), value: legacyLnurlp);
  }

  await _writeWallets([w]);
  await storage.write(key: _currentIdKey, value: w.id);

  await storage.delete(key: _legacyUrlKey);
  await storage.delete(key: _legacyAdminKey);
  await storage.delete(key: _legacyLnAddressKey);
  await storage.delete(key: _legacyBolt12Key);
  await storage.delete(key: _legacyLnurlpKey);
}

String _defaultLabelFromUrl(String url) {
  try {
    final host = Uri.parse(url).host;
    if (host.isNotEmpty) return host;
  } catch (_) {}
  return url;
}

String _generateWalletId() {
  final rng = Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  return [for (final b in bytes) b.toRadixString(16).padLeft(2, '0')].join();
}
