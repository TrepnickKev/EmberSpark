import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ember_spark/services/lnurl_auth.dart';

String _hex(Uint8List b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

void main() {
  group('LNURL-auth linking key (derived from the wallet admin key)', () {
    const secret = 'a1b2c3d4e5f60718293a4b5c6d7e8f90';
    const other = '00112233445566778899aabbccddeeff';
    const host = 'login.example.com';

    test('same admin key + host is deterministic (survives reinstall/roams)', () {
      final a = _hex(lnurlAuthPubKeyForTest(secret, host));
      final b = _hex(lnurlAuthPubKeyForTest(secret, host));
      expect(a, b);
      // 33-byte compressed secp256k1 pubkey (0x02/0x03 prefix).
      expect(a.length, 66);
      expect(a.substring(0, 2), anyOf('02', '03'));
    });

    test('a different wallet gives a different identity', () {
      expect(
        _hex(lnurlAuthPubKeyForTest(secret, host)),
        isNot(_hex(lnurlAuthPubKeyForTest(other, host))),
      );
    });

    test('a different host gives a different key (anti-correlation)', () {
      expect(
        _hex(lnurlAuthPubKeyForTest(secret, host)),
        isNot(_hex(lnurlAuthPubKeyForTest(secret, 'other.example.org'))),
      );
    });
  });
}
