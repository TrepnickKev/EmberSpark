import 'dart:convert';

/// A tiny deterministic pseudo-random generator seeded from a string.
///
/// The whole point of the avatar library is that the *same* seed always yields
/// the *same* avatar — on any device, after a reinstall, forever. So this is
/// the only source of "randomness" in the package: no `Math.random`, no clock.
///
/// All arithmetic is kept within 32 bits so the sequence is identical on the
/// Dart VM, AOT (mobile), and web (where ints are 53-bit doubles).
class SeededRandom {
  SeededRandom(String seed) : _state = _seedState(_fnv1a32(seed));

  int _state;

  /// FNV-1a (32-bit) hash of the seed's UTF-8 bytes.
  static int _fnv1a32(String seed) {
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode(seed)) {
      hash = (hash ^ byte) & 0xffffffff;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }

  /// xorshift32 needs a non-zero state; nudge it if the hash landed on zero.
  static int _seedState(int hash) => hash == 0 ? 0x9e3779b9 : hash;

  /// Next raw 32-bit value via xorshift32.
  int _next() {
    var x = _state;
    x = (x ^ (x << 13)) & 0xffffffff;
    x = x ^ (x >> 17);
    x = (x ^ (x << 5)) & 0xffffffff;
    _state = x;
    return x;
  }

  /// A double in [0, 1).
  double nextDouble() => _next() / 0x100000000;

  /// An int in [0, max). [max] must be > 0.
  int nextInt(int max) {
    assert(max > 0);
    return _next() % max;
  }

  bool nextBool() => (_next() & 1) == 1;

  /// A uniformly chosen element of [items]. [items] must be non-empty.
  T choice<T>(List<T> items) {
    assert(items.isNotEmpty);
    return items[nextInt(items.length)];
  }
}
