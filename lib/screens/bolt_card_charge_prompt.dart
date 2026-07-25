import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/lightning_router.dart';
import '../services/nfc_service.dart';

/// Ambient NFC tap handler for screens where a tapped Bolt Card should NOT
/// silently start a charge (Send, Scan QR) — you may have meant to pay. Shows a
/// short explanation that a Bolt Card can only be charged (you withdraw from
/// it), then on confirm continues to the withdraw/charge screen. Non-withdraw
/// taps fall through (return false) so the coordinator's default routing
/// handles them.
Future<bool> promptBoltCardChargeOnly(
  BuildContext context,
  NfcAmbientTag tag,
) async {
  final code = (tag.payload ?? '').trim();
  if (!RegExp(r'^lnurlw://', caseSensitive: false).hasMatch(code)) {
    return false;
  }
  final l10n = AppLocalizations.of(context)!;
  final navigator = Navigator.of(context);
  final proceed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.boltCardChargeOnlyTitle),
      content: Text(l10n.boltCardChargeOnlyBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.boltCardChargeAction),
        ),
      ],
    ),
  );
  if (proceed == true) {
    unawaited(routeLightningCode(navigator, code));
  }
  return true;
}
