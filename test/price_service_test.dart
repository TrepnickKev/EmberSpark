import 'package:flutter_test/flutter_test.dart';
import 'package:ember_spark/services/price_service.dart';

void main() {
  group('btcHistKey', () {
    test('same UTC calendar day maps to the same key', () {
      final a = DateTime.utc(2025, 3, 4, 1, 0);
      final b = DateTime.utc(2025, 3, 4, 23, 59);
      expect(btcHistKey('EUR', a), btcHistKey('EUR', b));
    });

    test('different days map to different keys', () {
      final a = DateTime.utc(2025, 3, 4, 12);
      final b = DateTime.utc(2025, 3, 5, 12);
      expect(btcHistKey('EUR', a), isNot(btcHistKey('EUR', b)));
    });

    test('currency is part of the key', () {
      final t = DateTime.utc(2025, 3, 4, 12);
      expect(btcHistKey('EUR', t), isNot(btcHistKey('USD', t)));
    });
  });
}
