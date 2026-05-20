// Helpers that derive the deterministic seed string passed to
// RandomAvatar(...). Same string → same avatar everywhere, which is the
// whole point of seeding from a public Lightning identity instead of a
// device-local random.

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
String avatarSeedForWallet({
  String? lnAddress,
  String? bolt12,
  String? lnurlp,
  String? serverWalletId,
  required String fallbackLocalId,
}) {
  for (final s in [lnAddress, bolt12, lnurlp, serverWalletId]) {
    if (s != null && s.trim().isNotEmpty) return normalizeDestination(s);
  }
  return fallbackLocalId;
}
