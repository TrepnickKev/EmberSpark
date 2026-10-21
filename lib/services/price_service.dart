import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'http_client_factory.dart';

const supportedCurrencies = ['USD', 'EUR', 'GBP', 'CHF', 'CAD', 'AUD', 'JPY'];
const _currencyKey = 'fiat_currency';
const _defaultCurrency = 'USD';
const _cacheDuration = Duration(minutes: 5);

/// Which unit the user wants amounts displayed in across Home and History.
/// Toggled by tapping any amount; persisted to `amount_display_mode`.
enum AmountDisplayMode { sats, fiat }

final amountDisplayMode =
    ValueNotifier<AmountDisplayMode>(AmountDisplayMode.sats);

const _amountDisplayKey = 'amount_display_mode';

Future<void> loadAmountDisplayMode() async {
  const storage = FlutterSecureStorage();
  final v = await storage.read(key: _amountDisplayKey);
  amountDisplayMode.value =
      v == 'fiat' ? AmountDisplayMode.fiat : AmountDisplayMode.sats;
}

Future<void> toggleAmountDisplayMode() async {
  const storage = FlutterSecureStorage();
  final next = amountDisplayMode.value == AmountDisplayMode.sats
      ? AmountDisplayMode.fiat
      : AmountDisplayMode.sats;
  await storage.write(
    key: _amountDisplayKey,
    value: next == AmountDisplayMode.fiat ? 'fiat' : 'sats',
  );
  amountDisplayMode.value = next;
}

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

// Last successfully fetched rates, persisted so fiat values still show offline
// (also after a restart). Stale by nature; only used when the fetch fails.
const _lastRatesKey = 'btc_rates_last_v1';

/// Fetches BTC prices for all supported currencies from mempool.space.
/// Cached for 5 minutes; on network error returns the last cached map, then
/// the last persisted one (or null if there is none).
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
    if (res.statusCode != 200) {
      return cached?.rates ?? await _loadPersistedRates();
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final rates = <String, double>{};
    for (final c in supportedCurrencies) {
      final v = data[c];
      if (v is num) rates[c] = v.toDouble();
    }
    _cache = _RateCache(rates, DateTime.now());
    await _persistRates(rates);
    return rates;
  } catch (_) {
    return cached?.rates ?? await _loadPersistedRates();
  }
}

Future<void> _persistRates(Map<String, double> rates) async {
  try {
    const storage = FlutterSecureStorage();
    await storage.write(
      key: _lastRatesKey,
      value: jsonEncode({
        'fetchedAt': DateTime.now().toUtc().toIso8601String(),
        'rates': rates,
      }),
    );
  } catch (_) {}
}

Future<Map<String, double>?> _loadPersistedRates() async {
  try {
    const storage = FlutterSecureStorage();
    final raw = await storage.read(key: _lastRatesKey);
    if (raw == null) return null;
    final rates = (jsonDecode(raw) as Map)['rates'] as Map;
    return {
      for (final e in rates.entries)
        if (e.value is num) e.key as String: (e.value as num).toDouble(),
    };
  } catch (_) {
    return null;
  }
}

// Historical BTC prices for the transaction history. Keyed by currency + UTC
// day: a past day's price does not change, so this dedupes same-day payments
// and repeat history opens. Persisted (loaded lazily once, written back after
// a batch adds new days) so the offline history still shows fiat values.
final _histCache = <String, double>{};
const _histPricesKey = 'btc_hist_prices_v1';
const _histMaxEntries = 3000;
bool _histDirty = false;
// Shared so parallel lookups all wait for the same single storage read.
Future<void>? _histLoad;

Future<void> _ensureHistLoaded() => _histLoad ??= _loadHist();

Future<void> _loadHist() async {
  try {
    const storage = FlutterSecureStorage();
    final raw = await storage.read(key: _histPricesKey);
    if (raw == null) return;
    final saved = jsonDecode(raw) as Map;
    for (final e in saved.entries) {
      if (e.value is num) {
        _histCache.putIfAbsent(e.key as String, () => (e.value as num).toDouble());
      }
    }
  } catch (_) {}
}

Future<void> _persistHist() async {
  if (!_histDirty) return;
  _histDirty = false;
  // Insertion order = oldest first (loaded entries, then new fetches), so drop
  // from the front to stay within the cap.
  while (_histCache.length > _histMaxEntries) {
    _histCache.remove(_histCache.keys.first);
  }
  try {
    const storage = FlutterSecureStorage();
    await storage.write(key: _histPricesKey, value: jsonEncode(_histCache));
  } catch (_) {}
}

String btcHistKey(String currency, DateTime t) {
  final u = t.toUtc();
  return '$currency|${u.year}-${u.month}-${u.day}';
}

/// BTC price in [currency] at [time] from mempool.space's historical-price
/// endpoint. Cached per currency+day. Returns null on any failure so callers
/// fall back to the current rate.
Future<double?> getBtcRateAt(String currency, DateTime time) async {
  await _ensureHistLoaded();
  final key = btcHistKey(currency, time);
  final cached = _histCache[key];
  if (cached != null) return cached;
  try {
    final ts = time.millisecondsSinceEpoch ~/ 1000;
    final client = await getHttpClient();
    final res = await client
        .get(
          Uri.parse(
            'https://mempool.space/api/v1/historical-price'
            '?currency=$currency&timestamp=$ts',
          ),
          headers: browserLikeHeaders,
        )
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final prices = data['prices'];
    if (prices is! List || prices.isEmpty) return null;
    final first = prices.first;
    final v = first is Map ? first[currency] : null;
    if (v is num) {
      _histCache[key] = v.toDouble();
      _histDirty = true;
      return v.toDouble();
    }
    return null;
  } catch (_) {
    return null;
  }
}

/// Warms historical prices for a set of [times] (e.g. the visible history
/// list). Dedupes by currency+day and fetches a few at a time. Returns
/// `{ btcHistKey: rate }` for the days that resolved.
Future<Map<String, double>> getBtcRatesAt(
  String currency,
  Iterable<DateTime> times,
) async {
  final byKey = <String, DateTime>{};
  for (final t in times) {
    byKey.putIfAbsent(btcHistKey(currency, t), () => t);
  }
  final result = <String, double>{};
  final entries = byKey.entries.toList();
  const cap = 5;
  for (var i = 0; i < entries.length; i += cap) {
    final chunk = entries.skip(i).take(cap);
    await Future.wait(chunk.map((e) async {
      final r = await getBtcRateAt(currency, e.value);
      if (r != null) result[e.key] = r;
    }));
  }
  await _persistHist();
  return result;
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
  if (value > 0 && value < 0.01) {
    return '< 0.01 $currency';
  }
  final whole = value.floor();
  final cents = ((value - whole) * 100).round();
  return '${formatThousands(whole)}.${cents.toString().padLeft(2, '0')} $currency';
}

/// Like [formatFiat] but prepends the approximation marker "≈ " unless
/// the value is below one cent. Sub-cent values render as "<0.01 EUR";
/// the "<" already conveys imprecision so the "≈ " is suppressed.
String formatFiatApprox(double value, String currency) {
  if (value > 0 && value < 0.01) {
    return '< 0.01 $currency';
  }
  return '≈ ${formatFiat(value, currency)}';
}
