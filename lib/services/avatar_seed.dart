// Helpers that derive the deterministic seed string passed to
// RandomAvatar(...). Same string → same avatar everywhere, which is the
// whole point of seeding from a public Lightning identity instead of a
// device-local random.

import 'my_contact_service.dart';
import 'wallet_account_service.dart';

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
/// LNbits server-side wallet UUID > local random id. Matches what most
/// contacts will save someone by, so the bubble matches their tile.
///
/// When [defaultKind] is set and its identifier is non-empty, the user has
/// pinned a default identity and it overrides the priority order. If the
/// pinned identifier is empty we fall through to the order as normal.
String avatarSeedForWallet({
  String? lnAddress,
  String? bolt12,
  String? lnurlp,
  String? serverWalletId,
  required String fallbackLocalId,
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
  for (final s in [lnAddress, bolt12, lnurlp, serverWalletId]) {
    if (s != null && s.trim().isNotEmpty) return normalizeDestination(s);
  }
  return fallbackLocalId;
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
    serverWalletId: w?.serverWalletId,
    fallbackLocalId: w?.id ?? '',
    defaultKind: results[4] as MyContactKind?,
  );
  return (seed: seed, name: w?.label ?? '');
}
