import 'package:flutter_test/flutter_test.dart';
import 'package:ember_spark/services/lnbits_service.dart';
import 'package:ember_spark/services/payment_search.dart';

Payment _p({
  int amountSats = 1000,
  String memo = '',
  String comment = '',
  String bolt11 = '',
  String paymentHash = '',
}) =>
    Payment(
      amountSats: amountSats,
      feeSats: 0,
      memo: memo,
      comment: comment,
      bolt11: bolt11,
      time: DateTime(2026, 1, 1),
      pending: false,
      paymentHash: paymentHash,
    );

void main() {
  group('paymentMatchesQuery', () {
    test('empty query matches everything', () {
      expect(paymentMatchesQuery(_p(memo: 'coffee'), ''), isTrue);
      expect(paymentMatchesQuery(_p(memo: 'coffee'), '   '), isTrue);
    });

    test('matches memo, case-insensitive', () {
      final p = _p(memo: 'Coffee at Cafe');
      expect(paymentMatchesQuery(p, 'coffee'), isTrue);
      expect(paymentMatchesQuery(p, 'CAFE'), isTrue);
      expect(paymentMatchesQuery(p, 'tea'), isFalse);
    });

    test('matches comment', () {
      expect(paymentMatchesQuery(_p(comment: 'thanks!'), 'thanks'), isTrue);
    });

    test('matches payment hash and invoice substrings', () {
      final p = _p(paymentHash: 'abc123def', bolt11: 'lnbc10u1pxyz');
      expect(paymentMatchesQuery(p, '123def'), isTrue);
      expect(paymentMatchesQuery(p, 'LNBC10U'), isTrue);
    });

    test('matches amount in sats, ignoring separators', () {
      final p = _p(amountSats: 1000, memo: '');
      expect(paymentMatchesQuery(p, '1000'), isTrue);
      expect(paymentMatchesQuery(p, '1,000'), isTrue);
      expect(paymentMatchesQuery(p, '1 000'), isTrue);
      expect(paymentMatchesQuery(p, '999'), isFalse);
    });

    test('matches the absolute amount for outgoing (negative) payments', () {
      expect(paymentMatchesQuery(_p(amountSats: -2500), '2500'), isTrue);
    });

    test('non-matching query returns false', () {
      expect(
        paymentMatchesQuery(_p(memo: 'coffee', amountSats: 1000), 'zzz'),
        isFalse,
      );
    });
  });
}
