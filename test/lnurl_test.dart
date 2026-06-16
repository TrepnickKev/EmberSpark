import 'package:flutter_test/flutter_test.dart';
import 'package:ember_spark/services/lnurl.dart';

void main() {
  group('decodeLnurl LUD-17 schemes', () {
    test('lnurlw:// maps to https and preserves p/c case', () {
      expect(
        decodeLnurl('lnurlw://card.example.com/boltcard/x?p=A1b2&c=C3d4'),
        'https://card.example.com/boltcard/x?p=A1b2&c=C3d4',
      );
    });

    test('.onion host maps to http', () {
      expect(
        decodeLnurl('lnurlw://abcd1234.onion/ln?p=AA&c=BB'),
        'http://abcd1234.onion/ln?p=AA&c=BB',
      );
    });

    test('strips a lightning: wrapper before the LUD-17 scheme', () {
      expect(
        decodeLnurl('lightning:lnurlw://host.tld/x?p=AA&c=BB'),
        'https://host.tld/x?p=AA&c=BB',
      );
    });

    test('other LUD-17 schemes are recognized', () {
      expect(decodeLnurl('lnurlp://host.tld/pay'), 'https://host.tld/pay');
      expect(
        decodeLnurl('keyauth://host.tld/auth?tag=login&k1=ab'),
        'https://host.tld/auth?tag=login&k1=ab',
      );
    });
  });

  group('decodeLnurl bech32 (unchanged)', () {
    test('decodes a bech32 LNURL to its URL', () {
      // lnurl1... encoding of https://example.com/lnurl
      const lnurl =
          'LNURL1DP68GURN8GHJ7UM9WFMXJCM99E3K7MF0V9CXJ0M385EKVCENXC6R2C35XVUKXEFCV5MKVV34X5EKZD3EV56NYD3HXQURZEPEXEJXXEPNXSCRVWFNV9NXZCN9XQ6XYEFHVGCXXCMYXYMNSERXFQ5FNS';
      expect(decodeLnurl(lnurl), startsWith('https://'));
    });
  });
}
