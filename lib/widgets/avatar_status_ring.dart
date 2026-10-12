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

  /// The last probe failed while the device is in flight mode (calm blue-grey
  /// with an airplane badge): the phone is offline on purpose, not the server.
  flightMode,
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
    ConnectionStatus.flightMode => Colors.blueGrey.shade300,
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
    // Always the same Stack with the ring first, in every state: the badge is
    // only added or removed after it. Swapping between a bare ring and a Stack
    // would make Flutter rebuild the whole avatar subtree on each status change,
    // resetting the wallet carousel (it snapped back to its initial page).
    final decorated = Stack(
      clipBehavior: Clip.none,
      children: [
        ring,
        // In flight mode, a small airplane badge on the ring's lower right.
        if (widget.status == ConnectionStatus.flightMode)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.airplanemode_active,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
    if (widget.tooltip == null) return decorated;
    return Tooltip(message: widget.tooltip!, child: decorated);
  }
}
