import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';
import 'http_client_factory.dart';
import 'lnurl.dart';

const _seedStorageKey = 'lnurl_auth_seed_v1';

final ECDomainParameters _curve = ECDomainParameters('secp256k1');

/// Signs the LNURL-auth k1 challenge with this device's per-domain linking
/// key and submits the response. Throws on protocol or HTTP errors.
Future<void> performLnurlAuth(LnurlAuthInfo info) async {
  final seed = await _getOrCreateSeed();
  final priv = _deriveLinkingPrivKey(seed, info.host);
  final k1Bytes = _hexDecode(info.k1);
  final sigDer = _signLowS(priv, k1Bytes);
  final pub = _publicKeyCompressed(priv);

  final newUri = info.authUri.replace(queryParameters: {
    ...info.authUri.queryParameters,
    'sig': _hexEncode(sigDer),
    'key': _hexEncode(pub),
  });

  final client = await getHttpClient();
  final res = await client
      .get(newUri, headers: browserLikeHeaders)
      .timeout(const Duration(seconds: 30));
  if (res.statusCode != 200) {
    throw Exception('LNURL-auth failed (${res.statusCode}): ${res.body}');
  }
  final data = jsonDecode(res.body);
  if (data is Map && data['status'] == 'ERROR') {
    throw Exception('LNURL-auth error: ${data['reason']}');
  }
}

Future<Uint8List> _getOrCreateSeed() async {
  const storage = FlutterSecureStorage();
  final existing = await storage.read(key: _seedStorageKey);
  if (existing != null) return _hexDecode(existing);
  final r = Random.secure();
  final seed = Uint8List.fromList(
    List.generate(32, (_) => r.nextInt(256)),
  );
  await storage.write(key: _seedStorageKey, value: _hexEncode(seed));
  return seed;
}

/// Per-domain linking key. Simple HMAC-derived (not BIP-32-compatible),
/// deterministic for the same seed + host pair.
Uint8List _deriveLinkingPrivKey(Uint8List seed, String host) {
  final hmac = HMac(SHA256Digest(), 64)..init(KeyParameter(seed));
  final out = hmac.process(
    Uint8List.fromList(utf8.encode('lnurl-auth:${host.toLowerCase()}')),
  );
  var d = _bigIntFromBytes(out) % _curve.n;
  if (d == BigInt.zero) d = BigInt.one;
  return _bigIntToBytes(d, 32);
}

Uint8List _signLowS(Uint8List priv, Uint8List msg32) {
  final d = _bigIntFromBytes(priv);
  final signer = ECDSASigner(null, HMac(SHA256Digest(), 64))
    ..init(true, PrivateKeyParameter(ECPrivateKey(d, _curve)));
  final sig = signer.generateSignature(msg32) as ECSignature;
  final n = _curve.n;
  final halfN = n >> 1;
  var s = sig.s;
  if (s > halfN) s = n - s;
  return _derEncode(sig.r, s);
}

Uint8List _publicKeyCompressed(Uint8List priv) {
  final d = _bigIntFromBytes(priv);
  final q = (_curve.G * d)!;
  final x = q.x!.toBigInteger()!;
  final y = q.y!.toBigInteger()!;
  final prefix = y.isEven ? 0x02 : 0x03;
  return Uint8List.fromList([prefix, ..._bigIntToBytes(x, 32)]);
}

Uint8List _derEncode(BigInt r, BigInt s) {
  final rb = _bigIntToDerBytes(r);
  final sb = _bigIntToDerBytes(s);
  final total = 2 + rb.length + 2 + sb.length;
  return Uint8List.fromList([
    0x30,
    total,
    0x02,
    rb.length,
    ...rb,
    0x02,
    sb.length,
    ...sb,
  ]);
}

Uint8List _bigIntToDerBytes(BigInt v) {
  final out = <int>[];
  var n = v;
  while (n > BigInt.zero) {
    out.insert(0, (n & BigInt.from(0xff)).toInt());
    n >>= 8;
  }
  if (out.isEmpty) out.add(0);
  if ((out[0] & 0x80) != 0) out.insert(0, 0);
  return Uint8List.fromList(out);
}

Uint8List _bigIntToBytes(BigInt v, int length) {
  final bytes = Uint8List(length);
  var n = v;
  for (var i = length - 1; i >= 0 && n > BigInt.zero; i--) {
    bytes[i] = (n & BigInt.from(0xff)).toInt();
    n >>= 8;
  }
  return bytes;
}

BigInt _bigIntFromBytes(Uint8List bytes) {
  var result = BigInt.zero;
  for (final b in bytes) {
    result = (result << 8) | BigInt.from(b);
  }
  return result;
}

const _hexChars = '0123456789abcdef';

String _hexEncode(Uint8List bytes) {
  final sb = StringBuffer();
  for (final b in bytes) {
    sb.write(_hexChars[(b >> 4) & 0xf]);
    sb.write(_hexChars[b & 0xf]);
  }
  return sb.toString();
}

Uint8List _hexDecode(String s) {
  final clean = s.toLowerCase();
  if (clean.length.isOdd) throw const FormatException('Invalid hex length');
  final out = Uint8List(clean.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = (_hexNibble(clean.codeUnitAt(i * 2)) << 4) |
        _hexNibble(clean.codeUnitAt(i * 2 + 1));
  }
  return out;
}

int _hexNibble(int code) {
  if (code >= 0x30 && code <= 0x39) return code - 0x30;
  if (code >= 0x61 && code <= 0x66) return code - 0x57;
  throw FormatException('Invalid hex char: ${String.fromCharCode(code)}');
}
