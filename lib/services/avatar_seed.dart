// Helpers that derive the deterministic seed string passed to
// RandomAvatar(...). Same string → same avatar everywhere, which is the
// whole point of seeding from a public Lightning identity instead of a
// device-local random.

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import 'my_contact_service.dart';
import 'wallet_account_service.dart';

/// Stable, device-independent avatar seed for a wallet that has no shared
/// Lightning identity. Derived from the wallet's stored key with an HMAC, the
/// same basis LNURL-auth uses (see lnurl_auth.dart), so the avatar survives a
/// reinstall and matches on any device that re-enters the same key, instead of
/// the random local wallet id. Uses a distinct domain tag from the LNURL-auth
/// seed so the two can't be correlated, and is one-way so it never exposes the
/// key.
String walletKeyAvatarSeed(String walletSecret) {
  final hmac = HMac(SHA256Digest(), 64)
    ..init(KeyParameter(Uint8List.fromList(utf8.encode(walletSecret.trim()))));
  final out = hmac.process(
    Uint8List.fromList(utf8.encode('emberspark-avatar-seed-v1')),
  );
  return out.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// The stable fallback seed for [w] when it has no LN address / LNURL / BOLT12:
/// the wallet-key-derived seed, or (only if the key is somehow empty) the local
/// id. Empty when there is no wallet.
String fallbackAvatarSeedFor(WalletAccount? w) {
  if (w == null) return '';
  final key = w.adminKey.trim();
  return key.isEmpty ? w.id : walletKeyAvatarSeed(key);
}

/// Normalises a Lightning destination so identical identities written in
/// different forms produce the same hash. Strips `lightning:` / `lnurl:`
/// prefixes, trims whitespace, lowercases.
String normalizeDestination(String s) =>
    s.trim().replaceFirst(
      RegExp(r'^(lightning|lnurl):', caseSensitive: false),
      '',
    ).toLowerCase();

/// Picks the most-shared public identifier as the seed, falling through to
/// less-shared ones. Order: LN address > BOLT12 offer > LNURL-pay link >
/// [fallbackSeed] (the stable wallet-key-derived seed, see
/// [fallbackAvatarSeedFor]). Matches what most contacts will save someone by,
/// so the bubble matches their tile.
///
/// When [defaultKind] is set and its identifier is non-empty, the user has
/// pinned a default identity and it overrides the priority order. If the
/// pinned identifier is empty we fall through to the order as normal.
String avatarSeedForWallet({
  String? lnAddress,
  String? bolt12,
  String? lnurlp,
  required String fallbackSeed,
  MyContactKind? defaultKind,
}) {
  if (defaultKind != null) {
    final chosen = switch (defaultKind) {
      MyContactKind.lnAddress => lnAddress,
      MyContactKind.lnurlp => lnurlp,
      MyContactKind.bolt12 => bolt12,
    };
    if (chosen != null && chosen.trim().isNotEmpty) {
      return normalizeDestination(chosen);
    }
  }
  for (final s in [lnAddress, bolt12, lnurlp]) {
    if (s != null && s.trim().isNotEmpty) return normalizeDestination(s);
  }
  return fallbackSeed;
}

/// Computes the avatar seed for a specific [w] (not necessarily the active
/// wallet), reading that wallet's stored identities by id. Uses the same
/// priority as the active-wallet seed in Home, so a wallet's avatar looks the
/// same whether it's shown in the swipe-to-switch carousel or after it becomes
/// active. Returns '' when nothing seeds it.
Future<String> avatarSeedForAccount(WalletAccount w) async {
  final results = await Future.wait([
    getMyLightningAddressFor(w.id),
    getMyBolt12OfferFor(w.id),
    getMyLnurlpLinkFor(w.id),
    getMyDefaultContactKindFor(w.id),
  ]);
  return avatarSeedForWallet(
    lnAddress: results[0] as String?,
    bolt12: results[1] as String?,
    lnurlp: results[2] as String?,
    fallbackSeed: fallbackAvatarSeedFor(w),
    defaultKind: results[3] as MyContactKind?,
  );
}

/// Loads the current wallet's avatar seed and display name. The seed uses
/// the same priority order as the home-screen profile bubble; the name is
/// the wallet's `label` (also what home shows under the profile bubble).
/// Either field may be empty if no wallet is configured. Used by the pay
/// screens to render the sender column of the route header.
Future<({String seed, String name})> getOwnAvatarInfo() async {
  final results = await Future.wait([
    getMyLightningAddress(),
    getMyBolt12Offer(),
    getMyLnurlpLink(),
    getCurrentWallet(),
    getMyDefaultContactKind(),
  ]);
  final w = results[3] as WalletAccount?;
  final seed = avatarSeedForWallet(
    lnAddress: results[0] as String?,
    bolt12: results[1] as String?,
    lnurlp: results[2] as String?,
    fallbackSeed: fallbackAvatarSeedFor(w),
    defaultKind: results[4] as MyContactKind?,
  );
  return (seed: seed, name: w?.label ?? '');
}
