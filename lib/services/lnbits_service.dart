import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'http_client_factory.dart';

class LNbitsService {
  final String baseUrl;
  final String adminKey;
  final http.Client _client;

  LNbitsService({
    required this.baseUrl,
    required this.adminKey,
    required http.Client client,
  }) : _client = client;

  static Future<LNbitsService> fromStorage() async {
    const storage = FlutterSecureStorage();
    final url = await storage.read(key: 'url') ?? '';
    final admin = await storage.read(key: 'admin_key') ?? '';
    return LNbitsService(
      baseUrl: url,
      adminKey: admin,
      client: await getHttpClient(),
    );
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

  Future<void> payInvoice(String bolt11) async {
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
    String description = 'EmberSpark',
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
    return lnurl;
  }

  /// Creates a BOLT12 offer on the LNbits BOLT12 community extension and
  /// returns the bech32 `lno1…` string. Throws [Bolt12NotSupported] if the
  /// extension isn't installed (404) or the backend doesn't support
  /// BOLT12.
  Future<String> createBolt12Offer({
    String description = 'EmberSpark',
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
  final DateTime time;
  final bool pending;
  final String paymentHash;

  const Payment({
    required this.amountSats,
    required this.feeSats,
    required this.memo,
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
    return Payment(
      amountSats: amountMsat ~/ 1000,
      feeSats: feeMsat.abs() ~/ 1000,
      memo: (j['memo'] as String?) ?? '',
      time: time,
      pending: pending,
      paymentHash: (j['payment_hash'] as String?) ?? '',
    );
  }

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
