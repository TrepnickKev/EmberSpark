import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

const _lockKey = 'app_lock_enabled';
final _auth = LocalAuthentication();

Future<bool> isLockEnabled() async {
  const storage = FlutterSecureStorage();
  return (await storage.read(key: _lockKey)) == '1';
}

Future<void> setLockEnabled(bool enabled) async {
  const storage = FlutterSecureStorage();
  if (enabled) {
    await storage.write(key: _lockKey, value: '1');
  } else {
    await storage.delete(key: _lockKey);
  }
}

/// Whether the device has any kind of lock screen configured (biometric,
/// PIN, pattern, or password). If false, app-launch lock can't be enabled.
Future<bool> isDeviceSecuritySupported() async {
  try {
    return await _auth.isDeviceSupported();
  } catch (_) {
    return false;
  }
}

/// Prompts the user to authenticate with biometric — falling back to the
/// device PIN/pattern/password automatically because [biometricOnly] is
/// false. Returns true on success, false on cancel/error/lockout.
Future<bool> tryAuthenticate({
  String reason = 'Unlock EmberSpark',
}) async {
  try {
    return await _auth.authenticate(
      localizedReason: reason,
      biometricOnly: false,
      persistAcrossBackgrounding: true,
    );
  } catch (_) {
    return false;
  }
}
