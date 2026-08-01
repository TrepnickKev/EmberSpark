import 'package:flutter_test/flutter_test.dart';
import 'package:ember_spark/services/avatar_seed.dart';

void main() {
  group('walletKeyAvatarSeed', () {
    test('is deterministic for the same key (stable across reinstalls)', () {
      expect(walletKeyAvatarSeed('admin-key-abc'),
          walletKeyAvatarSeed('admin-key-abc'));
    });

    test('ignores surrounding whitespace', () {
      expect(walletKeyAvatarSeed('  admin-key-abc  '),
          walletKeyAvatarSeed('admin-key-abc'));
    });

    test('differs for different keys', () {
      expect(walletKeyAvatarSeed('key-one'),
          isNot(walletKeyAvatarSeed('key-two')));
    });
  });

  group('avatarSeedForWallet', () {
    test('prefers the LN address, normalized', () {
      final seed = avatarSeedForWallet(
        lnAddress: 'LIGHTNING:Alice@Example.com',
        bolt12: 'lno1abc',
        lnurlp: 'lnurl1xyz',
        fallbackSeed: 'fallback',
      );
      expect(seed, 'alice@example.com');
    });

    test('falls through BOLT12 then LNURL then the fallback seed', () {
      expect(
        avatarSeedForWallet(bolt12: 'lno1abc', fallbackSeed: 'fallback'),
        'lno1abc',
      );
      expect(
        avatarSeedForWallet(lnurlp: 'lnurl1xyz', fallbackSeed: 'fallback'),
        'lnurl1xyz',
      );
      expect(
        avatarSeedForWallet(fallbackSeed: 'fallback'),
        'fallback',
      );
    });

    test('empty identities fall through to the fallback seed', () {
      final seed = avatarSeedForWallet(
        lnAddress: '   ',
        bolt12: '',
        lnurlp: null,
        fallbackSeed: 'fallback',
      );
      expect(seed, 'fallback');
    });
  });
}
