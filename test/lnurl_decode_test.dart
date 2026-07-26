import 'package:ember_spark/services/lnurl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('decodeLnurl', () {
    test('passes a plain https URL through unchanged (case preserved)', () {
      const url = 'https://lnbits.example.com/withdraw/api/v1/lnurl/AbC123?xy=Zz';
      expect(decodeLnurl(url), url);
    });

    test('passes an http URL through unchanged', () {
      const url = 'http://host.local/withdraw/api/v1/lnurl/x';
      expect(decodeLnurl(url), url);
    });

    test('strips a lightning: prefix before a URL', () {
      expect(
        decodeLnurl('lightning:https://host/lnurl/x'),
        'https://host/lnurl/x',
      );
    });

    test('maps an lnurlw:// LUD-17 scheme to https', () {
      expect(decodeLnurl('lnurlw://host/withdraw/x'), 'https://host/withdraw/x');
    });

    test('maps an lnurlw:// on a .onion host to http', () {
      expect(
        decodeLnurl('lnurlw://abcd.onion/withdraw/x'),
        'http://abcd.onion/withdraw/x',
      );
    });

    test('still decodes a bech32 LNURL to its URL (LUD-01 test vector)', () {
      const bech32 =
          'LNURL1DP68GURN8GHJ7UM9WFMXJCM99E3K7MF0V9CXJ0M385EKVCENXC6R2C35XVUKXEFCV5MKVV34X5EKZD3EV56NYD3HXQURZEPEXEJXXEPNXSCRVWFNV9NXZCN9XQ6XYEFHVGCXXCMYXYMNSERXFQ5FNS';
      expect(
        decodeLnurl(bech32),
        'https://service.com/api?q=3fc3645b439ce8e7f2553a69e5267081d96dcd340693afabe04be7b0ccd178df',
      );
    });
  });

  group('lightningParamOrSelf', () {
    test('extracts the lightning= payload from a web-fallback URL', () {
      const url =
          'https://lightning.finbil.de/?lightning=LNURL1DP68GURN8GHJ7MRFVA58G';
      expect(lightningParamOrSelf(url), 'LNURL1DP68GURN8GHJ7MRFVA58G');
    });

    test('extracts an lnurl= param too, case-insensitive key', () {
      const url = 'https://host/pay?LNURL=LNURL1ABC';
      expect(lightningParamOrSelf(url), 'LNURL1ABC');
    });

    test('returns a URL without a lightning/lnurl param unchanged', () {
      const url = 'https://host/withdraw/api/v1/lnurl/xyz';
      expect(lightningParamOrSelf(url), url);
    });

    test('returns a bare bech32 LNURL unchanged', () {
      const bech32 = 'LNURL1DP68GURN8GHJ7MRFVA58G';
      expect(lightningParamOrSelf(bech32), bech32);
    });

    test('leaves lnurlw:// and lightning addresses unchanged', () {
      expect(lightningParamOrSelf('lnurlw://host/x'), 'lnurlw://host/x');
      expect(lightningParamOrSelf('alice@example.com'), 'alice@example.com');
    });
  });
}
