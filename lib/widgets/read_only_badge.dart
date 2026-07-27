import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// A small grey outlined "Read only" pill for wallets whose stored key is an
/// LNbits invoice/read key (can receive, not send).
Widget readOnlyBadge(AppLocalizations l10n) {
  return Container(
    margin: const EdgeInsets.only(left: 8),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey, width: 1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.visibility_outlined, size: 11, color: Colors.grey),
        const SizedBox(width: 3),
        Text(
          l10n.walletReadOnly,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
