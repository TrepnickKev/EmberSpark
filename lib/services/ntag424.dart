import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// Programs / wipes an NXP **NTAG424 DNA** chip for use as a Bolt Card, using
/// DESFire EV2 secure messaging over an ISO-DEP (ISO 14443-4) APDU channel.
///
/// This module is deliberately decoupled from `nfc_manager`: it talks to the
/// card only through a [Transceive] callback (`isoDep.transceive`). That keeps
/// the protocol/crypto unit-testable without NFC hardware.
///
/// The flow follows NXP application note **AN12196** and matches what the
/// official open-source Bolt Card NFC Card Creator writes, so cards programmed
/// here verify against the LNbits `boltcards` extension:
///   1. ISO select the NDEF application.
///   2. Write the `lnurlw://…?p=…&c=…` NDEF template (plain; factory NDEF file
///      has free write access).
///   3. AuthenticateEV2First with key 0 (factory default = all-zero).
///   4. ChangeFileSettings on the NDEF file to switch on SDM/SUN, mirroring the
///      encrypted PICCData (UID+counter) into `p=` and a CMAC into `c=`.
///   5. ChangeKey for keys 1..4 (K3:=K1, K4:=K2), then key 0 LAST.
///   6. Re-authenticate with the new key 0 to prove the write took.
///
/// Safety: a wrong command counter / session key makes the card reject a
/// command with an integrity error *before* any key is changed, so a protocol
/// bug fails cleanly rather than bricking a card. The only irreversible step is
/// ChangeKey, which runs only after the earlier authenticated commands have
/// already succeeded.
typedef Transceive = Future<Uint8List> Function(Uint8List apdu);

/// The factory-default AES key on a blank NTAG424 (all zeroes).
final Uint8List _defaultKey = Uint8List(16);

class Ntag424Exception implements Exception {
  final String message;
  const Ntag424Exception(this.message);
  @override
  String toString() => 'Ntag424Exception: $message';
}

/// Thrown when AuthenticateEV2First with the default key fails — almost always
/// because the card has already been programmed (its keys are not default).
class CardNotBlank implements Exception {
  const CardNotBlank();
  @override
  String toString() => 'Card is not blank (already programmed). Wipe it first.';
}

/// Keys + identifiers needed to program a card. K3 is written equal to K1 and
/// K4 equal to K2, matching the LNbits boltcards / Bolt Card app convention.
class BoltCardKeys {
  final Uint8List k0;
  final Uint8List k1;
  final Uint8List k2;
  const BoltCardKeys(this.k0, this.k1, this.k2);

  factory BoltCardKeys.fromHex(String k0, String k1, String k2) =>
      BoltCardKeys(_hexToBytes(k0), _hexToBytes(k1), _hexToBytes(k2));
}

/// Driver for one tap. Construct with the card's [transceive] function, then
/// call [programBoltcard] or [wipe].
class Ntag424 {
  final Transceive _transceive;

  // Authenticated-session state (set by [_authenticateEV2First]).
  Uint8List? _sesEnc;
  Uint8List? _sesMac;
  Uint8List? _ti;
  int _cmdCtr = 0;

  /// Diagnostic trace of the APDU exchange + intermediate crypto values,
  /// captured for debugging the secure-messaging path on real hardware. It is
  /// appended to a thrown [Ntag424Exception] so the on-screen error dialog can
  /// surface it. Test-card only (it includes keys / session values).
  final List<String> trace = [];
  void _log(String label, [Object? v]) =>
      trace.add(v == null ? label : '$label: ${v is Uint8List ? _hexOf(v) : v}');
  static String _hexOf(Uint8List b) =>
      b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

  Ntag424(this._transceive);

  /// NDEF application id (D2 76 00 00 85 01 01).
  static final Uint8List _ndefAid =
      Uint8List.fromList([0xD2, 0x76, 0x00, 0x00, 0x85, 0x01, 0x01]);

  static const int _ndefFileNo = 0x02;

  /// Programs a blank card so it scans as [lnurlwTemplate], then rotates its
  /// keys to [keys]. Throws [CardNotBlank] if the card isn't factory-default.
  ///
  /// [lnurlwTemplate] must contain literal `p=` and `c=` query parameters whose
  /// (zeroed) values are the right length: 32 hex chars after `p=` (16-byte
  /// encrypted PICCData) and 16 hex chars after `c=` (8-byte CMAC).
  Future<void> programBoltcard({
    required String lnurlwTemplate,
    required BoltCardKeys keys,
  }) async {
    try {
      await _isoSelectNdefApp();

      final fileBytes = _buildNdefFile(lnurlwTemplate);
      final piccOffset = _valueOffset(fileBytes, 'p=');
      final macOffset = _valueOffset(fileBytes, 'c=');

      // Write the NDEF template (factory NDEF file allows free write).
      await _writeDataPlain(_ndefFileNo, 0, fileBytes);

      // Authenticate with the factory-default key 0.
      await _authenticateEV2First(0x00, _defaultKey);

      // Turn on SDM/SUN mirroring of the encrypted PICCData + CMAC.
      await _changeFileSettingsSdm(
        piccDataOffset: piccOffset,
        macInputOffset: macOffset,
        macOffset: macOffset,
      );

      // Rotate the keys. Non-auth keys (1..4) use the diversified XOR+CRC form;
      // key 0 (the auth key) is changed LAST with the same-key form, after which
      // the session is invalid.
      await _changeKey(1, _defaultKey, keys.k1);
      await _changeKey(2, _defaultKey, keys.k2);
      await _changeKey(3, _defaultKey, keys.k1); // K3 := K1
      await _changeKey(4, _defaultKey, keys.k2); // K4 := K2
      await _changeKey(0, _defaultKey, keys.k0);

      // Prove the write: re-authenticate with the new key 0.
      await _authenticateEV2First(0x00, keys.k0);
    } on CardNotBlank {
      rethrow;
    } catch (e) {
      throw _withTrace(e);
    }
  }

  /// Resets a programmed card back to factory keys and disables SDM, so it can
  /// be reused. Needs the card's *current* keys.
  Future<void> wipe(BoltCardKeys keys) async {
    try {
      await _isoSelectNdefApp();

      // Authenticate with the stored key 0; if that fails, the card may already
      // be at factory keys (only partially programmed, or already reset), so try
      // the default key.
      var keysAreDefault = false;
      try {
        await _authenticateEV2First(0x00, keys.k0);
      } on CardNotBlank {
        try {
          await _authenticateEV2First(0x00, _defaultKey);
          keysAreDefault = true;
        } on CardNotBlank {
          throw const Ntag424Exception(
            'Could not authenticate with the saved or default keys; the card was '
            'likely programmed with different keys.',
          );
        }
      }

      // DIAGNOSTIC: probe the command-MAC path (no encrypted data) to isolate a
      // MAC-side failure from an encrypted-data one. Logged into the trace.
      try {
        await _probeGetCardUid();
      } catch (e) {
        _log('getUID error', '$e');
      }

      // Disable SDM and restore plain, free-read/write NDEF file settings.
      await _changeFileSettingsPlain();

      // Only the stored-key case needs the keys reset to default; a card that
      // already authenticated with the default key is at factory keys already.
      if (!keysAreDefault) {
        await _changeKey(1, keys.k1, _defaultKey);
        await _changeKey(2, keys.k2, _defaultKey);
        await _changeKey(3, keys.k1, _defaultKey);
        await _changeKey(4, keys.k2, _defaultKey);
        await _changeKey(0, keys.k0, _defaultKey);
      }
    } catch (e) {
      throw _withTrace(e);
    }
  }

  /// Wraps a failure with the captured APDU/crypto trace so it surfaces in the
  /// on-screen error dialog for debugging.
  Ntag424Exception _withTrace(Object e) => Ntag424Exception(
        '$e\n\n--- trace ---\n${trace.join('\n')}',
      );

  // ---- ISO / native command wrappers --------------------------------------

  Future<void> _isoSelectNdefApp() async {
    // ISO SelectFile by DF name (the NDEF application AID). This is an ISO
    // 7816-4 command, so success is SW 0x9000 (not the DESFire-native 0x9100
    // that the wrapped commands return).
    final apdu = Uint8List.fromList(
        <int>[0x00, 0xA4, 0x04, 0x0C, _ndefAid.length, ..._ndefAid]);
    final resp = await _transceive(apdu);
    _log('select TX', apdu);
    _log('select RX', resp);
    _ensureIsoStatus(resp, 'select NDEF app');
  }

  /// WriteData (0x8D) in plain comm mode (no session). Used for the NDEF
  /// template before authentication, relying on the factory free-write access.
  Future<void> _writeDataPlain(int fileNo, int offset, Uint8List data) async {
    final header = <int>[
      fileNo,
      ..._int3le(offset),
      ..._int3le(data.length),
    ];
    final apdu = _wrap(0x8D, header, data);
    final resp = await _transceive(apdu);
    _log('writeNDEF TX', apdu);
    _log('writeNDEF RX', resp);
    // A blank card's NDEF file has free write access. A 0x91AE (authentication
    // error) here means the file is key-locked, i.e. the card is already
    // configured — surface that as the friendly "not blank" case rather than a
    // raw status.
    if (_sw(resp) == 0x91AE) throw const CardNotBlank();
    _ensureStatus(resp, 'write NDEF');
  }

  // ---- AuthenticateEV2First (AN12196 §6.6) ---------------------------------

  Future<void> _authenticateEV2First(int keyNo, Uint8List key) async {
    _log('auth keyNo', '$keyNo');
    _log('auth key', key);
    // Part 1: send key number; card returns E(K, RndB).
    final r1 = await _transceive(_wrap(0x71, [keyNo, 0x00], Uint8List(0)));
    _log('auth1 RX', r1);
    if (!_isAdditionalFrame(r1)) {
      // The card rejected auth with this key.
      throw const CardNotBlank();
    }
    final ekRndB = _body(r1);
    final rndB = _aesCbcDecrypt(key, Uint8List(16), ekRndB);
    _log('RndB', rndB);

    final rndA = _randomBytes(16);
    _log('RndA', rndA);
    final rndBRot = _rotateLeft(rndB);
    final plain = Uint8List.fromList([...rndA, ...rndBRot]);
    final ekData = _aesCbcEncrypt(key, Uint8List(16), plain);

    // Part 2: send E(K, RndA || RndB'); card returns E(K, TI || RndA' || caps).
    final r2 = await _transceive(_wrap(0xAF, const [], ekData));
    _log('auth2 RX', r2);
    if (!_isSuccess(r2)) {
      throw const CardNotBlank();
    }
    final decrypted = _aesCbcDecrypt(key, Uint8List(16), _body(r2));
    final ti = decrypted.sublist(0, 4);
    final rndAPrimeResp = decrypted.sublist(4, 20);
    if (!_bytesEqual(rndAPrimeResp, _rotateLeft(rndA))) {
      throw const Ntag424Exception('RndA mismatch (authentication failed)');
    }

    // Derive session keys (AN12196 §6.6.2). SV1 -> MAC key, SV2 -> ENC key.
    final sv1 = _sessionVector(0xA5, 0x5A, rndA, rndB);
    final sv2 = _sessionVector(0x5A, 0xA5, rndA, rndB);
    _sesMac = _aesCmac(key, sv1);
    _sesEnc = _aesCmac(key, sv2);
    _ti = ti;
    _cmdCtr = 0;
    _log('TI', ti);
    _log('SesEnc', _sesEnc!);
    _log('SesMac', _sesMac!);
  }

  /// SV = [c0, c1, 0x00, 0x01, 0x00, 0x80] + RndA[0:2]
  ///      + (RndA[2:8] XOR RndB[0:6]) + RndB[6:16] + RndA[8:16]
  static Uint8List _sessionVector(int c0, int c1, Uint8List a, Uint8List b) {
    final out = BytesBuilder();
    out.add([c0, c1, 0x00, 0x01, 0x00, 0x80]);
    out.add(a.sublist(0, 2));
    out.add(_xor(a.sublist(2, 8), b.sublist(0, 6)));
    out.add(b.sublist(6, 16));
    out.add(a.sublist(8, 16));
    return out.toBytes();
  }

  // ---- ChangeFileSettings (CommMode.Full) ----------------------------------

  /// Enables SDM on the NDEF file: mirror encrypted PICCData (UID+counter) at
  /// [piccDataOffset] into `p=`, and a CMAC at [macOffset] into `c=`. Mirrors
  /// the byte layout the working Bolt Card app sends; only the three offsets
  /// vary with the URL length and are computed by the caller.
  Future<void> _changeFileSettingsSdm({
    required int piccDataOffset,
    required int macInputOffset,
    required int macOffset,
  }) async {
    final data = <int>[
      0x40, // FileOption: SDM enabled, CommMode = Plain
      0x00, 0xE0, // AccessRights: Read=free, Write/RW/Change=key0
      0xC1, // SDMOptions: UID + ReadCtr + ASCII encoding
      // SDMAccessRights, sent high byte first: 0xFF = RFU(F) + CtrRet(none, F);
      // 0x12 = SDMMetaRead=key1, SDMFileRead=key2. (A wrong CtrRet here with the
      // read counter enabled makes the card reject ChangeFileSettings, SW=0x911E.)
      0xFF, 0x12,
      ..._int3le(piccDataOffset), // PICCDataOffset
      ..._int3le(macInputOffset), // SDMMACInputOffset
      ..._int3le(macOffset), // SDMMACOffset
    ];
    final resp = await _transceiveFull(0x5F, [_ndefFileNo], Uint8List.fromList(data));
    _ensureStatus(resp, 'enable SDM');
  }

  /// Restores the NDEF file to plain, free read/write, SDM disabled (for wipe).
  Future<void> _changeFileSettingsPlain() async {
    final data = <int>[0x00, 0xE0, 0xEE];
    final resp = await _transceiveFull(0x5F, [_ndefFileNo], Uint8List.fromList(data));
    _ensureStatus(resp, 'disable SDM');
  }

  /// DIAGNOSTIC: GetCardUID (0x51) is CommMode.Full with no command data, so it
  /// exercises only the command-MAC path (session MAC key + counter + TI),
  /// independent of any encrypted command data. Logging its result isolates a
  /// MAC-side failure from an encryption/settings-side one. Non-destructive;
  /// only advances the counter on success (so a rejected probe doesn't desync).
  Future<void> _probeGetCardUid() async {
    final mac = _sesMac!, ti = _ti!;
    _cmdCtr++; // increment before, like every secured command
    final ctr = _ctrLe();
    final macInput = Uint8List.fromList([0x51, ...ctr, ...ti]);
    final mact = _truncateMac(_aesCmac(mac, macInput));
    final apdu = _wrap(0x51, const [], mact);
    _log('getUID ctr=$_cmdCtr TX', apdu);
    final resp = await _transceive(apdu);
    _log('getUID RX', resp);
  }

  // ---- ChangeKey (CommMode.Full, AN12196 §6.5) -----------------------------

  Future<void> _changeKey(int keyNo, Uint8List oldKey, Uint8List newKey) async {
    final Uint8List plain;
    if (keyNo == 0x00) {
      // Changing the currently authenticated key: NewKey || KeyVersion.
      plain = Uint8List.fromList([...newKey, 0x00]);
    } else {
      // Other keys: (NewKey XOR OldKey) || KeyVersion || CRC32(NewKey).
      plain = Uint8List.fromList([
        ..._xor(newKey, oldKey),
        0x00,
        ..._crc32Le(newKey),
      ]);
    }
    final resp = await _transceiveFull(0xC4, [keyNo], plain);
    _ensureStatus(resp, 'change key $keyNo');
  }

  // ---- Secure-messaging transport (CommMode.Full) --------------------------

  /// Sends a command whose data is encrypted (CommMode.Full) and MAC'd. The
  /// caller checks the returned status word ([_ensureStatus]); the response MAC
  /// is not verified (none of our commands return data we depend on, and the
  /// status word already reports success/failure). [header] is the plaintext
  /// command header (e.g. file/key number); [data] is the plaintext payload.
  Future<Uint8List> _transceiveFull(int cmd, List<int> header, Uint8List data) async {
    final enc = _sesEnc!, mac = _sesMac!, ti = _ti!;
    // CmdCtr is incremented BEFORE each secured command is processed (NTAG424
    // datasheet); both PICC and PCD do this, so the first secured command after
    // AuthenticateEV2First uses 1 (not 0). The same value is used for the IV and
    // the command MAC.
    _cmdCtr++;
    final ctr = _ctrLe();

    // IVc = E(KSesEnc, A5 5A || TI || CmdCtr || 0^8)
    final ivInput = Uint8List.fromList([0xA5, 0x5A, ...ti, ...ctr, 0,0,0,0,0,0,0,0]);
    final iv = _aesEcbEncryptBlock(enc, ivInput);
    final encData = _aesCbcEncrypt(enc, iv, _pad(data));

    // MAC over: Cmd || CmdCtr || TI || Header || EncData
    final macInput = Uint8List.fromList([cmd, ...ctr, ...ti, ...header, ...encData]);
    final mact = _truncateMac(_aesCmac(mac, macInput));

    final apdu = _wrap(cmd, header, Uint8List.fromList([...encData, ...mact]));
    _log('full cmd=0x${cmd.toRadixString(16)} ctr=$_cmdCtr hdr', Uint8List.fromList(header));
    _log('  plain', data);
    _log('  iv', iv);
    _log('  encData', encData);
    _log('  macInput', macInput);
    _log('  mact', mact);
    _log('  TX', apdu);
    final resp = await _transceive(apdu);
    _log('  RX', resp);
    return resp;
  }

  // ---- APDU framing helpers ------------------------------------------------

  /// Wraps a native command in an ISO 7816 APDU: 90 [cmd] 00 00 Lc [header+data] 00.
  Uint8List _wrap(int cmd, List<int> header, Uint8List data) {
    final payload = <int>[...header, ...data];
    final apdu = <int>[0x90, cmd, 0x00, 0x00, payload.length, ...payload, 0x00];
    return Uint8List.fromList(apdu);
  }

  static bool _isSuccess(Uint8List r) => _sw(r) == 0x9100;
  static bool _isAdditionalFrame(Uint8List r) => _sw(r) == 0x91AF;
  // ISO 7816-4 commands (e.g. SelectFile) report success as 0x9000.
  static bool _isIsoSuccess(Uint8List r) => _sw(r) == 0x9000 || _sw(r) == 0x9100;
  static int _sw(Uint8List r) =>
      r.length < 2 ? -1 : (r[r.length - 2] << 8) | r[r.length - 1];
  static Uint8List _body(Uint8List r) => r.sublist(0, r.length - 2);

  static void _ensureStatus(Uint8List r, String what) {
    if (!_isSuccess(r)) _failStatus(r, what);
  }

  static void _ensureIsoStatus(Uint8List r, String what) {
    if (!_isIsoSuccess(r)) _failStatus(r, what);
  }

  static void _failStatus(Uint8List r, String what) {
    final sw = _sw(r);
    throw Ntag424Exception(
      'Card error on $what (SW=0x${sw.toRadixString(16).padLeft(4, '0')})',
    );
  }

  Uint8List _ctrLe() => Uint8List.fromList([_cmdCtr & 0xFF, (_cmdCtr >> 8) & 0xFF]);

  // ---- NDEF file construction ----------------------------------------------

  /// Builds the NTAG424 NDEF file contents for [uri]: a 2-byte big-endian
  /// length prefix followed by a single NDEF URI record (no URI prefix code).
  static Uint8List _buildNdefFile(String uri) {
    final uriBytes = uri.codeUnits; // ASCII
    final payloadLen = uriBytes.length + 1; // +1 for the prefix byte (0x00)
    final message = <int>[
      0xD1, // MB|ME|SR, TNF=well-known
      0x01, // type length
      payloadLen, // payload length (short record)
      0x55, // 'U' (URI record)
      0x00, // URI prefix: none
      ...uriBytes,
    ];
    final nlen = message.length;
    return Uint8List.fromList([(nlen >> 8) & 0xFF, nlen & 0xFF, ...message]);
  }

  /// File offset of the first byte of the value following [marker] (e.g. the
  /// 32 zero hex chars after `p=`). Throws if the marker is absent.
  static int _valueOffset(Uint8List file, String marker) {
    final m = marker.codeUnits;
    for (var i = 0; i + m.length <= file.length; i++) {
      var hit = true;
      for (var j = 0; j < m.length; j++) {
        if (file[i + j] != m[j]) {
          hit = false;
          break;
        }
      }
      if (hit) return i + m.length;
    }
    throw Ntag424Exception('Template is missing "$marker"');
  }

  // ---- crypto + byte utilities ---------------------------------------------

  static Uint8List _pad(Uint8List data) {
    // DESFire / ISO 9797-1 padding method 2: append 0x80 then 0x00s to the
    // next 16-byte boundary (always at least one pad byte block-aligned here).
    final padLen = 16 - (data.length % 16);
    final out = Uint8List(data.length + padLen);
    out.setRange(0, data.length, data);
    out[data.length] = 0x80;
    return out;
  }

  static Uint8List _truncateMac(Uint8List fullMac) {
    // Truncated MAC = the 8 odd-indexed bytes (1,3,5,...,15) of the CMAC.
    final out = Uint8List(8);
    for (var i = 0; i < 8; i++) {
      out[i] = fullMac[2 * i + 1];
    }
    return out;
  }

  static Uint8List _aesCmac(Uint8List key, Uint8List data) {
    final cmac = CMac(AESEngine(), 128)..init(KeyParameter(key));
    final out = Uint8List(16);
    cmac.update(data, 0, data.length);
    cmac.doFinal(out, 0);
    return out;
  }

  static Uint8List _aesEcbEncryptBlock(Uint8List key, Uint8List block) {
    final c = AESEngine()..init(true, KeyParameter(key));
    final out = Uint8List(16);
    c.processBlock(block, 0, out, 0);
    return out;
  }

  static Uint8List _aesCbcEncrypt(Uint8List key, Uint8List iv, Uint8List data) {
    final c = CBCBlockCipher(AESEngine())
      ..init(true, ParametersWithIV(KeyParameter(key), iv));
    return _processBlocks(c, data);
  }

  static Uint8List _aesCbcDecrypt(Uint8List key, Uint8List iv, Uint8List data) {
    final c = CBCBlockCipher(AESEngine())
      ..init(false, ParametersWithIV(KeyParameter(key), iv));
    return _processBlocks(c, data);
  }

  static Uint8List _processBlocks(BlockCipher c, Uint8List data) {
    final out = Uint8List(data.length);
    for (var off = 0; off < data.length; off += c.blockSize) {
      c.processBlock(data, off, out, off);
    }
    return out;
  }

  /// DESFire CRC32 (JAMCRC): reflected, poly 0xEDB88320, init 0xFFFFFFFF, no
  /// final inversion. Returned little-endian (4 bytes).
  static Uint8List _crc32Le(Uint8List data) {
    var crc = 0xFFFFFFFF;
    for (final b in data) {
      crc ^= b;
      for (var i = 0; i < 8; i++) {
        if ((crc & 1) != 0) {
          crc = (crc >> 1) ^ 0xEDB88320;
        } else {
          crc >>= 1;
        }
      }
    }
    crc &= 0xFFFFFFFF;
    return Uint8List.fromList([
      crc & 0xFF,
      (crc >> 8) & 0xFF,
      (crc >> 16) & 0xFF,
      (crc >> 24) & 0xFF,
    ]);
  }

  static Uint8List _xor(List<int> a, List<int> b) {
    final out = Uint8List(a.length);
    for (var i = 0; i < a.length; i++) {
      out[i] = a[i] ^ b[i];
    }
    return out;
  }

  static Uint8List _rotateLeft(Uint8List b) =>
      Uint8List.fromList([...b.sublist(1), b[0]]);

  static bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static List<int> _int3le(int v) => [v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF];

  // ---- test hooks (exposed for unit tests; not part of the public flow) ----

  /// Derives `(SesAuthMACKey, SesAuthENCKey)` from a card key and the two
  /// randoms, per AN12196 §6.6.2. Exposed so tests can check it against the
  /// application-note worked example.
  static (Uint8List, Uint8List) sessionKeysForTest(
    Uint8List key,
    Uint8List rndA,
    Uint8List rndB,
  ) =>
      (
        _aesCmac(key, _sessionVector(0xA5, 0x5A, rndA, rndB)),
        _aesCmac(key, _sessionVector(0x5A, 0xA5, rndA, rndB)),
      );

  static Uint8List cmacForTest(Uint8List key, Uint8List data) =>
      _aesCmac(key, data);
  static Uint8List crc32ForTest(Uint8List data) => _crc32Le(data);
  static Uint8List truncateMacForTest(Uint8List mac) => _truncateMac(mac);
  static Uint8List ndefFileForTest(String uri) => _buildNdefFile(uri);
  /// AES-CBC decrypt with a zero IV (as used to decrypt the AuthenticateEV2First
  /// part-2 response). Exposed so a test can validate a real card's auth trace.
  static Uint8List aesCbcDecryptZeroIvForTest(Uint8List key, Uint8List data) =>
      _aesCbcDecrypt(key, Uint8List(16), data);
  static Uint8List rotateLeftForTest(Uint8List b) => _rotateLeft(b);
  static int valueOffsetForTest(Uint8List file, String marker) =>
      _valueOffset(file, marker);

  static final Random _rng = Random.secure();

  static Uint8List _randomBytes(int n) =>
      Uint8List.fromList(List<int>.generate(n, (_) => _rng.nextInt(256)));
}

Uint8List _hexToBytes(String hex) {
  final clean = hex.trim();
  final out = Uint8List(clean.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = int.parse(clean.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return out;
}
