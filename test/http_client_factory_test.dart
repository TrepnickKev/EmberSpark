import 'package:flutter_test/flutter_test.dart';
import 'package:ember_spark/services/http_client_factory.dart';

void main() {
  group('trustedTlsHosts', () {
    test('includes the hosts of saved connections and the server being added',
        () {
      final hosts = trustedTlsHosts(
        ['https://LNbits.Home.lan:5001', 'https://abc.onion/'],
        server: 'https://new.example.org/wallet',
      );
      expect(hosts, {'lnbits.home.lan', 'abc.onion', 'new.example.org'});
    });

    test('leaves other hosts out', () {
      final hosts = trustedTlsHosts(['https://lnbits.home.lan']);
      expect(hosts.contains('mempool.space'), isFalse);
      expect(hosts.contains('wrong.example'), isFalse);
    });

    test('skips empty and unparsable entries', () {
      expect(trustedTlsHosts(['', 'not a url', '::'], server: ''), isEmpty);
    });
  });
}
