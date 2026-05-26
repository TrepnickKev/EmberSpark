import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

/// The home-screen profile avatar, with a coin-flip success animation.
///
/// Listens to [trigger]. Each time its value changes, the avatar rotates
/// around the Y axis into a green checkmark, holds for ~1 second, then
/// flips back. Pure Flutter: an [AnimationController] drives a [Transform]
/// with a small perspective entry so the rotation reads as a coin flip
/// rather than a flat horizontal squish.
class FlippingAvatar extends StatefulWidget {
  const FlippingAvatar({
    super.key,
    required this.seed,
    required this.trigger,
    this.size = 88,
  });

  final String seed;
  final ValueListenable<int> trigger;
  final double size;

  @override
  State<FlippingAvatar> createState() => _FlippingAvatarState();
}

class _FlippingAvatarState extends State<FlippingAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    widget.trigger.addListener(_onTrigger);
  }

  @override
  void dispose() {
    widget.trigger.removeListener(_onTrigger);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTrigger() async {
    if (!mounted) return;
    await _controller.forward(from: 0);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final angle = _controller.value * math.pi;
        final showCheck = _controller.value > 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(angle),
          child: showCheck
              // The back face is mirrored by the parent rotation; flip it
              // back so the checkmark reads right-side-up.
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: _checkmark(),
                )
              : RandomAvatar(
                  widget.seed,
                  height: widget.size,
                  width: widget.size,
                ),
        );
      },
    );
  }

  Widget _checkmark() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green,
      ),
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: widget.size * 0.6,
      ),
    );
  }
}
