import 'package:flutter/widgets.dart';

import 'palette.dart';
import 'seeded_random.dart';

/// A deliberately plain "no art yet" placeholder: a seed-colored disc with a
/// centered ₿. Used only until illustrated assets are bundled (see
/// ASSET_SPEC.md), so an avatar is never blank during bring-up.
class FallbackAvatarPainter extends CustomPainter {
  FallbackAvatarPainter(this.seed);

  final String seed;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final rng = SeededRandom(seed);
    final palette = kPalettes[rng.nextInt(kPalettes.length)];

    final rect = Rect.fromLTWH(0, 0, s, s);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.3),
          radius: 1.1,
          colors: [palette.backgroundTop, palette.backgroundBottom],
        ).createShader(rect),
    );

    final tp = TextPainter(
      text: TextSpan(
        text: '₿',
        style: TextStyle(
          color: palette.accent,
          fontSize: 0.5 * s,
          fontWeight: FontWeight.w800,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((s - tp.width) / 2, (s - tp.height) / 2));
  }

  @override
  bool shouldRepaint(covariant FallbackAvatarPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
