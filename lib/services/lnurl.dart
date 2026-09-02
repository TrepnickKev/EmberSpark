import 'dart:convert';
import 'package:bech32/bech32.dart';
import 'bech32_util.dart';
import 'http_client_factory.dart';
import 'wallet_backend.dart';

/// Decodes a `lnurl1...` (or `LIGHTNING:LNURL1...`) string into its URL.
String decodeLnurl(String input) {
  var s = input.trim().replaceFirst(
    RegExp(r'^(lightning|lnurl):', caseSensitive: false),
    '',
  );

  // LUD-17: scheme-prefixed URLs (lnurlw:// for Bolt Cards, plus lnurlp /
  // lnurlc / keyauth). Map the scheme to https, or http for .onion hosts,
  // and return the URL directly. Path/query case is preserved because a
  // Bolt Card's p/c parameters can be case-sensitive.
  final lud17 = RegExp(
    r'^(lnurlw|lnurlp|lnurlc|keyauth)://(.+)$',
    caseSensitive: false,
  ).firstMatch(s);
  if (lud17 != null) {
    final rest = lud17.group(2)!;
    final host = Uri.parse('https://$rest').host.toLowerCase();
    final scheme = host.endsWith('.onion') ? 'http' : 'https';
    return '$scheme://$rest';
  }

  // A plain http(s) URL (some LNURL providers, e.g. LNbits reusable withdraw
  // QRs, encode the endpoint URL directly). Return it unchanged so the caller
  // can fetch it; case is preserved because the path/query may be significant.
  if (RegExp(r'^https?://', caseSensitive: false).hasMatch(s)) {
    return s;
  }

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

/// If [code] is an http(s) URL that carries a `lightning=` (or `lnurl=`) query
/// parameter — the standard QR web-fallback form, e.g.
/// `https://host/?lightning=LNURL1...` — return that parameter's value;
/// otherwise return [code] unchanged. Lets a QR that doubles as a web link
/// still yield its Lightning payload instead of fetching the web page.
String lightningParamOrSelf(String code) {
  final trimmed = code.trim();
  final uri = Uri.tryParse(trimmed);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    for (final entry in uri.queryParameters.entries) {
      final key = entry.key.toLowerCase();
      if ((key == 'lightning' || key == 'lnurl') && entry.value.isNotEmpty) {
        return entry.value.trim();
      }
    }
  }
  return trimmed;
}

/// Thrown by [fetchLnurl] when the endpoint's response is not LNURL JSON (e.g.
/// a scanned link that is actually a web page returning HTML).
class NotAnLnurlServiceException implements Exception {
  const NotAnLnurlServiceException();
  @override
  String toString() => 'Not an LNURL service';
}

/// Returns a canonical form of an LNURL string: decodes it, collapses any
/// accidental duplicate slashes in the URL path (some LNbits setups emit
/// `…/lnurlp//<id>`), and re-encodes. Returns the input unchanged if it is
/// not a decodable LNURL or needs no fix, so it can never break a working
/// value.
String canonicalizeLnurl(String lnurl) {
  try {
    final url = decodeLnurl(lnurl);
    final uri = Uri.parse(url);
    final fixedPath = uri.path.replaceAll(RegExp(r'/{2,}'), '/');
    if (fixedPath == uri.path) return lnurl; // nothing to fix
    final fixedUrl = uri.replace(path: fixedPath).toString();
    final data5 = convertBits(utf8.encode(fixedUrl), 8, 5, true);
    final encoded = const Bech32Codec().encode(Bech32('lnurl', data5), 2048);
    // Preserve the input's casing (LNURLs are conventionally uppercase).
    final bare = lnurl.trim().replaceFirst(
      RegExp(r'^(lightning|lnurl):', caseSensitive: false),
      '',
    );
    return bare == bare.toUpperCase() ? encoded.toUpperCase() : encoded;
  } catch (_) {
    return lnurl; // safety: never break a value we can't parse
  }
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
  // A non-JSON / non-object body means this wasn't an LNURL endpoint at all
  // (e.g. a scanned link that is really a web page returning HTML).
  final Map<String, dynamic> data;
  try {
    data = jsonDecode(res.body) as Map<String, dynamic>;
  } catch (_) {
    throw const NotAnLnurlServiceException();
  }
  return parseLnurlResponse(data);
}

/// Parses an already-decoded LNURL JSON body into [LnurlInfo]. Pure (no I/O) so
/// it is unit-testable. Throws [LnurlServiceErrorException] when the body is a
/// service error (either shape, see [lnurlErrorReason]) and [FormatException]
/// for an unknown/absent tag.
LnurlInfo parseLnurlResponse(Map<String, dynamic> data) {
  final reason = lnurlErrorReason(data);
  if (reason != null) {
    throw LnurlServiceErrorException(
      reason,
      alreadyUsed: isAlreadyUsedReason(reason),
    );
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

/// Detects an LNURL error body in either the LUD-06 standard
/// `{"status":"ERROR","reason":...}` shape or the non-standard `{"error":...}`
/// shape some services use (e.g. satsback.com). Returns the human-readable
/// reason, or null when the body is not an error.
String? lnurlErrorReason(Map<String, dynamic> data) {
  final isStatusError = (data['status'] as String?)?.toUpperCase() == 'ERROR';
  final err = data['error'];
  if (isStatusError || err != null) {
    final reason = data['reason'] ?? err;
    return reason is String ? reason : (reason?.toString() ?? '');
  }
  return null;
}

/// True when [reason] indicates a withdraw voucher that has already been
/// redeemed / spent (so there is nothing left to claim).
bool isAlreadyUsedReason(String reason) {
  final r = reason.toLowerCase();
  return r.contains('already') ||
      r.contains('used') ||
      r.contains('redeem') ||
      r.contains('claim') ||
      r.contains('spent');
}

/// Thrown when an LNURL endpoint returns a service error (e.g. an already-used
/// withdraw voucher). [reason] is the server's message; [alreadyUsed] flags the
/// "voucher already redeemed" case so callers can show a friendlier state.
class LnurlServiceErrorException implements Exception {
  const LnurlServiceErrorException(this.reason, {this.alreadyUsed = false});
  final String reason;
  final bool alreadyUsed;
  @override
  String toString() => 'LnurlServiceErrorException: $reason';
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
  final reason = lnurlErrorReason(data);
  if (res.statusCode != 200 || reason != null) {
    throw Exception('LNURL-pay error: ${reason ?? res.body}');
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
  final reason = lnurlErrorReason(data);
  if (reason != null) {
    throw LnurlServiceErrorException(
      reason,
      alreadyUsed: isAlreadyUsedReason(reason),
    );
  }
}

/// Thrown by [chargeViaLnurlWithdraw] when the requested amount is outside the
/// withdraw service's advertised min/max (both in sats). Callers map it to a
/// friendly, localized range message.
class LnurlWithdrawRangeError implements Exception {
  const LnurlWithdrawRangeError(this.minSats, this.maxSats);
  final int minSats;
  final int maxSats;
  @override
  String toString() => 'Amount out of range ($minSats–$maxSats sats)';
}

/// Charges a Bolt Card / LNURL-withdraw source for [sats]: resolves [code]
/// (an `lnurlw://…` or bech32 LNURL), validates the amount against the
/// service's min/max, mints an invoice on the current wallet and submits it to
/// the withdraw callback — so the funds land in the current wallet. This is the
/// point-of-sale "charge the card" flow. Throws [LnurlWithdrawRangeError] for
/// an out-of-range amount, [FormatException] if [code] is not a withdraw
/// source, or any network/LNURL error.
Future<void> chargeViaLnurlWithdraw(
  String code,
  int sats, {
  String? memo,
  String? existingBolt11,
}) async {
  final url = code.contains('@')
      ? lightningAddressToUrl(code)
      : decodeLnurl(code);
  final info = await fetchLnurl(url);
  if (info is! LnurlWithdrawInfo) {
    throw const FormatException('Not an LNURL-withdraw source');
  }
  final msat = sats * 1000;
  if (sats <= 0 ||
      msat < info.minWithdrawableMsat ||
      msat > info.maxWithdrawableMsat) {
    throw LnurlWithdrawRangeError(
      info.minWithdrawableMsat ~/ 1000,
      info.maxWithdrawableMsat ~/ 1000,
    );
  }
  // Reuse the invoice the caller already created (e.g. the one shown as the
  // Receive QR) so the card pays that one instead of orphaning it and minting
  // a second. Only create a fresh invoice when none was supplied.
  final String bolt11;
  if (existingBolt11 != null && existingBolt11.trim().isNotEmpty) {
    bolt11 = existingBolt11.trim();
  } else {
    final svc = await loadWalletBackend();
    final resolvedMemo = (memo != null && memo.trim().isNotEmpty)
        ? memo.trim()
        : (info.description.isNotEmpty ? info.description : 'EmberSpark');
    bolt11 = await svc.createInvoice(amountSats: sats, memo: resolvedMemo);
  }
  await submitWithdrawInvoice(info, bolt11);
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

