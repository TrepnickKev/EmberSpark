import 'avatar_layers.dart';
import 'seeded_random.dart';

/// The resolved set of layer asset paths for one avatar, back-to-front. Any
/// slot may be null when that slot has no bundled art. Plain data — no Flutter
/// — so selection is unit-testable without rendering.
class AvatarComposition {
  const AvatarComposition({
    required this.background,
    required this.animal,
    required this.detail,
    required this.effect,
    this.badge,
  });

  final String? background;
  final String? animal;
  final String? detail;
  final String? effect;

  /// The seed-chosen Bitcoin badge overlay. Unlike the other slots it is not
  /// part of [layers]; the widget appends it only when its badge toggle is on.
  final String? badge;

  /// Whether there is a character to composite. When false the widget renders
  /// the neutral fallback.
  bool get usesArt => animal != null;

  /// The layers in draw order (back to front), skipping empty slots.
  List<String> get layers => [
        if (background != null) background!,
        if (animal != null) animal!,
        if (detail != null) detail!,
        if (effect != null) effect!,
      ];

  @override
  String toString() =>
      'AvatarComposition(bg: $background, animal: $animal, detail: $detail, '
      'effect: $effect)';
}

/// Deterministically resolves the layer set for [seed]. Draw order is fixed —
/// one draw per slot regardless of how many options that slot has (or whether
/// it is empty) — so adding art to one slot never re-rolls the others.
///
/// The layer lists default to the bundled [AvatarLayers] manifest; tests pass
/// their own lists to exercise selection.
AvatarComposition buildComposition(
  String seed, {
  List<String> backgrounds = AvatarLayers.backgrounds,
  List<String> animals = AvatarLayers.animals,
  List<String> details = AvatarLayers.details,
  List<String> effects = AvatarLayers.effects,
  List<String> badges = AvatarLayers.badges,
}) {
  final rng = SeededRandom(seed);
  return AvatarComposition(
    background: _pick(rng, backgrounds),
    animal: _pick(rng, animals),
    detail: _pick(rng, details),
    effect: _pick(rng, effects),
    badge: _pick(rng, badges),
  );
}

/// Consumes exactly one draw and returns the chosen item, or null if [items]
/// is empty (the draw is still consumed to keep the stream aligned).
String? _pick(SeededRandom rng, List<String> items) {
  final i = rng.nextInt(items.isEmpty ? 1 : items.length);
  return items.isEmpty ? null : items[i];
}
