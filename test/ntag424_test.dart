import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ember_spark/services/ntag424.dart';

Uint8List hx(String s) {
  final clean = s.replaceAll(' ', '');
  final out = Uint8List(clean.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = int.parse(clean.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return out;
}

String hex(Uint8List b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

void main() {
  group('AES-CMAC (NIST SP 800-38B vectors)', () {
    final key = hx('2b7e1516 28aed2a6 abf71588 09cf4f3c');

    test('empty message', () {
      expect(hex(Ntag424.cmacForTest(key, Uint8List(0))),
          'bb1d6929e95937287fa37d129b756746');
    });

    test('16-byte message', () {
      final m = hx('6bc1bee2 2e409f96 e93d7e11 7393172a');
      expect(hex(Ntag424.cmacForTest(key, m)),
          '070a16b46b4d4144f79bdd9dd04a287c');
    });

    test('20-byte (non-block-aligned) message', () {
      // The command MAC input is not a multiple of 16 bytes, so verify CMAC on
      // a non-aligned input too (NIST SP 800-38B example, Mlen=160).
      final m = hx('6bc1bee2 2e409f96 e93d7e11 7393172a ae2d8a57');
      expect(hex(Ntag424.cmacForTest(key, m)),
          '7d85449ea6ea19c823a7bf78837dfade');
    });
  });

  group('EV2 session key derivation (AN12196 worked example)', () {
    // From the AuthenticateEV2First worked example.
    final key = hx('A4123456 789ABCEF A4123456 789ABCEF');
    final rndA = hx('ABD14E02 FCF35DE2 7803C856 6E376D81');
    final rndB = hx('9204E862 0EBD30DF 52E91E41 E9AC499E');

    test('derives the documented SesAuthMAC / SesAuthENC keys', () {
      final (mac, enc) = Ntag424.sessionKeysForTest(key, rndA, rndB);
      expect(hex(mac), '3890a8e11762d784715608e811b37a81');
      expect(hex(enc), '42b9997d6513a602e9ce2ddd1bfe042d');
    });
  });

  group('DESFire CRC32 (JAMCRC)', () {
    test('check value of "123456789" is 0x340BC6D9 (little-endian bytes)', () {
      final crc = Ntag424.crc32ForTest(
          Uint8List.fromList('123456789'.codeUnits));
      expect(hex(crc), 'd9c60b34');
    });
  });

  group('truncated MAC', () {
    test('keeps the 8 odd-indexed bytes', () {
      final full = hx('00112233 44556677 8899aabb ccddeeff');
      expect(hex(Ntag424.truncateMacForTest(full)), '11335577 99bbddff'.replaceAll(' ', ''));
    });
  });

  group('NDEF file + SDM offsets', () {
    test('builds a length-prefixed URI record and locates p=/c= values', () {
      const uri =
          'lnurlw://demo.host/boltcards/api/v1/scan/abc123'
          '?p=00000000000000000000000000000000&c=0000000000000000';
      final file = Ntag424.ndefFileForTest(uri);

      // 2-byte big-endian NLEN prefix, then 0xD1 0x01 PLEN 0x55 0x00 ...
      expect(file[0], 0x00);
      expect(file[2], 0xD1);
      expect(file[5], 0x55);
      expect(file[6], 0x00);

      final pOff = Ntag424.valueOffsetForTest(file, 'p=');
      final cOff = Ntag424.valueOffsetForTest(file, 'c=');
      // The p value is 32 hex chars; "&c=" (3 bytes) follows, so c starts 35
      // bytes after p.
      expect(cOff - pOff, 32 + 3);
      // The bytes at the located offsets are the zero placeholders.
      expect(String.fromCharCode(file[pOff]), '0');
      expect(String.fromCharCode(file[cOff]), '0');
    });
  });
}
