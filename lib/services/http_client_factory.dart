import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'wallet_account_service.dart';

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
///  - bypasses TLS validation when the user has opted in via Settings, but
///    only for the user's LNbits servers: the saved connections plus
///    [server], the one being added. Every other host (LNURL and Lightning
///    address servers, mempool.space, GitHub) stays verified. For the
///    trusted hosts it also uses an empty trust store and forces http/1.1
///    ALPN, which fixes some servers where the system trust store or h2
///    negotiation breaks the handshake before cert validation is reached.
Future<http.Client> getHttpClient({String? server}) async {
  final verified = IOClient(HttpClient()..userAgent = _userAgent);
  if (!await isUnverifiedTlsAllowed()) return verified;

  final hosts = trustedTlsHosts(
    [for (final w in await listWallets()) w.url],
    server: server,
  );
  if (hosts.isEmpty) return verified;

  final ctx = SecurityContext(withTrustedRoots: false);
  try {
    // Dart's HttpClient is HTTP/1.1 only; some servers reject the
    // default empty ALPN list with HANDSHAKE_FAILURE.
    ctx.setAlpnProtocols(<String>['http/1.1'], false);
  } catch (_) {
    // Older Dart versions or platforms where setAlpnProtocols throws —
    // safe to ignore; the rest of the relaxed config still applies.
  }
  final relaxed = HttpClient(context: ctx)
    ..userAgent = _userAgent
    ..badCertificateCallback = (_, host, __) => hosts.contains(host);
  return _HostScopedClient(hosts, IOClient(relaxed), verified);
}

/// Lower-cased hosts of [urls] and [server] that "Allow unverified HTTPS"
/// applies to. Unparsable or host-less entries are skipped.
Set<String> trustedTlsHosts(Iterable<String> urls, {String? server}) => {
      for (final u in [...urls, if (server != null) server])
        if (Uri.tryParse(u.trim())?.host case final h? when h.isNotEmpty)
          h.toLowerCase(),
    };

/// Sends requests for [_hosts] through [_relaxed] and everything else
/// through [_verified].
class _HostScopedClient extends http.BaseClient {
  _HostScopedClient(this._hosts, this._relaxed, this._verified);

  final Set<String> _hosts;
  final http.Client _relaxed;
  final http.Client _verified;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      (_hosts.contains(request.url.host.toLowerCase()) ? _relaxed : _verified)
          .send(request);

  @override
  void close() {
    _relaxed.close();
    _verified.close();
  }
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
