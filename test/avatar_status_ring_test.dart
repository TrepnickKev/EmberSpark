import 'package:ember_spark/widgets/avatar_status_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the State instances it was given, so the test can tell whether the
/// avatar under the ring was kept or rebuilt from scratch.
class _Probe extends StatefulWidget {
  const _Probe(this.seen);
  final List<State> seen;
  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    widget.seen.add(this);
  }

  @override
  Widget build(BuildContext context) => const SizedBox(width: 88, height: 88);
}

void main() {
  testWidgets(
    'avatar under the ring keeps its state across status changes',
    (tester) async {
      final seen = <State>[];
      final probe = _Probe(seen);
      Future<void> pump(ConnectionStatus s) => tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: AvatarStatusRing(status: s, tooltip: s.name, child: probe),
          ),
        ),
      );

      await pump(ConnectionStatus.connecting);
      expect(find.byIcon(Icons.airplanemode_active), findsNothing);

      await pump(ConnectionStatus.flightMode);
      expect(find.byIcon(Icons.airplanemode_active), findsOneWidget);

      await pump(ConnectionStatus.ok);
      expect(find.byIcon(Icons.airplanemode_active), findsNothing);

      await pump(ConnectionStatus.flightMode);
      await pump(ConnectionStatus.failed);

      // One State for the whole sequence: the child (e.g. the wallet carousel)
      // was never torn down and rebuilt, so it can't snap back to its first page.
      expect(seen, hasLength(1));
    },
  );
}
