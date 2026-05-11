import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

const _kTrustKey = 'trust_unverified_tls';

/// A current Chrome-on-Android UA — strict WAFs validate the
/// `AppleWebKit/.../KHTML, like Gecko Chrome/.../Mobile Safari/...` shape,
/// not just the "Mozilla/5.0" prefix.
const _userAgent =
    'Mozilla/5.0 (Linux; Android 14; Pixel 8) '
    'AppleWebKit/537.36 (KHTML, like Gecko) '
    'Chrome/134.0.0.0 Mobile Safari/537.36';

const browserLikeHeaders = <String, String>{
  'Accept': 'application/json, text/plain, */*',
  'Accept-Language': 'en-US,en;q=0.9',
};

/// Returns an HTTP client that:
///  - sets a non-default User-Agent (so plain openresty/cloudflare WAFs
///    don't 403 us as "bot traffic"),
///  - bypasses TLS validation when the user has opted in via Settings;
///    additionally uses an empty trust store and forces http/1.1 ALPN
///    in that mode, which fixes some servers where the system trust
///    store or h2 negotiation breaks the handshake before cert
///    validation is reached.
Future<http.Client> getHttpClient() async {
  final unverified = await isUnverifiedTlsAllowed();

  SecurityContext? ctx;
  if (unverified) {
    ctx = SecurityContext(withTrustedRoots: false);
    try {
      // Dart's HttpClient is HTTP/1.1 only; some servers reject the
      // default empty ALPN list with HANDSHAKE_FAILURE.
      ctx.setAlpnProtocols(<String>['http/1.1'], false);
    } catch (_) {
      // Older Dart versions or platforms where setAlpnProtocols throws —
      // safe to ignore; the rest of the relaxed config still applies.
    }
  }

  final inner = HttpClient(context: ctx)..userAgent = _userAgent;
  if (unverified) {
    inner.badCertificateCallback = (_, __, ___) => true;
  }
  return IOClient(inner);
}

Future<bool> isUnverifiedTlsAllowed() async {
  const storage = FlutterSecureStorage();
  return (await storage.read(key: _kTrustKey)) == '1';
}

Future<void> setUnverifiedTlsAllowed(bool allowed) async {
  const storage = FlutterSecureStorage();
  if (allowed) {
    await storage.write(key: _kTrustKey, value: '1');
  } else {
    await storage.delete(key: _kTrustKey);
  }
}
