import 'dart:ui';

/// A background + accent pair, tuned to read well on a dark UI (EmberSpark).
class AvatarPalette {
  const AvatarPalette({
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.accent,
  });

  /// Top of the radial/vertical background wash.
  final Color backgroundTop;

  /// Bottom / outer of the background wash.
  final Color backgroundBottom;

  /// The emblem's dominant color (coin, features).
  final Color accent;
}

/// Bitcoin orange, the anchor accent of the set.
const Color bitcoinOrange = Color(0xFFF7931A);

/// Curated palettes. The background is always dark so the bright emblem pops;
/// accents are warm/energetic hues that fit a Bitcoin/Lightning feel. Kept
/// small and hand-picked for MVP — every combination should look good.
const List<AvatarPalette> kPalettes = [
  // Classic bitcoin orange on coal.
  AvatarPalette(
    backgroundTop: Color(0xFF2A1B0E),
    backgroundBottom: Color(0xFF120B06),
    accent: bitcoinOrange,
  ),
  // Amber / gold.
  AvatarPalette(
    backgroundTop: Color(0xFF2C2410),
    backgroundBottom: Color(0xFF121004),
    accent: Color(0xFFFFC24D),
  ),
  // Ember red.
  AvatarPalette(
    backgroundTop: Color(0xFF2E1410),
    backgroundBottom: Color(0xFF140806),
    accent: Color(0xFFF25C43),
  ),
  // Lightning violet.
  AvatarPalette(
    backgroundTop: Color(0xFF1E1630),
    backgroundBottom: Color(0xFF0C0916),
    accent: Color(0xFFB388FF),
  ),
  // Electric teal.
  AvatarPalette(
    backgroundTop: Color(0xFF0E2626),
    backgroundBottom: Color(0xFF041210),
    accent: Color(0xFF35E0C4),
  ),
  // Sky blue.
  AvatarPalette(
    backgroundTop: Color(0xFF10202E),
    backgroundBottom: Color(0xFF050D14),
    accent: Color(0xFF4DB7FF),
  ),
  // Lime spark.
  AvatarPalette(
    backgroundTop: Color(0xFF1A2810),
    backgroundBottom: Color(0xFF0A1204),
    accent: Color(0xFF9CE34D),
  ),
  // Magenta.
  AvatarPalette(
    backgroundTop: Color(0xFF2C1226),
    backgroundBottom: Color(0xFF140610),
    accent: Color(0xFFFF6EC7),
  ),
];
