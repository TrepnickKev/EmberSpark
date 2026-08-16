import 'package:flutter_test/flutter_test.dart';
import 'package:ember_spark/services/received_notify_service.dart';

void main() {
  group('evaluateNotify (background received-payment decision)', () {
    test('first observation seeds the baseline and does not notify', () {
      final r = evaluateNotify(1000, null);
      expect(r.baseline, 1000);
      expect(r.notify, isFalse);
    });

    test('an increase notifies and advances the baseline to the new balance', () {
      final r = evaluateNotify(1500, 1000);
      expect(r.notify, isTrue);
      expect(r.baseline, 1500); // advanced, so the same receive is not re-notified
    });

    test('re-checking the same balance after an increase does not notify again', () {
      final first = evaluateNotify(1500, 1000);
      final second = evaluateNotify(1500, first.baseline);
      expect(second.notify, isFalse);
      expect(second.baseline, 1500);
    });

    test('a spend ratchets the baseline down without notifying', () {
      final r = evaluateNotify(600, 1000);
      expect(r.notify, isFalse);
      expect(r.baseline, 600);
    });

    test('unchanged balance does not notify and keeps the baseline', () {
      final r = evaluateNotify(1000, 1000);
      expect(r.notify, isFalse);
      expect(r.baseline, 1000);
    });

    test('a receive after a spend notifies again', () {
      final spent = evaluateNotify(600, 1000); // baseline 600, no notify
      final received = evaluateNotify(900, spent.baseline);
      expect(received.notify, isTrue);
      expect(received.baseline, 900);
    });
  });
}
