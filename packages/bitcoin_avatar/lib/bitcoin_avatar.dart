/// Deterministic Bitcoin/Lightning themed avatars, composited from illustrated
/// layers selected by a seed hash.
///
/// ```dart
/// BitcoinAvatar('satoshi@example.com', size: 64)
/// ```
library;

export 'src/bitcoin_avatar.dart' show BitcoinAvatar;
export 'src/avatar_composition.dart' show AvatarComposition, buildComposition;
export 'src/avatar_layers.dart' show AvatarLayers;
export 'src/palette.dart' show AvatarPalette, kPalettes, bitcoinOrange;
