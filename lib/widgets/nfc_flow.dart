import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/nfc_service.dart';

/// Shared NFC read/write flows that keep the reader session active until the
/// user acknowledges a result dialog. While reader mode stays on, Android's
/// tag-dispatch chooser ("open with …") cannot interrupt, so the user has time
/// to lift the tag before the session ends. Mirrors the Bolt Card flows.

/// Reads an NDEF tag: shows a "hold tag" dialog, then a persistent "tag read"
/// confirmation (reader kept active until OK). Returns the trimmed payload, or
/// null if cancelled / failed / unavailable.
Future<String?> readNfcTagWithConfirm(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  final rootNav = Navigator.of(context, rootNavigator: true);

  String? payload;
  Object? err;
  var holdOpen = false;
  void closeHold() {
    if (holdOpen) {
      rootNav.pop();
      holdOpen = false;
    }
  }

  NfcSession session;
  try {
    session = await readNdefText(
      stopAfterRead: false,
      onRead: (p) {
        payload = p;
        closeHold();
      },
      onError: (e) {
        err = e;
        closeHold();
      },
    );
  } on NfcUnavailable {
    messenger.showSnackBar(SnackBar(content: Text(l10n.nfcUnavailable)));
    return null;
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.nfcReadFailed)));
    return null;
  }

  try {
    if (!context.mounted) return null;
    if (payload == null && err == null) {
      holdOpen = true;
      await _holdDialog(context, l10n.nfcHoldTag);
      holdOpen = false;
    }
    final text = payload?.trim() ?? '';
    if (text.isEmpty) {
      if (err != null) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.nfcReadFailed)));
      }
      return null; // cancelled or failed
    }
    if (context.mounted) {
      await _confirmDialog(context, l10n.nfcTagRead);
    }
    return text;
  } finally {
    await session.stop();
  }
}

/// Writes [uri] to a tag: "hold tag" dialog, then a persistent confirmation
/// (reader kept active until OK). Returns true on success.
Future<bool> writeNfcUriWithConfirm(BuildContext context, String uri) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  final rootNav = Navigator.of(context, rootNavigator: true);

  var ok = false;
  Object? err;
  var holdOpen = false;
  void closeHold() {
    if (holdOpen) {
      rootNav.pop();
      holdOpen = false;
    }
  }

  NfcSession session;
  try {
    session = await writeNdefUri(
      uri,
      stopAfterWrite: false,
      onSuccess: () {
        ok = true;
        closeHold();
      },
      onError: (e) {
        err = e;
        closeHold();
      },
    );
  } on NfcUnavailable {
    messenger.showSnackBar(SnackBar(content: Text(l10n.nfcUnavailable)));
    return false;
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.nfcWriteFailed)));
    return false;
  }

  try {
    if (!context.mounted) return false;
    if (!ok && err == null) {
      holdOpen = true;
      await _holdDialog(context, l10n.nfcHoldTag);
      holdOpen = false;
    }
    if (!ok) {
      if (err != null) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.nfcWriteFailed)));
      }
      return false;
    }
    if (context.mounted) {
      await _confirmDialog(context, l10n.nfcWriteSuccess);
    }
    return true;
  } finally {
    await session.stop();
  }
}

/// "Hold an NFC tag" progress dialog with a Cancel button. Returns when the
/// dialog is dismissed (by the caller closing it on read/write, or by Cancel).
Future<void> _holdDialog(BuildContext context, String message) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      content: Row(
        children: [
          const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(message)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: Text(l10n.commonCancel),
        ),
      ],
    ),
  );
}

/// Persistent success confirmation (a green check + [message] + OK). Shown
/// while the reader session is still active so the OS chooser stays suppressed.
Future<void> _confirmDialog(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    ),
  );
}
