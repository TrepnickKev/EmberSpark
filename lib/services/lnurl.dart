import 'dart:convert';
import 'package:bech32/bech32.dart';
import 'bech32_util.dart';
import 'http_client_factory.dart';

/// Decodes a `lnurl1...` (or `LIGHTNING:LNURL1...`) string into its URL.
String decodeLnurl(String input) {
  var s = input.trim().replaceFirst(
    RegExp(r'^(lightning|lnurl):', caseSensitive: false),
    '',
  );
  s = s.toLowerCase();
  if (!s.startsWith('lnurl')) {
    throw const FormatException('Not an LNURL bech32 string');
  }
  final decoded = const Bech32Codec().decode(s, 2048);
  if (decoded.hrp != 'lnurl') {
    throw FormatException('Wrong HRP: ${decoded.hrp}');
  }
  final bytes = convertBits(decoded.data, 5, 8, false);
  return utf8.decode(bytes);
}

/// Converts a Lightning address (`user@host`) to its LNURL-pay URL.
String lightningAddressToUrl(String address) {
  final parts = address.trim().split('@');
  if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
    throw FormatException('Invalid Lightning address: $address');
  }
  final scheme = parts[1].toLowerCase().endsWith('.onion') ? 'http' : 'https';
  return '$scheme://${parts[1]}/.well-known/lnurlp/${parts[0]}';
}

sealed class LnurlInfo {
  const LnurlInfo();
}

class LnurlPayInfo extends LnurlInfo {
  final String callback;
  final int minSendableMsat;
  final int maxSendableMsat;
  final String description;

  /// LUD-12: maximum length of a sender comment. 0 means the endpoint does
  /// not accept comments (and the wallet should not show the field).
  final int commentAllowed;

  const LnurlPayInfo({
    required this.callback,
    required this.minSendableMsat,
    required this.maxSendableMsat,
    required this.description,
    this.commentAllowed = 0,
  });
}

class LnurlWithdrawInfo extends LnurlInfo {
  final String callback;
  final String k1;
  final int minWithdrawableMsat;
  final int maxWithdrawableMsat;
  final String description;

  const LnurlWithdrawInfo({
    required this.callback,
    required this.k1,
    required this.minWithdrawableMsat,
    required this.maxWithdrawableMsat,
    required this.description,
  });
}

class LnurlAuthInfo extends LnurlInfo {
  final String host;
  final String action;
  final String k1;
  final Uri authUri;

  const LnurlAuthInfo({
    required this.host,
    required this.action,
    required this.k1,
    required this.authUri,
  });
}

/// Detects an LNURL-auth (LUD-04) URL by its query params. Returns null if
/// the URL is some other LNURL flow.
LnurlAuthInfo? tryParseLnurlAuth(String url) {
  final uri = Uri.parse(url);
  if (uri.queryParameters['tag'] != 'login') return null;
  final k1 = uri.queryParameters['k1'];
  if (k1 == null || k1.isEmpty) return null;
  return LnurlAuthInfo(
    host: uri.host,
    action: uri.queryParameters['action'] ?? 'login',
    k1: k1,
    authUri: uri,
  );
}

/// Fetches an LNURL endpoint and parses the response into [LnurlInfo].
/// Throws [FormatException] for unknown tags or malformed responses.
Future<LnurlInfo> fetchLnurl(String url) async {
  final client = await getHttpClient();
  final res = await client
      .get(Uri.parse(url), headers: browserLikeHeaders)
      .timeout(const Duration(seconds: 30));
  if (res.statusCode != 200) {
    throw Exception('LNURL fetch failed (${res.statusCode}): ${res.body}');
  }
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  if (data['status'] == 'ERROR') {
    throw Exception('LNURL error: ${data['reason']}');
  }
  final tag = data['tag'] as String?;
  switch (tag) {
    case 'payRequest':
      return LnurlPayInfo(
        callback: data['callback'] as String,
        minSendableMsat: (data['minSendable'] as num).toInt(),
        maxSendableMsat: (data['maxSendable'] as num).toInt(),
        description: _extractPayDescription(data['metadata'] as String?),
        commentAllowed: (data['commentAllowed'] as num?)?.toInt() ?? 0,
      );
    case 'withdrawRequest':
      return LnurlWithdrawInfo(
        callback: data['callback'] as String,
        k1: data['k1'] as String,
        minWithdrawableMsat: (data['minWithdrawable'] as num).toInt(),
        maxWithdrawableMsat: (data['maxWithdrawable'] as num).toInt(),
        description: (data['defaultDescription'] as String?) ?? '',
      );
    default:
      throw FormatException('Unsupported LNURL tag: $tag');
  }
}

/// Asks the LNURL-pay endpoint for a BOLT11 invoice for [amountMsat].
/// Optionally attaches a LUD-12 [comment] (must fit `info.commentAllowed`).
Future<String> requestPayInvoice(
  LnurlPayInfo info,
  int amountMsat, {
  String? comment,
}) async {
  final sep = info.callback.contains('?') ? '&' : '?';
  var url = '${info.callback}${sep}amount=$amountMsat';
  if (comment != null && comment.isNotEmpty) {
    url += '&comment=${Uri.encodeQueryComponent(comment)}';
  }
  final client = await getHttpClient();
  final res = await client
      .get(Uri.parse(url), headers: browserLikeHeaders)
      .timeout(const Duration(seconds: 30));
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode != 200 || data['status'] == 'ERROR') {
    throw Exception('LNURL-pay error: ${data['reason'] ?? res.body}');
  }
  return data['pr'] as String;
}

/// Submits a BOLT11 invoice to the LNURL-withdraw callback.
Future<void> submitWithdrawInvoice(
  LnurlWithdrawInfo info,
  String bolt11,
) async {
  final sep = info.callback.contains('?') ? '&' : '?';
  final url = '${info.callback}${sep}k1=${info.k1}&pr=$bolt11';
  final client = await getHttpClient();
  final res = await client
      .get(Uri.parse(url), headers: browserLikeHeaders)
      .timeout(const Duration(seconds: 30));
  if (res.statusCode != 200) {
    throw Exception('LNURL-withdraw failed (${res.statusCode}): ${res.body}');
  }
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  if (data['status'] == 'ERROR') {
    throw Exception('LNURL-withdraw error: ${data['reason']}');
  }
}

/// Pulls a human-readable description out of the LNURL-pay `metadata` field,
/// which is itself a JSON-encoded array of [type, content] pairs.
String _extractPayDescription(String? metadata) {
  if (metadata == null) return '';
  try {
    final list = jsonDecode(metadata) as List;
    for (final entry in list) {
      if (entry is List && entry.length >= 2 && entry[0] == 'text/plain') {
        return entry[1] as String;
      }
    }
  } catch (_) {}
  return '';
}

