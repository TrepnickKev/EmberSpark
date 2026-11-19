import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Campfire ember sparks drifting up from the bottom of the screen, played once
/// per bump of [trigger] (Home bumps it when a payment was received). The
/// ticker only runs during a burst, so the widget costs nothing while idle. It
/// never takes taps and is skipped when the system asks for reduced animations.
class EmberSparks extends StatefulWidget {
  const EmberSparks({super.key, required this.trigger});

  final ValueListenable<int> trigger;

  /// How long one burst lasts, from the first spark to the last one fading.
  static const burstDuration = Duration(seconds: 7);

  @override
  State<EmberSparks> createState() => _EmberSparksState();
}

class _EmberSparksState extends State<EmberSparks>
    with SingleTickerProviderStateMixin {
  static const _sparkCount = 150;

  late final Ticker _ticker;
  final _random = Random();
  // Seconds since the burst started.
  final _elapsed = ValueNotifier<double>(0);
  List<_Spark> _sparks = const [];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    widget.trigger.addListener(_start);
  }

  @override
  void didUpdateWidget(EmberSparks old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger) {
      old.trigger.removeListener(_start);
      widget.trigger.addListener(_start);
    }
  }

  @override
  void dispose() {
    widget.trigger.removeListener(_start);
    _ticker.dispose();
    _elapsed.dispose();
    super.dispose();
  }

  void _start() {
    if (!mounted || MediaQuery.disableAnimationsOf(context)) return;
    _sparks = List.generate(_sparkCount, (_) => _Spark.random(_random));
    _elapsed.value = 0;
    if (_ticker.isActive) _ticker.stop();
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    if (elapsed >= EmberSparks.burstDuration) {
      _ticker.stop();
      _sparks = const [];
      _elapsed.value = 0;
      return;
    }
    _elapsed.value = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _EmberPainter(_elapsed, () => _sparks, dark: dark),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// One ember, with everything random fixed at the start of the burst. Times
/// are in seconds; positions and distances are fractions of the widget size.
class _Spark {
  const _Spark({
    required this.start,
    required this.life,
    required this.x,
    required this.height,
    required this.lean,
    required this.swayA,
    required this.swayB,
    required this.freqA,
    required this.freqB,
    required this.phaseA,
    required this.phaseB,
    required this.flickerA,
    required this.flickerB,
    required this.flareFreq,
    required this.radius,
    required this.kick,
    required this.fan,
  });

  factory _Spark.random(Random r) {
    // Three uniforms summed: a bell around the centre, like a fire's core.
    final spread = (r.nextDouble() + r.nextDouble() + r.nextDouble()) / 3;
    // Most embers burst out at once, like a log dropped into the fire, and
    // fan outwards from the middle; the rest keep trickling up afterwards.
    final burst = r.nextDouble() < 0.75;
    return _Spark(
      start: burst ? pow(r.nextDouble(), 2) * 0.6 : 0.6 + r.nextDouble() * 1.9,
      life: 3 + r.nextDouble() * (burst ? 2 : 1.5),
      x: burst ? 0.3 + spread * 0.4 : 0.075 + spread * 0.85,
      // Most fade between 65% and 90% up, a few reach the top.
      height: r.nextDouble() < 0.15
          ? 0.9 + r.nextDouble() * 0.1
          : 0.65 + r.nextDouble() * 0.25,
      lean: (r.nextDouble() - 0.5) * 0.12,
      swayA: 0.022 + r.nextDouble() * 0.045,
      swayB: 0.008 + r.nextDouble() * 0.022,
      freqA: 0.8 + r.nextDouble() * 1.2,
      freqB: 2.5 + r.nextDouble() * 3,
      phaseA: r.nextDouble() * 2 * pi,
      phaseB: r.nextDouble() * 2 * pi,
      flickerA: 9 + r.nextDouble() * 8,
      flickerB: 23 + r.nextDouble() * 15,
      flareFreq: 1.5 + r.nextDouble() * 2,
      // Cubed, so most embers are tiny and only a few are big.
      radius: 1.2 + pow(r.nextDouble(), 3) * 3.6,
      kick: burst,
      fan: burst ? (spread - 0.5) * 0.7 + (r.nextDouble() - 0.5) * 0.2 : 0,
    );
  }

  final double start;
  final double life;
  final double x;
  final double height;
  final double lean;
  final double swayA;
  final double swayB;
  final double freqA;
  final double freqB;
  final double phaseA;
  final double phaseB;
  final double flickerA;
  final double flickerB;
  final double flareFreq;
  final double radius;

  /// Whether the ember was thrown up by the burst, so it starts fast.
  final bool kick;

  /// Sideways throw of a burst ember, as a fraction of the width.
  final double fan;

  /// Position at [age] seconds, as fractions of the widget size.
  Offset at(double age) {
    final p = (age / life).clamp(0.0, 1.0);
    // Burst embers shoot up and fan out, then float on; the others leave
    // the fire slowly and climb steadily.
    final rise = kick
        ? height * (0.55 * (1 - pow(1 - p, 2.5)) + 0.45 * pow(p, 1.3))
        : height * pow(p, 1.3);
    final thrown = fan * (1 - pow(1 - p, 3));
    // Sway grows as the ember climbs away from the fire.
    final sway = (0.3 + 0.7 * p) *
        (swayA * sin(phaseA + age * freqA) + swayB * sin(phaseB + age * freqB));
    return Offset(x + thrown + lean * p + sway, 1 - rise);
  }

  /// Brightness at [age]: fade in, flicker, the odd short flare, fade out.
  double alphaAt(double age) {
    final p = age / life;
    final envelope = p < 0.06
        ? p / 0.06
        : p > 0.65
            ? (1 - p) / 0.35
            : 1.0;
    final flicker = 0.7 +
        0.15 * sin(phaseA + age * flickerA) +
        0.15 * sin(phaseB + age * flickerB);
    final flare = sin(phaseB + age * flareFreq) > 0.96 ? 1.4 : 1.0;
    return (envelope * flicker * flare).clamp(0.0, 1.0);
  }
}

/// Hot white-yellow cooling through orange to deep red over an ember's life.
const _coolingStops = [
  Color(0xFFFFF4C2),
  Color(0xFFFFC04D),
  Color(0xFFFF7A1A),
  Color(0xFFD9381E),
  Color(0xFF8E1B10),
];

Color _cooling(double p) {
  final scaled = p.clamp(0.0, 1.0) * (_coolingStops.length - 1);
  final i = scaled.floor().clamp(0, _coolingStops.length - 2);
  return Color.lerp(_coolingStops[i], _coolingStops[i + 1], scaled - i)!;
}

class _EmberPainter extends CustomPainter {
  _EmberPainter(this.elapsed, this.sparks, {required this.dark})
      : super(repaint: elapsed);

  final ValueListenable<double> elapsed;
  final List<_Spark> Function() sparks;

  /// Additive blending makes embers glow on a dark background but washes them
  /// out to white on a light one, so light themes paint normally.
  final bool dark;

  static const _tailSeconds = 0.04;

  @override
  void paint(Canvas canvas, Size size) {
    final list = sparks();
    if (list.isEmpty) return;
    final t = elapsed.value;
    final blend = dark ? BlendMode.plus : BlendMode.srcOver;
    _paintFireGlow(canvas, size, t);
    for (final s in list) {
      final age = t - s.start;
      if (age <= 0 || age >= s.life) continue;
      final alpha = s.alphaAt(age);
      if (alpha <= 0.01) continue;
      final color = _cooling(age / s.life);
      final head = _scale(s.at(age), size);
      final tail = _scale(s.at(max(0, age - _tailSeconds)), size);
      final r = s.radius * (1 - 0.4 * age / s.life);

      // Soft glow around the ember.
      final glow = r * 3;
      canvas.drawCircle(
        head,
        glow,
        Paint()
          ..blendMode = blend
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: 0.4 * alpha),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: head, radius: glow)),
      );
      // A faint trail just behind the ember.
      canvas.drawLine(
        tail,
        head,
        Paint()
          ..blendMode = blend
          ..strokeCap = StrokeCap.round
          ..strokeWidth = r * 0.9
          ..shader = LinearGradient(
            colors: [
              color.withValues(alpha: 0),
              color.withValues(alpha: 0.5 * alpha),
            ],
          ).createShader(Rect.fromPoints(tail, head)),
      );
      // Bright core, hotter than the ember's current colour.
      canvas.drawCircle(
        head,
        r * 0.85,
        Paint()
          ..blendMode = blend
          ..color = Color.lerp(Colors.white, color, 0.35)!
              .withValues(alpha: alpha),
      );
    }
  }

  /// A faint warm glow at the bottom centre, hinting at the fire below.
  void _paintFireGlow(Canvas canvas, Size size, double t) {
    final total = EmberSparks.burstDuration.inMicroseconds /
        Duration.microsecondsPerSecond;
    // Flares up as the log lands, then settles to a steady glow and fades.
    final envelope = t < 0.15
        ? t / 0.15
        : t > total - 2.5
            ? max(0.0, (total - t) / 2.5)
            : 1.0;
    final strength = envelope * (1 + 0.7 * exp(-t * 1.5));
    if (strength <= 0) return;
    // Centred just below the bottom edge: a wide fire just out of view.
    final center = Offset(size.width / 2, size.height + size.width * 0.1);
    final radius = size.width * 0.95;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFF7A1A).withValues(alpha: 0.26 * strength),
            const Color(0xFFFF7A1A).withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  Offset _scale(Offset fraction, Size size) =>
      Offset(fraction.dx * size.width, fraction.dy * size.height);

  @override
  bool shouldRepaint(_EmberPainter old) => old.dark != dark;
}
