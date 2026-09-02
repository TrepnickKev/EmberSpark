import 'package:flutter_test/flutter_test.dart';
import 'package:ember_spark/services/lnurl.dart';

void main() {
  group('parseLnurlResponse error detection', () {
    test('non-standard {"error":...} (satsback) throws already-used', () {
      expect(
        () => parseLnurlResponse({'error': 'LNURL Withdraw already used'}),
        throwsA(
          isA<LnurlServiceErrorException>()
              .having((e) => e.alreadyUsed, 'alreadyUsed', isTrue)
              .having((e) => e.reason, 'reason', 'LNURL Withdraw already used'),
        ),
      );
    });

    test('standard {"status":"ERROR","reason":...} throws service error', () {
      expect(
        () => parseLnurlResponse({'status': 'ERROR', 'reason': 'bad k1'}),
        throwsA(
          isA<LnurlServiceErrorException>()
              .having((e) => e.alreadyUsed, 'alreadyUsed', isFalse)
              .having((e) => e.reason, 'reason', 'bad k1'),
        ),
      );
    });

    test('lower/mixed-case status is still recognised as an error', () {
      expect(
        () => parseLnurlResponse({'status': 'Error', 'reason': 'nope'}),
        throwsA(isA<LnurlServiceErrorException>()),
      );
    });

    test('a valid withdrawRequest parses into LnurlWithdrawInfo', () {
      final info = parseLnurlResponse({
        'tag': 'withdrawRequest',
        'callback': 'https://host.tld/callback',
        'k1': 'deadbeef',
        'minWithdrawable': 1000,
        'maxWithdrawable': 2000,
        'defaultDescription': 'test',
      });
      expect(info, isA<LnurlWithdrawInfo>());
      final w = info as LnurlWithdrawInfo;
      expect(w.k1, 'deadbeef');
      expect(w.minWithdrawableMsat, 1000);
      expect(w.maxWithdrawableMsat, 2000);
    });

    test('an absent tag still throws the FormatException (not an error body)',
        () {
      expect(
        () => parseLnurlResponse({'foo': 'bar'}),
        throwsFormatException,
      );
    });
  });

  group('isAlreadyUsedReason', () {
    test('matches already-used / redeemed / spent phrasings', () {
      expect(isAlreadyUsedReason('LNURL Withdraw already used'), isTrue);
      expect(isAlreadyUsedReason('Voucher already redeemed'), isTrue);
      expect(isAlreadyUsedReason('This has been claimed'), isTrue);
      expect(isAlreadyUsedReason('Funds already spent'), isTrue);
    });

    test('does not match unrelated errors', () {
      expect(isAlreadyUsedReason('Invalid k1'), isFalse);
      expect(isAlreadyUsedReason('Internal server error'), isFalse);
    });
  });
}
