import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'lnbits_service.dart';
import 'wallet_account_service.dart';

/// Offline copy of a wallet's transaction history, so the History screen can
/// open without a connection (flight mode, server down). Stored per wallet in
/// secure storage (encrypted at rest, excluded from backups like the API keys)
/// and replaced on every successful online load.
typedef CachedPayments = ({List<Payment> payments, DateTime savedAt});

const _cacheVersion = 1;

Future<void> saveCachedPayments(String walletId, List<Payment> payments) async {
  const storage = FlutterSecureStorage();
  final data = {
    'v': _cacheVersion,
    'savedAt': DateTime.now().toUtc().toIso8601String(),
    'payments': [for (final p in payments) p.toCacheJson()],
  };
  await storage.write(key: paymentsCacheKey(walletId), value: jsonEncode(data));
}

/// The cached history of [walletId], or null when there is none or it can't
/// be read (corrupt or from an incompatible version). Never throws.
Future<CachedPayments?> loadCachedPayments(String walletId) async {
  try {
    const storage = FlutterSecureStorage();
    final raw = await storage.read(key: paymentsCacheKey(walletId));
    if (raw == null || raw.isEmpty) return null;
    final data = jsonDecode(raw);
    if (data is! Map || data['v'] != _cacheVersion) return null;
    final savedAt = DateTime.tryParse(data['savedAt'] as String? ?? '');
    final list = data['payments'];
    if (savedAt == null || list is! List) return null;
    return (
      payments: [
        for (final e in list) Payment.fromJson(Map<String, dynamic>.from(e as Map)),
      ],
      savedAt: savedAt.toLocal(),
    );
  } catch (_) {
    return null;
  }
}
