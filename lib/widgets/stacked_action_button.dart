import 'package:flutter/material.dart';

/// Bitcoin's canonical orange (the bitcoin.org logo colour). Used as a
/// brand accent on action buttons and section headers without recolouring
/// the entire Material theme.
const Color bitcoinOrange = Color(0xFFF7931A);

/// Thin translucent-orange outline for buttons, cards, dialogs and sheets,
/// mirroring satoshihabits.com's resting card/button border. Full [bitcoinOrange]
/// stays for text, icons and active states. Not const because [Color.withValues]
/// is not a const call.
final Color bitcoinOutline = bitcoinOrange.withValues(alpha: 0.30);

/// A circular outlined icon button with a label centred below it.
/// Phoenix-Wallet-style action button — used in the Receive, Send, and QR
/// scanner rows. Active state uses [bitcoinOrange]; disabled falls back to
/// the theme's disabled colour.
class StackedActionButton extends StatelessWidget {
  const StackedActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = onPressed == null
        ? Theme.of(context).disabledColor
        : bitcoinOrange;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          shape: CircleBorder(
            side: BorderSide(color: color.withValues(alpha: 0.6)),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Icon(icon, color: color, size: 22),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }
}
