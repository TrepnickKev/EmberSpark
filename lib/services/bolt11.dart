import 'dart:convert';
import 'package:bech32/bech32.dart';
import 'bech32_util.dart';

/// Subset of fields decoded from a BOLT11 invoice — enough to show the user
/// what they're about to pay. We don't verify the signature; the LNbits
/// server does that on the actual payment call.
class Bolt11Decoded {
  /// Amount in satoshis. Zero for "any-amount" invoices.
  final int amountSats;

  /// Amount in millisatoshis (more precise; can be non-multiple of 1000).
  final int amountMsat;

  /// The `d` tagged field, UTF-8 decoded. Empty if the invoice carries only
  /// a description hash (`h` tag) instead of inline text.
  final String description;

  /// Lower-case hex of the payment hash (`p` tag), or empty.
  final String paymentHash;

  /// Seconds from creation until expiry. Defaults to 3600 if no `x` tag.
  final int expirySeconds;

  const Bolt11Decoded({
    required this.amountSats,
    required this.amountMsat,
    required this.description,
    required this.paymentHash,
    required this.expirySeconds,
  });
}

/// Best-effort decode. Returns null on any error so the caller can hide the
/// helper UI without surfacing parse errors to the user.
Bolt11Decoded? decodeBolt11(String invoice) {
  try {
    var s = invoice.trim().toLowerCase();
    s = s.replaceFirst(RegExp(r'^lightning:'), '');
    if (s.isEmpty) return null;

    // HRP / data separator is the last '1' (bech32 alphabet excludes '1').
    final sep = s.lastIndexOf('1');
    if (sep < 1) return null;
    final hrp = s.substring(0, sep);

    // Prefix must match a known network.
    final prefixMatch = RegExp(r'^(lnbcrt|lnbc|lntb|lnsb)').firstMatch(hrp);
    if (prefixMatch == null) return null;

    // Amount: digits (and optional multiplier suffix) after the prefix.
    final amountPart = hrp.substring(prefixMatch.end);
    final amountMsat = _parseAmountToMsat(amountPart);
    if (amountMsat == null) return null;

    // bech32 decode the whole invoice. BOLT11 invoices can be ~700 chars.
    final decoded = const Bech32Codec().decode(s, 2048);
    final data = decoded.data;

    // Layout: 7 groups timestamp | tagged fields... | 104 groups signature
    if (data.length < 7 + 104) return null;
    final taggedEnd = data.length - 104;

    var i = 7;
    var description = '';
    var paymentHash = '';
    var expiry = 3600;

    while (i + 3 <= taggedEnd) {
      final type = data[i];
      final length = (data[i + 1] << 5) | data[i + 2];
      i += 3;
      if (i + length > taggedEnd) break;
      final fieldData = data.sublist(i, i + length);
      i += length;

      switch (type) {
        case 13: // 'd' - description
          try {
            description = utf8.decode(convertBits(fieldData, 5, 8, false));
          } catch (_) {}
          break;
        case 1: // 'p' - payment hash (256 bits = 52 5-bit groups)
          if (length == 52) {
            final bytes = convertBits(fieldData, 5, 8, false);
            paymentHash = bytes
                .map((b) => b.toRadixString(16).padLeft(2, '0'))
                .join();
          }
          break;
        case 6: // 'x' - expiry (variable-length integer in 5-bit groups)
          var v = 0;
          for (final g in fieldData) {
            v = (v << 5) | g;
          }
          expiry = v;
          break;
      }
    }

    return Bolt11Decoded(
      amountSats: amountMsat ~/ 1000,
      amountMsat: amountMsat,
      description: description,
      paymentHash: paymentHash,
      expirySeconds: expiry,
    );
  } catch (_) {
    return null;
  }
}

/// `25u` → 2_500_000 msat, `1` → 100_000_000_000 msat, empty → 0 (any-amount).
int? _parseAmountToMsat(String amountPart) {
  if (amountPart.isEmpty) return 0;
  final lastChar = amountPart[amountPart.length - 1];
  final hasMult = 'munp'.contains(lastChar);
  final digits = hasMult
      ? amountPart.substring(0, amountPart.length - 1)
      : amountPart;
  final mult = hasMult ? lastChar : '';
  final n = int.tryParse(digits);
  if (n == null) return null;
  // Multiplier × 10 to keep p (= 0.1 msat per unit) integer.
  final mTimes10 = switch (mult) {
    '' => 1000000000000, // 1 BTC = 100B msat → ×10
    'm' => 1000000000,
    'u' => 1000000,
    'n' => 1000,
    'p' => 1,
    _ => 0,
  };
  if (mTimes10 == 0) return null;
  return (n * mTimes10) ~/ 10;
}
