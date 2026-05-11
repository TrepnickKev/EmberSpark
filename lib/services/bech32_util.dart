/// 5-bit groups (bech32 data) ↔ 8-bit bytes. Reference impl from BIP-173.
List<int> convertBits(List<int> data, int from, int to, bool pad) {
  var acc = 0;
  var bits = 0;
  final ret = <int>[];
  final maxv = (1 << to) - 1;
  final maxAcc = (1 << (from + to - 1)) - 1;
  for (final value in data) {
    if (value < 0 || (value >> from) != 0) {
      throw FormatException('Invalid value $value for $from-bit input');
    }
    acc = ((acc << from) | value) & maxAcc;
    bits += from;
    while (bits >= to) {
      bits -= to;
      ret.add((acc >> bits) & maxv);
    }
  }
  if (pad) {
    if (bits > 0) ret.add((acc << (to - bits)) & maxv);
  } else if (bits >= from || ((acc << (to - bits)) & maxv) != 0) {
    throw const FormatException('Invalid bech32 padding');
  }
  return ret;
}
