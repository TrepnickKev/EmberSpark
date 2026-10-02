import 'package:flutter/material.dart';

import 'stacked_action_button.dart' show bitcoinOrange;

/// Server-connection health shown as the colour of the ring around the avatar.
enum ConnectionStatus {
  /// A load / refresh is in flight (orange).
  connecting,

  /// The last probe reached the server (green).
  ok,

  /// The last probe failed - server unreachable or errored (red).
  failed,
}

/// A gently pulsing coloured glow ring drawn around [child] (the Home avatar),
/// signalling the current [ConnectionStatus]: green when connected, orange while
/// connecting, red when no connection could be made. The glow lives on an outer
/// wrapper so it is never clipped by the avatar's circle or the carousel.
class AvatarStatusRing extends StatefulWidget {
  const AvatarStatusRing({
    super.key,
    required this.status,
    required this.child,
    this.tooltip,
  });

  final ConnectionStatus status;
  final Widget child;
  final String? tooltip;

  @override
  State<AvatarStatusRing> createState() => _AvatarStatusRingState();
}

class _AvatarStatusRingState extends State<AvatarStatusRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Color get _color => switch (widget.status) {
    ConnectionStatus.ok => const Color(0xFF2ECC71),
    ConnectionStatus.connecting => bitcoinOrange,
    ConnectionStatus.failed => Colors.redAccent,
  };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final ring = AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final t = _pulse.value;
        // No padding: the ring sits flush against the avatar (Container still
        // insets the child by the border width, so the ring never covers it).
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35 + 0.35 * t),
                blurRadius: 10 + 8 * t,
                spreadRadius: 1 + 2 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
    if (widget.tooltip == null) return ring;
    return Tooltip(message: widget.tooltip!, child: ring);
  }
}
