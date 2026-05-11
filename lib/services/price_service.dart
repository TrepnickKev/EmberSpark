import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'http_client_factory.dart';

const supportedCurrencies = ['USD', 'EUR', 'GBP', 'CHF', 'CAD', 'AUD', 'JPY'];
const _currencyKey = 'fiat_currency';
const _defaultCurrency = 'USD';
const _cacheDuration = Duration(minutes: 5);

class _RateCache {
  final Map<String, double> rates;
  final DateTime fetchedAt;
  const _RateCache(this.rates, this.fetchedAt);
}

_RateCache? _cache;

Future<String> getSelectedCurrency() async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: _currencyKey) ?? _defaultCurrency;
}

Future<void> setSelectedCurrency(String currency) async {
  const storage = FlutterSecureStorage();
  await storage.write(key: _currencyKey, value: currency);
}

/// Fetches BTC prices for all supported currencies from mempool.space.
/// Cached for 5 minutes; on network error returns the last cached map (or
/// null if there is none).
Future<Map<String, double>?> getBtcRates() async {
  final cached = _cache;
  if (cached != null &&
      DateTime.now().difference(cached.fetchedAt) < _cacheDuration) {
    return cached.rates;
  }
  try {
    final client = await getHttpClient();
    final res = await client
        .get(
          Uri.parse('https://mempool.space/api/v1/prices'),
          headers: browserLikeHeaders,
        )
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return cached?.rates;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final rates = <String, double>{};
    for (final c in supportedCurrencies) {
      final v = data[c];
      if (v is num) rates[c] = v.toDouble();
    }
    _cache = _RateCache(rates, DateTime.now());
    return rates;
  } catch (_) {
    return cached?.rates;
  }
}

String formatThousands(int n) {
  final negative = n < 0;
  final s = n.abs().toString();
  final out = s.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return negative ? '-$out' : out;
}

String formatFiat(double value, String currency) {
  final whole = value.floor();
  final cents = ((value - whole) * 100).round();
  return '${formatThousands(whole)}.${cents.toString().padLeft(2, '0')} $currency';
}
