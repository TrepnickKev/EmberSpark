import 'package:flutter/material.dart';

import 'wallet_avatar.dart';

/// Sender → recipient indicator shown at the top of the pay confirmation
/// screens when the destination came from a contact pick. Both columns
/// share the same shape (88×88 avatar over a name label) so the row is
/// symmetric. Avatar size matches the home-screen profile bubble.
class PaymentRouteHeader extends StatelessWidget {
  const PaymentRouteHeader({
    super.key,
    required this.senderSeed,
    required this.senderName,
    required this.recipientSeed,
    required this.recipientName,
  });

  final String senderSeed;
  final String senderName;
  final String recipientSeed;
  final String recipientName;

  static const double _avatarSize = 88;
  static const double _arrowIconSize = 24;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AvatarColumn(seed: senderSeed, name: senderName),
          const SizedBox(width: 16),
          // Vertically centre the arrow on the avatar row, ignoring the
          // text label below.
          Padding(
            padding: const EdgeInsets.only(
              top: (_avatarSize - _arrowIconSize) / 2,
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.grey,
              size: _arrowIconSize,
            ),
          ),
          const SizedBox(width: 16),
          _AvatarColumn(seed: recipientSeed, name: recipientName),
        ],
      ),
    );
  }
}

class _AvatarColumn extends StatelessWidget {
  const _AvatarColumn({required this.seed, required this.name});

  final String seed;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WalletAvatar(seed, size: 88),
        const SizedBox(height: 6),
        SizedBox(
          width: 88,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
