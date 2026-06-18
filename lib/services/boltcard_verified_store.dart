import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Remembers which Bolt Cards the user has successfully verified, by their
/// LNbits `external_id`, so the list can show a durable "Verified" badge across
/// reloads and app restarts. A verification is cleared when the card is
/// (re)programmed, wiped, or deleted, since those invalidate it.
const _key = 'boltcard_verified_ids';

Future<Set<String>> getVerifiedCardIds() async {
  const storage = FlutterSecureStorage();
  final raw = await storage.read(key: _key);
  if (raw == null || raw.isEmpty) return <String>{};
  try {
    final list = jsonDecode(raw);
    if (list is List) return list.whereType<String>().toSet();
  } catch (_) {
    // Corrupt value: treat as empty.
  }
  return <String>{};
}

Future<void> markCardVerified(String externalId) async {
  if (externalId.isEmpty) return;
  final ids = await getVerifiedCardIds()..add(externalId);
  await _write(ids);
}

Future<void> unmarkCardVerified(String externalId) async {
  final ids = await getVerifiedCardIds();
  if (ids.remove(externalId)) await _write(ids);
}

Future<void> _write(Set<String> ids) async {
  const storage = FlutterSecureStorage();
  await storage.write(key: _key, value: jsonEncode(ids.toList()));
}
