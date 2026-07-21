import 'package:flutter_test/flutter_test.dart';
import 'package:ember_spark/services/unseen_incoming_service.dart';

void main() {
  group('evaluateUnseen (payment-received badge decision)', () {
    test('first observation seeds the baseline and shows no badge', () {
      final r = evaluateUnseen(1000, null);
      expect(r.baseline, 1000);
      expect(r.unseen, isFalse);
    });

    test('balance above baseline shows the badge, baseline unchanged', () {
      final r = evaluateUnseen(1500, 1000);
      expect(r.baseline, 1000);
      expect(r.unseen, isTrue);
    });

    test('balance below baseline (a spend) lowers the mark, no badge', () {
      final r = evaluateUnseen(700, 1000);
      expect(r.baseline, 700);
      expect(r.unseen, isFalse);
    });

    test('balance equal to baseline shows no badge', () {
      final r = evaluateUnseen(1000, 1000);
      expect(r.baseline, 1000);
      expect(r.unseen, isFalse);
    });

    test('a spend then a receive still surfaces the badge', () {
      // Acknowledged at 1000, spent down to 700 (baseline follows to 700),
      // then received 200 -> 900, which is above the lowered baseline.
      final afterSpend = evaluateUnseen(700, 1000);
      final afterReceive = evaluateUnseen(900, afterSpend.baseline);
      expect(afterReceive.unseen, isTrue);
    });
  });
}
