/// The bundled art manifest — the source of truth for what the compositor can
/// pick per slot. Flutter can't reliably enumerate assets at runtime, so when
/// you add art under the package's `assets/` folders (see ASSET_SPEC.md), list
/// the package-relative paths here AND declare `assets/` in `pubspec.yaml`.
///
/// Paths are loaded via `Image.asset(path, package: 'bitcoin_avatar')`.
///
/// While a slot is empty the compositor still consumes one deterministic draw
/// for it (so filling one slot later does not shuffle the others), and — when
/// `animals` is empty — the widget renders a neutral fallback instead of a
/// blank circle.
class AvatarLayers {
  const AvatarLayers._();

  static const List<String> backgrounds = <String>[
    'assets/background/bg_beach_night.png',
    'assets/background/bg_forest.png',
    'assets/background/bg_forest_fall.png',
    'assets/background/bg_forest_night.png',
    'assets/background/bg_forest_spring.png',
    'assets/background/bg_forest_thunder.png',
    'assets/background/bg_forest_winter.png',
    'assets/background/bg_lake_fall.png',
    'assets/background/bg_lake_night.png',
    'assets/background/bg_lake_spring.png',
    'assets/background/bg_lake_winter.png',
    'assets/background/bg_mountains_day.png',
    'assets/background/bg_mountains_night.png',
    'assets/background/bg_mountains_rain.png',
    'assets/background/bg_mountains_sunset.png',
  ];

  static const List<String> animals = <String>[
    'assets/animal/animal_badger.png',
    'assets/animal/animal_bear.png',
    'assets/animal/animal_bull_brown_fur.png',
    'assets/animal/animal_cat.png',
    'assets/animal/animal_cat_shorthair.png',
    'assets/animal/animal_cat_shorthair_sand.png',
    'assets/animal/animal_dog.png',
    'assets/animal/animal_dog_labrador.png',
    'assets/animal/animal_duck.png',
    'assets/animal/animal_fox.png',
    'assets/animal/animal_otter.png',
    'assets/animal/animal_owl.png',
    'assets/animal/animal_owl_dark.png',
    'assets/animal/animal_penguin.png',
    'assets/animal/animal_penguin_yellow_hair.png',
    'assets/animal/animal_rabbit.png',
    'assets/animal/animal_raccoon.png',
    'assets/animal/animal_red_panda.png',
    'assets/animal/animal_sheep.png',
    'assets/animal/animal_squirrel.png',
    'assets/animal/animal_squirrel_european_red.png',
    'assets/animal/animal_wolf_gray.png',
    'assets/animal/animal_wolf_white.png',
    'assets/animal/animal_woodpecker.png',
  ];

  static const List<String> details = <String>[
    // "No accessory" is one option among equals: it is listed exactly once, so
    // it is as likely as any single scarf or vest.
    'assets/detail/detail_none.png',
    'assets/detail/detail_coat_black.png',
    'assets/detail/detail_coat_blue.png',
    'assets/detail/detail_coat_bordeaux.png',
    'assets/detail/detail_coat_green.png',
    'assets/detail/detail_coat_purple.png',
    'assets/detail/detail_hoodie_black.png',
    'assets/detail/detail_hoodie_blue.png',
    'assets/detail/detail_hoodie_bordeaux.png',
    'assets/detail/detail_hoodie_green.png',
    'assets/detail/detail_hoodie_orange.png',
    'assets/detail/detail_hoodie_purple.png',
    'assets/detail/detail_jacket_black.png',
    'assets/detail/detail_jacket_blue.png',
    'assets/detail/detail_jacket_bordeaux.png',
    'assets/detail/detail_jacket_green.png',
    'assets/detail/detail_jacket_orange.png',
    'assets/detail/detail_jacket_purple.png',
    'assets/detail/detail_scarf.png',
    'assets/detail/detail_scarf_black.png',
    'assets/detail/detail_scarf_blue.png',
    'assets/detail/detail_scarf_bordeaux.png',
    'assets/detail/detail_scarf_brown.png',
    'assets/detail/detail_scarf_green.png',
    'assets/detail/detail_scarf_orange.png',
    'assets/detail/detail_scarf_purple.png',
    'assets/detail/detail_vest_blue.png',
    'assets/detail/detail_vest_bordeaux.png',
    'assets/detail/detail_vest_green.png',
    'assets/detail/detail_vest_orange.png',
    'assets/detail/detail_vest_purple.png',
  ];

  static const List<String> effects = <String>[
    // e.g. 'assets/effect/effect_none.png',
  ];

  /// Bitcoin badge overlays, drawn last when the widget's badge toggle is on.
  /// One is picked per seed like any other slot, but visibility is controlled
  /// by [BitcoinAvatar.showBitcoinBadge] rather than randomness.
  static const List<String> badges = <String>[
    'assets/badge/badge_bitcoin_gold.png',
    'assets/badge/badge_coin.png',
    'assets/badge/badge_flash.png',
    'assets/badge/badge_lightning.png',
  ];

  /// True once at least one animal is bundled; gates real compositing vs the
  /// neutral fallback.
  static bool get hasArt => animals.isNotEmpty;
}
