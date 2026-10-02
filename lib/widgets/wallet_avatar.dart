import 'package:bitcoin_avatar/bitcoin_avatar.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

import '../services/avatar_prefs.dart';

/// Renders a wallet/contact avatar from a deterministic [seed] string, using
/// the new `bitcoin_avatar` emblems by default and the legacy `random_avatar`
/// (multiavatar) style when [useLegacyAvatars] is on. Watching the notifier
/// here means every avatar in the app switches renderer live when the Settings
/// toggle flips. The new renderer self-clips to a circle; the legacy one keeps
/// its previous (caller-clipped) look.
class WalletAvatar extends StatelessWidget {
  const WalletAvatar(this.seed, {this.size = 88, super.key});

  final String seed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: useLegacyAvatars,
      builder: (_, legacy, __) => legacy
          ? SizedBox(
              width: size,
              height: size,
              child: RandomAvatar(seed, height: size, width: size),
            )
          : BitcoinAvatar(seed, size: size),
    );
  }
}
