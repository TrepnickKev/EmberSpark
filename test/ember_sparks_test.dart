import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ember_spark/widgets/ember_sparks.dart';

void main() {
  Widget host(ValueNotifier<int> trigger, {bool disableAnimations = false}) =>
      MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: EmberSparks(trigger: trigger),
        ),
      );

  testWidgets('stays idle until triggered', (tester) async {
    final trigger = ValueNotifier<int>(0);
    await tester.pumpWidget(host(trigger));
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('a trigger plays one burst that then stops', (tester) async {
    final trigger = ValueNotifier<int>(0);
    await tester.pumpWidget(host(trigger));
    trigger.value++;
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pump(EmberSparks.burstDuration);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('reduced animations skip the burst', (tester) async {
    final trigger = ValueNotifier<int>(0);
    await tester.pumpWidget(host(trigger, disableAnimations: true));
    trigger.value++;
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
