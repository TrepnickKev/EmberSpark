import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager/nfc_manager_android.dart';

/// Thrown by [readNdefText] and [writeNdefUri] when the device has no NFC
/// chip, or NFC is disabled in system settings.
class NfcUnavailable implements Exception {
  const NfcUnavailable();
  @override
  String toString() => 'NFC unavailable on this device';
}

/// Thrown when a tag is tapped but doesn't expose NDEF (e.g. raw MIFARE
/// classic, or a sticker that has never been formatted).
class NfcTagNotNdef implements Exception {
  const NfcTagNotNdef();
}

/// Thrown when a tap was made but the tag is read-only / doesn't have
/// enough space.
class NfcTagNotWritable implements Exception {
  const NfcTagNotWritable();
}

/// Thrown when a tapped tag doesn't expose ISO-DEP (ISO 14443-4), i.e. it's
/// not a DESFire / NTAG424 chip and can't be programmed as a Bolt Card.
class NfcTagNotIsoDep implements Exception {
  const NfcTagNotIsoDep();
}

/// Handle for an in-progress NFC session. Call [stop] to cancel it.
class NfcSession {
  NfcSession._();
  bool _stopped = false;

  Future<void> stop() async {
    if (_stopped) return;
    _stopped = true;
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {
      // Already stopped or platform raised on dup-stop — swallow.
    }
  }
}

Future<void> _ensureAvailable() async {
  final av = await NfcManager.instance.checkAvailability();
  if (av != NfcAvailability.enabled) {
    throw const NfcUnavailable();
  }
}

/// Reads the first URI or Text payload from the first NDEF record on the
/// first tag tapped. `onRead` fires with the decoded string; `onError`
/// fires for any per-tap failure (non-NDEF tag, unsupported record, etc.).
/// Throws [NfcUnavailable] synchronously if NFC is off or absent.
/// When [stopAfterRead] is false, the session is left active after a read (or
/// error) and the caller is responsible for calling [NfcSession.stop]. Keeping
/// reader mode on suppresses the Android tag-dispatch chooser, so the OS won't
/// grab the still-present card while a result is being shown.
Future<NfcSession> readNdefText({
  required void Function(String) onRead,
  required void Function(Object) onError,
  bool stopAfterRead = true,
}) async {
  await _ensureAvailable();
  final session = NfcSession._();
  await NfcManager.instance.startSession(
    pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
    onDiscovered: (NfcTag tag) async {
      try {
        final ndef = NdefAndroid.from(tag);
        if (ndef == null) {
          throw const NfcTagNotNdef();
        }
        final msg = ndef.cachedNdefMessage ?? await ndef.getNdefMessage();
        if (msg == null || msg.records.isEmpty) {
          throw const NfcTagNotNdef();
        }
        String? payload;
        for (final r in msg.records) {
          payload = _decodeRecord(r);
          if (payload != null) break;
        }
        if (stopAfterRead) await session.stop();
        if (payload == null) {
          onError(const NfcTagNotNdef());
        } else {
          onRead(payload);
        }
      } catch (e) {
        if (stopAfterRead) await session.stop();
        onError(e);
      }
    },
  );
  return session;
}

/// Writes a single URI NDEF record (`uri`, e.g. "lightning:lnbc…") to the
/// first writable tag tapped. Throws [NfcUnavailable] synchronously if NFC
/// is off or absent.
///
/// When [stopAfterWrite] is false, the session is left active after the write
/// (or error) and the caller must call [NfcSession.stop]. Keeping reader mode
/// on suppresses the Android tag-dispatch chooser while a result is shown.
Future<NfcSession> writeNdefUri(
  String uri, {
  required void Function() onSuccess,
  required void Function(Object) onError,
  bool stopAfterWrite = true,
}) async {
  await _ensureAvailable();
  final session = NfcSession._();
  await NfcManager.instance.startSession(
    pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
    onDiscovered: (NfcTag tag) async {
      try {
        final ndef = NdefAndroid.from(tag);
        if (ndef == null) throw const NfcTagNotNdef();
        if (!ndef.isWritable) throw const NfcTagNotWritable();
        final record = _buildUriRecord(uri);
        if (record.byteLength > ndef.maxSize) {
          throw const NfcTagNotWritable();
        }
        await ndef.writeNdefMessage(NdefMessage(records: [record]));
        if (stopAfterWrite) await session.stop();
        onSuccess();
      } catch (e) {
        if (stopAfterWrite) await session.stop();
        onError(e);
      }
    },
  );
  return session;
}

/// Runs [action] against the first ISO-DEP (ISO 14443-4) tag tapped, used for
/// DESFire / NTAG424 APDU exchanges (Bolt Card programming, wiping). The chip's
/// UID (the ISO 14443-3 anticollision id) is passed to [onComplete] after
/// [action] returns successfully; [onError] fires on any per-tap failure.
/// Throws [NfcUnavailable] synchronously if NFC is off or absent.
///
/// When [stopAfterAction] is false, the session is left active after the action
/// (or error) and the caller must call [NfcSession.stop]. Keeping reader mode on
/// suppresses the Android tag-dispatch chooser so the OS won't grab the
/// still-present card while a result is being shown.
Future<NfcSession> runIsoDepSession({
  required Future<void> Function(IsoDepAndroid isoDep) action,
  required void Function(Uint8List uid) onComplete,
  required void Function(Object) onError,
  bool stopAfterAction = true,
}) async {
  await _ensureAvailable();
  final session = NfcSession._();
  // Use Android reader mode with skipNdefCheck so the platform doesn't read
  // NDEF or interfere while we drive raw DESFire APDUs, and noPlatformSounds to
  // avoid the scan beep mid-write. Stopping the session (NfcSession.stop ->
  // stopSession) disables this same reader mode.
  await NfcManagerAndroid.instance.enableReaderMode(
    flags: {
      NfcReaderFlagAndroid.nfcA,
      NfcReaderFlagAndroid.nfcB,
      NfcReaderFlagAndroid.skipNdefCheck,
      NfcReaderFlagAndroid.noPlatformSounds,
    },
    onTagDiscovered: (NfcTag tag) async {
      try {
        final iso = IsoDepAndroid.from(tag);
        if (iso == null) throw const NfcTagNotIsoDep();
        await action(iso);
        if (stopAfterAction) await session.stop();
        onComplete(iso.tag.id);
      } catch (e) {
        if (stopAfterAction) await session.stop();
        onError(e);
      }
    },
  );
  return session;
}

/// Decodes a single NDEF record into a string, or returns null if the
/// record type isn't a URI or Text record.
String? _decodeRecord(NdefRecord r) {
  if (r.payload.isEmpty) return null;
  // Well-known URI ("U") — first byte is the prefix-code, rest is UTF-8.
  if (r.typeNameFormat == TypeNameFormat.wellKnown &&
      r.type.length == 1 &&
      r.type[0] == 0x55) {
    final prefix = _uriPrefix(r.payload[0]);
    final rest = utf8.decode(r.payload.sublist(1), allowMalformed: true);
    return '$prefix$rest';
  }
  // Well-known Text ("T") — status byte + lang code + UTF-8/16 text.
  if (r.typeNameFormat == TypeNameFormat.wellKnown &&
      r.type.length == 1 &&
      r.type[0] == 0x54) {
    final status = r.payload[0];
    final langLen = status & 0x3F;
    final isUtf16 = (status & 0x80) != 0;
    final textBytes = r.payload.sublist(1 + langLen);
    return isUtf16
        ? _decodeUtf16(textBytes)
        : utf8.decode(textBytes, allowMalformed: true);
  }
  // Absolute URI — type field is the URI itself.
  if (r.typeNameFormat == TypeNameFormat.absoluteUri && r.type.isNotEmpty) {
    return utf8.decode(r.type, allowMalformed: true);
  }
  return null;
}

NdefRecord _buildUriRecord(String uri) {
  return NdefRecord(
    typeNameFormat: TypeNameFormat.wellKnown,
    type: Uint8List.fromList([0x55]), // 'U'
    identifier: Uint8List(0),
    // 0x00 = no shorthand prefix, full URI in the rest of the payload.
    payload: Uint8List.fromList([0x00, ...utf8.encode(uri)]),
  );
}

String _uriPrefix(int code) {
  // From NFC Forum URI Record Type Definition.
  const prefixes = <String>[
    '', // 0x00 — full URI in payload
    'http://www.', 'https://www.', 'http://', 'https://',
    'tel:', 'mailto:', 'ftp://anonymous:anonymous@', 'ftp://ftp.',
    'ftps://', 'sftp://', 'smb://', 'nfs://', 'ftp://', 'dav://',
    'news:', 'telnet://', 'imap:', 'rtsp://', 'urn:', 'pop:',
    'sip:', 'sips:', 'tftp:', 'btspp://', 'btl2cap://', 'btgoep://',
    'tcpobex://', 'irdaobex://', 'file://', 'urn:epc:id:',
    'urn:epc:tag:', 'urn:epc:pat:', 'urn:epc:raw:', 'urn:epc:',
    'urn:nfc:',
  ];
  return code >= 0 && code < prefixes.length ? prefixes[code] : '';
}

String _decodeUtf16(Uint8List bytes) {
  final codeUnits = <int>[];
  // UTF-16BE per NDEF spec when status byte indicates UTF-16.
  for (var i = 0; i + 1 < bytes.length; i += 2) {
    codeUnits.add((bytes[i] << 8) | bytes[i + 1]);
  }
  return String.fromCharCodes(codeUnits);
}
