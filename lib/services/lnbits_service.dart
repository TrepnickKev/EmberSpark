import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bolt11.dart';
import 'http_client_factory.dart';
import 'lnurl.dart';
import 'wallet_account_service.dart';
import 'wallet_backend.dart';

/// Thrown by [LNbitsService.payInvoice] when the invoice being paid was created
/// by the same wallet — paying yourself is a no-op and is cancelled.
class SelfPaymentException implements Exception {
  const SelfPaymentException();
  @override
  String toString() => 'Self-payment: the invoice belongs to this wallet';
}

/// Thrown by [LNbitsService.payInvoice] when the active wallet is read-only
/// (its key is an LNbits invoice/read key that cannot send).
class ReadOnlyWalletException implements Exception {
  const ReadOnlyWalletException();
  @override
  String toString() => 'Read-only wallet: sending is not possible';
}

class LNbitsService implements WalletBackend {
  final String baseUrl;
  final String adminKey;
  final bool readOnly;
  final http.Client _client;

  LNbitsService({
    required this.baseUrl,
    required this.adminKey,
    required http.Client client,
    this.readOnly = false,
  }) : _client = client;

  static Future<LNbitsService> fromStorage() async {
    final w = await getCurrentWallet();
    return LNbitsService(
      baseUrl: w?.url ?? '',
      adminKey: w?.adminKey ?? '',
      readOnly: w?.readOnly ?? false,
      client: await getHttpClient(),
    );
  }

  /// Best-effort probe of whether [key] can send from [url] (has admin scope).
  /// Fires a deliberately-malformed outgoing-payment request: LNbits rejects an
  /// invoice/read key with 401/403 before the (empty) invoice is ever decoded,
  /// so nothing is paid or created. Returns true when inconclusive (network
  /// error) so a real wallet is never wrongly flagged read-only.
  static Future<bool> canSendWith(String url, String key) async {
    try {
      final client = await getHttpClient();
      final base = url.replaceFirst(RegExp(r'/+$'), '');
      final onion = Uri.parse(base).host.toLowerCase().endsWith('.onion');
      final res = await client
          .post(
            Uri.parse('$base/api/v1/payments'),
            headers: {'Content-Type': 'application/json', 'X-Api-Key': key},
            body: jsonEncode({'out': true, 'bolt11': ''}),
          )
          .timeout(Duration(seconds: onion ? 60 : 15));
      return res.statusCode != 401 && res.statusCode != 403;
    } catch (_) {
      return true;
    }
  }

  /// Cleans up a user-entered URL: trims, supplies a scheme if missing
  /// (http for .onion, https otherwise), strips any path/query/fragment.
  /// Throws [FormatException] on input that can't be parsed as http(s).
  static String normalizeBaseUrl(String input) {
    var s = input.trim();
    if (s.isEmpty) {
      throw const FormatException('URL is empty');
    }
    if (!s.contains('://')) {
      final hostPart = s.split('/').first.toLowerCase();
      s = '${hostPart.endsWith('.onion') ? 'http' : 'https'}://$s';
    }
    final uri = Uri.tryParse(s);
    if (uri == null || uri.host.isEmpty) {
      throw FormatException('Invalid URL: $input');
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw FormatException('URL must be http or https, got "${uri.scheme}"');
    }
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$port';
  }

  bool get _isOnion => Uri.parse(baseUrl).host.toLowerCase().endsWith('.onion');
  Duration get _readTimeout =>
      _isOnion ? const Duration(seconds: 60) : const Duration(seconds: 15);
  Duration get _payTimeout =>
      _isOnion ? const Duration(seconds: 120) : const Duration(seconds: 60);

  Map<String, String> _headers(String key) => {
        'Content-Type': 'application/json',
        'X-Api-Key': key,
      };

  Uri _uri(String path) =>
      Uri.parse('${baseUrl.replaceAll(RegExp(r'/+$'), '')}$path');

  /// Returns the LNbits server-side wallet UUID. Stable across devices —
  /// the same LNbits wallet (URL + admin key) on a new phone returns the
  /// same id. Used as a cross-device avatar seed fallback when the user
  /// hasn't set a public identifier under My Contact yet.
  Future<String> getServerWalletId() async {
    final res = await _client
        .get(_uri('/api/v1/wallet'), headers: _headers(adminKey))
        .timeout(_readTimeout);
    if (res.statusCode != 200) {
      throw Exception('LNbits ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final id = data['id'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('Empty wallet id from LNbits');
    }
    return id;
  }

  @override
  Future<int> getBalanceSats() async {
    final res = await _client
        .get(_uri('/api/v1/wallet'), headers: _headers(adminKey))
        .timeout(_readTimeout);
    if (res.statusCode != 200) {
      throw Exception('LNbits ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final msat = (data['balance'] as num).toInt();
    return msat ~/ 1000;
  }

  @override
  Future<void> payInvoice(String bolt11) async {
    // Read-only wallets (invoice/read key) cannot send. Block every send path
    // here with a clear error rather than a raw 401 from LNbits.
    if (readOnly) throw const ReadOnlyWalletException();
    // Refuse to pay an invoice this same wallet created (paying yourself is a
    // no-op). Best-effort: if the ownership check can't be determined, proceed
    // so a transient glitch never blocks a legitimate payment.
    final hash = decodeBolt11(bolt11)?.paymentHash ?? '';
    if (hash.isNotEmpty) {
      bool owns;
      try {
        owns = await _walletOwnsInvoice(hash);
      } catch (_) {
        owns = false; // fail open
      }
      if (owns) throw const SelfPaymentException();
    }
    final res = await _client
        .post(
          _uri('/api/v1/payments'),
          headers: _headers(adminKey),
          body: jsonEncode({'out': true, 'bolt11': bolt11}),
        )
        .timeout(_payTimeout);
    if (res.statusCode >= 400) {
      throw Exception('Payment failed (${res.statusCode}): ${res.body}');
    }
  }

  /// Whether an invoice with [paymentHash] exists in THIS wallet — i.e. this
  /// wallet created it. The endpoint is scoped to the wallet key, so it returns
  /// 200 only for own invoices and 404 for anything external.
  Future<bool> _walletOwnsInvoice(String paymentHash) async {
    final res = await _client
        .get(_uri('/api/v1/payments/$paymentHash'), headers: _headers(adminKey))
        .timeout(_readTimeout);
    return res.statusCode == 200;
  }

  @override
  Future<String> createInvoice({
    required int amountSats,
    required String memo,
  }) async {
    final res = await _client
        .post(
          _uri('/api/v1/payments'),
          headers: _headers(adminKey),
          body: jsonEncode({
            'out': false,
            'amount': amountSats,
            'memo': memo,
          }),
        )
        .timeout(_readTimeout);
    if (res.statusCode >= 400) {
      throw Exception('Invoice creation failed (${res.statusCode}): ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['payment_request'] as String;
  }

  /// Creates an LNURL-pay link on the LNbits `lnurlp` extension and returns
  /// the bech32 `lnurl1…` string. Throws [LnurlpExtensionDisabled] if the
  /// extension isn't installed (404 from the endpoint).
  Future<String> createLnurlpLink({
    String description = 'EmberSpark LNURL',
    int minSats = 1,
    int maxSats = 1000000,
    int commentChars = 100,
  }) async {
    final res = await _client
        .post(
          _uri('/lnurlp/api/v1/links'),
          headers: _headers(adminKey),
          body: jsonEncode({
            'description': description,
            'min': minSats,
            'max': maxSats,
            'comment_chars': commentChars,
          }),
        )
        .timeout(_readTimeout);
    if (res.statusCode == 404) {
      throw const LnurlpExtensionDisabled();
    }
    if (res.statusCode >= 400) {
      throw Exception('LNbits ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final lnurl = data['lnurl'] as String?;
    if (lnurl == null || lnurl.isEmpty) {
      throw const FormatException('Empty lnurl from createLnurlpLink');
    }
    return canonicalizeLnurl(lnurl);
  }

  /// Creates a BOLT12 offer on the LNbits BOLT12 community extension and
  /// returns the bech32 `lno1…` string. Throws [Bolt12NotSupported] if the
  /// extension isn't installed (404) or the backend doesn't support
  /// BOLT12.
  Future<String> createBolt12Offer({
    String description = 'EmberSpark BOLT12',
    int? amountSats,
  }) async {
    final res = await _client
        .post(
          _uri('/bolt12/api/v1/offers'),
          headers: _headers(adminKey),
          body: jsonEncode({
            'description': description,
            if (amountSats != null) 'amount_msat': amountSats * 1000,
          }),
        )
        .timeout(_readTimeout);
    if (res.statusCode == 404) {
      throw const Bolt12NotSupported();
    }
    if (res.statusCode >= 400) {
      throw Exception('LNbits ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final offer = (data['offer'] ?? data['bolt12']) as String?;
    if (offer == null || offer.isEmpty) {
      throw const FormatException('Empty offer from createBolt12Offer');
    }
    return offer;
  }

  /// Lists this wallet's LNURL-pay links (lnurlp extension). Throws
  /// [LnurlpExtensionDisabled] if the extension isn't installed (404).
  Future<List<Map<String, dynamic>>> listLnurlpLinks() async {
    final res = await _client
        .get(_uri('/lnurlp/api/v1/links'), headers: _headers(adminKey))
        .timeout(_readTimeout);
    if (res.statusCode == 404) {
      throw const LnurlpExtensionDisabled();
    }
    if (res.statusCode >= 400) {
      throw Exception('LNbits ${res.statusCode}: ${res.body}');
    }
    final body = jsonDecode(res.body);
    final List raw = body is List
        ? body
        : (body is Map && body['data'] is List ? body['data'] as List : const []);
    return raw.whereType<Map<String, dynamic>>().toList();
  }

  /// Lists this wallet's BOLT12 offers. Throws [Bolt12NotSupported] if the
  /// extension/backend isn't available (404).
  Future<List<Map<String, dynamic>>> listBolt12Offers() async {
    final res = await _client
        .get(_uri('/bolt12/api/v1/offers'), headers: _headers(adminKey))
        .timeout(_readTimeout);
    if (res.statusCode == 404) {
      throw const Bolt12NotSupported();
    }
    if (res.statusCode >= 400) {
      throw Exception('LNbits ${res.statusCode}: ${res.body}');
    }
    final body = jsonDecode(res.body);
    final List raw = body is List
        ? body
        : (body is Map && body['data'] is List ? body['data'] as List : const []);
    return raw.whereType<Map<String, dynamic>>().toList();
  }

  /// Returns an existing LNURL-pay link for this wallet if the server already
  /// has a suitable one, otherwise creates a fresh one. Reuse priority:
  /// 1. a link with a `username` set (it backs a Lightning Address, so the
  ///    LNURL-pay tab resolves to the user's real address);
  /// 2. a link whose description starts with `EmberSpark` (covers links made
  ///    before the `EmberSpark LNURL` rename);
  /// 3. create a new `EmberSpark LNURL` link.
  /// Reusing avoids piling up duplicate links on repeated Auto-generate taps.
  Future<String> getOrCreateLnurlpLink() async {
    String? lnAddressLnurl; // link backing a Lightning Address (username set)
    String? emberLnurl; // generic EmberSpark-created link
    for (final link in await listLnurlpLinks()) {
      final lnurl = link['lnurl'] as String?;
      if (lnurl == null || lnurl.isEmpty) continue;
      final username = (link['username'] as String?)?.trim() ?? '';
      final desc = (link['description'] as String?) ?? '';
      if (username.isNotEmpty) {
        lnAddressLnurl ??= lnurl;
      } else if (desc.startsWith('EmberSpark')) {
        emberLnurl ??= lnurl;
      }
    }
    final chosen = lnAddressLnurl ?? emberLnurl;
    if (chosen != null) return canonicalizeLnurl(chosen);
    return createLnurlpLink();
  }

  /// Sets (or changes) the `username` on this wallet's LNURL-pay link so the
  /// server serves the Lightning Address `username@<domain>`. Reuses the link
  /// that already backs a Lightning Address, else an `EmberSpark` link, else
  /// creates a fresh link carrying the username. Throws
  /// [LnurlpExtensionDisabled] if the extension isn't installed (404), or an
  /// Exception carrying the server's message (e.g. the username is already
  /// taken or invalid).
  Future<void> setLnurlpUsername(String username) async {
    final links = await listLnurlpLinks();
    Map<String, dynamic>? target;
    for (final l in links) {
      if (((l['username'] as String?)?.trim() ?? '').isNotEmpty) {
        target = l;
        break;
      }
    }
    if (target == null) {
      for (final l in links) {
        if (((l['description'] as String?) ?? '').startsWith('EmberSpark')) {
          target = l;
          break;
        }
      }
    }

    final http.Response res;
    if (target == null) {
      // No reusable link: create one carrying the username.
      res = await _client
          .post(
            _uri('/lnurlp/api/v1/links'),
            headers: _headers(adminKey),
            body: jsonEncode({
              'description': 'EmberSpark LNURL',
              'min': 1,
              'max': 1000000,
              'comment_chars': 100,
              'username': username,
            }),
          )
          .timeout(_readTimeout);
    } else {
      // Update the existing link, preserving its amounts/description.
      final id = (target['id'] ?? '').toString();
      res = await _client
          .put(
            _uri('/lnurlp/api/v1/links/$id'),
            headers: _headers(adminKey),
            body: jsonEncode({
              'description': target['description'] ?? 'EmberSpark LNURL',
              'min': target['min'] ?? 1,
              'max': target['max'] ?? 1000000,
              'comment_chars': target['comment_chars'] ?? 100,
              'username': username,
            }),
          )
          .timeout(_readTimeout);
    }
    if (res.statusCode == 404) {
      throw const LnurlpExtensionDisabled();
    }
    if (res.statusCode >= 400) {
      throw Exception('LNbits ${res.statusCode}: ${res.body}');
    }
  }

  /// BOLT12 counterpart of [getOrCreateLnurlpLink]. Skips inactive offers so
  /// a disabled offer isn't reused.
  Future<String> getOrCreateBolt12Offer() async {
    for (final o in await listBolt12Offers()) {
      final desc = (o['description'] as String?) ?? '';
      final value = (o['offer'] ?? o['bolt12']) as String?;
      if (desc.startsWith('EmberSpark') &&
          value != null &&
          value.isNotEmpty &&
          o['active'] != false) {
        return value;
      }
    }
    return createBolt12Offer();
  }

  /// Asks the LNbits BOLT12 community extension to fetch a BOLT12 invoice
  /// (`lni1...`) from an offer (`lno1...`). Returns the invoice string on
  /// success; throws [Bolt12NotSupported] if the extension isn't installed
  /// (404), or a generic Exception for other failures.
  Future<String> fetchBolt12Invoice({
    required String offer,
    required int amountSats,
    String? memo,
  }) async {
    final res = await _client
        .post(
          _uri('/bolt12/api/v1/fetchinvoice'),
          headers: _headers(adminKey),
          body: jsonEncode({
            'offer': offer,
            'amount_msat': amountSats * 1000,
            if (memo != null && memo.isNotEmpty) 'payer_note': memo,
          }),
        )
        .timeout(_readTimeout);
    if (res.statusCode == 404) {
      throw const Bolt12NotSupported();
    }
    if (res.statusCode >= 400) {
      throw Exception('LNbits ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final invoice =
        (data['invoice'] ?? data['bolt12'] ?? data['bolt11']) as String?;
    if (invoice == null || invoice.isEmpty) {
      throw const FormatException('Empty invoice from fetchinvoice');
    }
    return invoice;
  }

  @override
  Future<bool> isInvoicePaid(String paymentHash) async {
    final res = await _client
        .get(_uri('/api/v1/payments/$paymentHash'), headers: _headers(adminKey))
        .timeout(_readTimeout);
    if (res.statusCode != 200) return false;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['paid'] == true || data['status'] == 'success';
  }

  @override
  Future<List<Payment>> listPayments({int limit = 50}) async {
    final res = await _client
        .get(
          _uri('/api/v1/payments?limit=$limit'),
          headers: _headers(adminKey),
        )
        .timeout(_readTimeout);
    if (res.statusCode != 200) {
      throw Exception('LNbits ${res.statusCode}: ${res.body}');
    }
    final body = jsonDecode(res.body);
    final List raw;
    if (body is List) {
      raw = body;
    } else if (body is Map && body['data'] is List) {
      raw = body['data'] as List;
    } else {
      throw const FormatException('Unexpected payments response');
    }
    return raw
        .map((e) => Payment.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class Payment {
  /// Sats; negative for outgoing, positive for incoming.
  final int amountSats;

  /// Sats. Always non-negative; only meaningful for outgoing payments.
  final int feeSats;
  final String memo;
  final String comment;
  final String bolt11;
  final DateTime time;
  final bool pending;
  final String paymentHash;

  const Payment({
    required this.amountSats,
    required this.feeSats,
    required this.memo,
    this.comment = '',
    this.bolt11 = '',
    required this.time,
    required this.pending,
    required this.paymentHash,
  });

  bool get incoming => amountSats > 0;

  factory Payment.fromJson(Map<String, dynamic> j) {
    final amountMsat = _toInt(j['amount']);
    final feeMsat = _toInt(j['fee']);
    final timeRaw = j['time'];
    final DateTime time;
    if (timeRaw is num) {
      time = DateTime.fromMillisecondsSinceEpoch(
        timeRaw.toInt() * 1000,
        isUtc: true,
      ).toLocal();
    } else if (timeRaw is String) {
      time = DateTime.tryParse(timeRaw)?.toLocal() ?? DateTime.now();
    } else {
      time = DateTime.now();
    }
    final pending = j['pending'] == true || j['status'] == 'pending';
    String comment = '';
    final extra = j['extra'];
    if (extra is Map) {
      final c = extra['comment'];
      if (c is String && c.isNotEmpty) {
        comment = c;
      } else {
        final c2 = extra['extra'];
        if (c2 is String && c2.isNotEmpty) comment = c2;
      }
    }
    final bolt11 = (j['bolt11'] as String?) ??
        (j['payment_request'] as String?) ??
        '';
    return Payment(
      amountSats: amountMsat ~/ 1000,
      feeSats: feeMsat.abs() ~/ 1000,
      memo: (j['memo'] as String?) ?? '',
      comment: comment,
      bolt11: bolt11,
      time: time,
      pending: pending,
      paymentHash: (j['payment_hash'] as String?) ?? '',
    );
  }

  /// Serialises this payment in the LNbits shape [Payment.fromJson] reads, so
  /// the offline history cache round-trips through the same parser.
  Map<String, dynamic> toCacheJson() => {
    'amount': amountSats * 1000,
    'fee': feeSats * 1000,
    'memo': memo,
    if (comment.isNotEmpty) 'extra': {'comment': comment},
    'bolt11': bolt11,
    'time': time.toUtc().toIso8601String(),
    'pending': pending,
    'payment_hash': paymentHash,
  };

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

/// Thrown by [LNbitsService.fetchBolt12Invoice] / [createBolt12Offer] when
/// the BOLT12 community extension isn't installed on the LNbits server
/// (404). The caller maps this to a friendly localized message rather than
/// the generic HTTP error.
class Bolt12NotSupported implements Exception {
  const Bolt12NotSupported();
  @override
  String toString() => 'BOLT12 not supported by this LNbits server';
}

/// Thrown by [LNbitsService.createLnurlpLink] when the `lnurlp` extension
/// isn't installed on the LNbits server (404). The caller maps this to a
/// friendly localized message rather than the generic HTTP error.
class LnurlpExtensionDisabled implements Exception {
  const LnurlpExtensionDisabled();
  @override
  String toString() => 'LNURLp extension not installed';
}
