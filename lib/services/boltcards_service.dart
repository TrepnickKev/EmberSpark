import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'http_client_factory.dart';
import 'wallet_account_service.dart';

/// A Bolt Card record as stored by the LNbits `boltcards` extension.
///
/// Mirrors the extension's `Card` model. The AES keys [k0]/[k1]/[k2] are hex
/// strings (32 chars / 16 bytes each); they are needed to program the physical
/// NTAG424 chip and to wipe it later, so they are kept as typed fields rather
/// than buried in a raw map.
class BoltCard {
  final String id;
  final String externalId;
  final String name;
  final String uid; // 7-byte chip UID, hex (may be empty until programmed)
  final int counter;
  final int txLimitSats;
  final int dailyLimitSats;
  final bool enabled;
  final String k0;
  final String k1;
  final String k2;

  const BoltCard({
    required this.id,
    required this.externalId,
    required this.name,
    required this.uid,
    required this.counter,
    required this.txLimitSats,
    required this.dailyLimitSats,
    required this.enabled,
    required this.k0,
    required this.k1,
    required this.k2,
  });

  factory BoltCard.fromJson(Map<String, dynamic> j) {
    int toInt(Object? v) =>
        v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
    return BoltCard(
      id: (j['id'] ?? '') as String,
      externalId: (j['external_id'] ?? '') as String,
      name: (j['card_name'] ?? '') as String,
      uid: (j['uid'] ?? '') as String,
      counter: toInt(j['counter']),
      txLimitSats: toInt(j['tx_limit']),
      dailyLimitSats: toInt(j['daily_limit']),
      enabled: j['enable'] != false,
      k0: (j['k0'] ?? '') as String,
      k1: (j['k1'] ?? '') as String,
      k2: (j['k2'] ?? '') as String,
    );
  }
}

/// Thrown when the LNbits server doesn't have the `boltcards` extension
/// installed/enabled (the endpoint answers 404). The UI maps this to a
/// friendly "extension not installed" message, matching how
/// [LnurlpExtensionDisabled] / [Bolt12NotSupported] are handled elsewhere.
class BoltcardsExtensionDisabled implements Exception {
  const BoltcardsExtensionDisabled();
  @override
  String toString() => 'Boltcards extension not installed';
}

/// Thrown by [BoltcardsService.createCard] when the server rejects the card
/// because its chip UID is already registered to another card record.
class BoltcardUidAlreadyRegistered implements Exception {
  const BoltcardUidAlreadyRegistered();
  @override
  String toString() => 'Card UID already registered';
}

/// Thin client for the LNbits `boltcards` extension REST API.
///
/// Construction mirrors [LNbitsService]: a [baseUrl] + admin [apiKey] + an
/// [http.Client]. All endpoints live under `/boltcards/api/v1/`.
class BoltcardsService {
  final String baseUrl;
  final String apiKey;
  final http.Client _client;

  BoltcardsService({
    required this.baseUrl,
    required this.apiKey,
    required http.Client client,
  }) : _client = client;

  static Future<BoltcardsService> fromStorage() async {
    final w = await getCurrentWallet();
    return BoltcardsService(
      baseUrl: w?.url ?? '',
      apiKey: w?.adminKey ?? '',
      client: await getHttpClient(),
    );
  }

  bool get _isOnion => Uri.parse(baseUrl).host.toLowerCase().endsWith('.onion');
  Duration get _timeout =>
      _isOnion ? const Duration(seconds: 60) : const Duration(seconds: 15);

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'X-Api-Key': apiKey,
      };

  Uri _uri(String path) =>
      Uri.parse('${baseUrl.replaceAll(RegExp(r'/+$'), '')}$path');

  /// The base URL a Bolt Card scan hits, e.g.
  /// `https://host/boltcards/api/v1/scan/<externalId>`. The `lnurlw://`
  /// template written to the chip is built from this (with `?p=…&c=…`).
  String scanBaseUrl(String externalId) =>
      '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/boltcards/api/v1/scan/$externalId';

  /// Lists this wallet's Bolt Cards. Throws [BoltcardsExtensionDisabled] on 404.
  Future<List<BoltCard>> listCards() async {
    final res = await _client
        .get(_uri('/boltcards/api/v1/cards'), headers: _headers())
        .timeout(_timeout);
    if (res.statusCode == 404) throw const BoltcardsExtensionDisabled();
    if (res.statusCode >= 400) {
      throw Exception('LNbits ${res.statusCode}: ${res.body}');
    }
    final body = jsonDecode(res.body);
    final List raw = body is List
        ? body
        : (body is Map && body['data'] is List ? body['data'] as List : const []);
    return raw
        .whereType<Map<String, dynamic>>()
        .map(BoltCard.fromJson)
        .toList();
  }

  /// Creates a Bolt Card on the server with freshly generated AES keys and
  /// returns the full record (including the keys, needed for programming).
  ///
  /// [uid] is the chip's 7-byte UID (hex); LNbits stores it so it can decrypt
  /// the `p` parameter on each scan. Throws [BoltcardsExtensionDisabled] on 404.
  Future<BoltCard> createCard({
    required String name,
    required String uid,
    required int txLimitSats,
    required int dailyLimitSats,
  }) async {
    final k0 = _randomKeyHex();
    final k1 = _randomKeyHex();
    final k2 = _randomKeyHex();
    final res = await _client
        .post(
          _uri('/boltcards/api/v1/cards'),
          headers: _headers(),
          body: jsonEncode({
            'card_name': name,
            'uid': uid.toUpperCase(),
            'counter': 0,
            'tx_limit': txLimitSats,
            'daily_limit': dailyLimitSats,
            'enable': true,
            'k0': k0,
            'k1': k1,
            'k2': k2,
            // On a new card the "previous" keys equal the current ones; this
            // matches what the LNbits frontend sends.
            'prev_k0': k0,
            'prev_k1': k1,
            'prev_k2': k2,
          }),
        )
        .timeout(_timeout);
    if (res.statusCode == 404) throw const BoltcardsExtensionDisabled();
    if (res.statusCode >= 400) {
      if (res.body.toLowerCase().contains('already registered')) {
        throw const BoltcardUidAlreadyRegistered();
      }
      throw Exception('LNbits ${res.statusCode}: ${res.body}');
    }
    return BoltCard.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// Updates an existing card. Any omitted field keeps the card's current
  /// value (the full record is re-sent to satisfy the extension's
  /// `CreateCardData` body). Returns the updated record.
  Future<BoltCard> updateCard(
    BoltCard card, {
    String? name,
    String? uid,
    int? txLimitSats,
    int? dailyLimitSats,
    bool? enabled,
    int? counter,
  }) async {
    final res = await _client
        .put(
          _uri('/boltcards/api/v1/cards/${card.id}'),
          headers: _headers(),
          body: jsonEncode({
            'card_name': name ?? card.name,
            'uid': (uid ?? card.uid).toUpperCase(),
            'counter': counter ?? card.counter,
            'tx_limit': txLimitSats ?? card.txLimitSats,
            'daily_limit': dailyLimitSats ?? card.dailyLimitSats,
            'enable': enabled ?? card.enabled,
            'k0': card.k0,
            'k1': card.k1,
            'k2': card.k2,
            'prev_k0': card.k0,
            'prev_k1': card.k1,
            'prev_k2': card.k2,
          }),
        )
        .timeout(_timeout);
    if (res.statusCode == 404) throw const BoltcardsExtensionDisabled();
    if (res.statusCode >= 400) {
      throw Exception('LNbits ${res.statusCode}: ${res.body}');
    }
    return BoltCard.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// Enables or disables a card. Returns the updated record.
  Future<BoltCard> setEnabled(String cardId, bool enabled) async {
    final res = await _client
        .get(
          _uri('/boltcards/api/v1/cards/enable/$cardId/${enabled ? 'true' : 'false'}'),
          headers: _headers(),
        )
        .timeout(_timeout);
    if (res.statusCode == 404) throw const BoltcardsExtensionDisabled();
    if (res.statusCode >= 400) {
      throw Exception('LNbits ${res.statusCode}: ${res.body}');
    }
    return BoltCard.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// Deletes a card from the server.
  Future<void> deleteCard(String cardId) async {
    final res = await _client
        .delete(_uri('/boltcards/api/v1/cards/$cardId'), headers: _headers())
        .timeout(_timeout);
    if (res.statusCode == 404) throw const BoltcardsExtensionDisabled();
    if (res.statusCode >= 400) {
      throw Exception('LNbits ${res.statusCode}: ${res.body}');
    }
  }

  static final Random _rng = Random.secure();

  /// 16 random bytes as a 32-char uppercase hex string (one AES-128 key).
  static String _randomKeyHex() {
    final b = List<int>.generate(16, (_) => _rng.nextInt(256));
    return b.map((x) => x.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
  }
}
