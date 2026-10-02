import 'package:flutter/widgets.dart';

import 'avatar_composition.dart';
import 'fallback_painter.dart';

/// A deterministic Bitcoin/Lightning themed avatar for [seed].
///
/// The same [seed] always renders the same avatar, so seeding from a public
/// identity (a Lightning address, node pubkey, ...) gives every identity a
/// stable, recognisable image. Rendered as a circular [size]x[size] widget.
///
/// Illustrated art is composited from bundled layers (see ASSET_SPEC.md). Until
/// any art is bundled it renders a neutral placeholder, so it is never blank.
class BitcoinAvatar extends StatelessWidget {
  const BitcoinAvatar(
    this.seed, {
    this.size = 88,
    this.showBitcoinBadge = true,
    super.key,
  });

  /// The package name that owns the bundled assets.
  static const String _package = 'bitcoin_avatar';

  /// The identity string to derive the avatar from.
  final String seed;

  /// Width and height in logical pixels.
  final double size;

  /// Whether the ₿ badge overlay is drawn. The badge variant is still chosen
  /// deterministically from [seed], so toggling this on/off never changes the
  /// rest of the avatar.
  final bool showBitcoinBadge;

  @override
  Widget build(BuildContext context) {
    final composition = buildComposition(seed);
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: composition.usesArt
            ? _composited(composition)
            : CustomPaint(
                size: Size.square(size),
                painter: FallbackAvatarPainter(seed),
              ),
      ),
    );
  }

  Widget _composited(AvatarComposition composition) {
    final badge = showBitcoinBadge ? composition.badge : null;
    return Stack(
      fit: StackFit.expand,
      children: [
        for (final path in [...composition.layers, if (badge != null) badge])
          Image.asset(
            path,
            package: _package,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            // A missing/renamed asset degrades to nothing rather than crashing.
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
      ],
    );
  }
}
