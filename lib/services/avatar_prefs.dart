import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Whether the wallet avatars use the previous `random_avatar` (multiavatar)
/// style instead of the new `animal_avatar` illustrations. `false` = new avatars.
/// A global [ValueNotifier] so every avatar site (Home, contacts, pay header,
/// withdraw chooser) switches renderer live when the Settings toggle flips.
/// Persisted to `use_legacy_avatars`; loaded once at app start.
final useLegacyAvatars = ValueNotifier<bool>(false);

const _useLegacyAvatarsKey = 'use_legacy_avatars';

Future<void> loadUseLegacyAvatars() async {
  const storage = FlutterSecureStorage();
  useLegacyAvatars.value = (await storage.read(key: _useLegacyAvatarsKey)) == '1';
}

Future<bool> getUseLegacyAvatars() async {
  const storage = FlutterSecureStorage();
  return (await storage.read(key: _useLegacyAvatarsKey)) == '1';
}

Future<void> setUseLegacyAvatars(bool enabled) async {
  const storage = FlutterSecureStorage();
  if (enabled) {
    await storage.write(key: _useLegacyAvatarsKey, value: '1');
  } else {
    await storage.delete(key: _useLegacyAvatarsKey);
  }
  useLegacyAvatars.value = enabled;
}
