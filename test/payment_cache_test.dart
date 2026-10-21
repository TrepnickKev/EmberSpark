import 'package:ember_spark/services/lnbits_service.dart';
import 'package:ember_spark/services/payment_cache.dart';
import 'package:ember_spark/services/wallet_account_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final incoming = Payment(
    amountSats: 2100,
    feeSats: 0,
    memo: 'Coffee',
    comment: 'thanks!',
    bolt11: 'lnbc21u1pexample',
    time: DateTime.utc(2026, 10, 3, 14, 5, 9).toLocal(),
    pending: false,
    paymentHash: 'aa11',
  );
  final outgoing = Payment(
    amountSats: -500,
    feeSats: 3,
    memo: '',
    time: DateTime.utc(2026, 10, 4, 8).toLocal(),
    pending: true,
    paymentHash: 'bb22',
  );

  void expectSame(Payment a, Payment b) {
    expect(a.amountSats, b.amountSats);
    expect(a.feeSats, b.feeSats);
    expect(a.memo, b.memo);
    expect(a.comment, b.comment);
    expect(a.bolt11, b.bolt11);
    expect(a.time, b.time);
    expect(a.pending, b.pending);
    expect(a.paymentHash, b.paymentHash);
  }

  group('Payment.toCacheJson', () {
    test('round-trips through Payment.fromJson (incoming and outgoing)', () {
      expectSame(Payment.fromJson(incoming.toCacheJson()), incoming);
      expectSame(Payment.fromJson(outgoing.toCacheJson()), outgoing);
    });
  });

  group('payment cache', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    test('save then load returns the same list and when it was saved', () async {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      await saveCachedPayments('w1', [incoming, outgoing]);
      final cached = await loadCachedPayments('w1');
      expect(cached, isNotNull);
      expect(cached!.payments, hasLength(2));
      expectSame(cached.payments[0], incoming);
      expectSame(cached.payments[1], outgoing);
      expect(cached.savedAt.isAfter(before), isTrue);
    });

    test('is kept per wallet', () async {
      await saveCachedPayments('w1', [incoming]);
      expect(await loadCachedPayments('w2'), isNull);
      expect((await loadCachedPayments('w1'))!.payments, hasLength(1));
    });

    test('missing or corrupt data gives null instead of throwing', () async {
      expect(await loadCachedPayments('none'), isNull);
      FlutterSecureStorage.setMockInitialValues({
        paymentsCacheKey('w1'): '{not json',
      });
      expect(await loadCachedPayments('w1'), isNull);
    });
  });
}
