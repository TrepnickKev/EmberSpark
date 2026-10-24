import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:workmanager/workmanager.dart';

import '../l10n/app_localizations.dart';
import 'http_client_factory.dart';
import 'language_service.dart';
import 'lnbits_service.dart';
import 'price_service.dart';
import 'wallet_account_service.dart';

/// Opt-in background notifications for payments received while the app is
/// closed. A WorkManager periodic task (~15 min, Android only) polls every
/// saved wallet's LNbits balance and shows a local notification on an increase.
///
/// It compares against a per-wallet [lastNotifiedBalanceKey] baseline that is
/// DELIBERATELY separate from `last_seen_balance__` (the in-app green-dot
/// badge): the two features must not clear each other. Unlike the badge, this
/// baseline advances to the current balance right after notifying, so the same
/// receive is never reported twice.

const _notifyKey = 'notify_received';
const _notifySoundKey = 'notify_sound';
const _taskUniqueName = 'emberspark-balance-poll';
// App build the poll was last scheduled by; a new build replaces the job.
const _taskBuildKey = 'notify_task_build';
const _legacyChannelId = 'received_payments';
const _notifyIcon = 'ic_stat_notify';

/// Notification sound choices. The value is stored and also forms the channel
/// id (Android ties a channel's sound to creation time, so each choice gets its
/// own channel). 'coins' is the default; 'default' means the device sound.
const _soundCoins = 'coins';
const _soundWoosh = 'woosh';
const _soundDefault = 'default';
const _allSounds = [_soundCoins, _soundWoosh, _soundDefault];

String _channelIdFor(String sound) => 'received_payments_$sound';

AndroidNotificationSound? _rawSoundFor(String sound) => switch (sound) {
      _soundCoins => const RawResourceAndroidNotificationSound(
          'coin_received_coins_handling',
        ),
      _soundWoosh => const RawResourceAndroidNotificationSound(
          'coin_received_soft_woosh_fire',
        ),
      _ => null, // device default
    };

/// Dev-only: when true, Settings shows a "Send test notification" button so the
/// notification path (permission + channel + icon) can be verified instantly,
/// without waiting for a WorkManager cycle. Keep false for production.
const bool kNotifyDebug = false;

/// Per-wallet baseline the background poll compares against.
String lastNotifiedBalanceKey(String walletId) =>
    'last_notified_balance__$walletId';

Future<bool> isReceivedNotifyEnabled() async {
  const storage = FlutterSecureStorage();
  return (await storage.read(key: _notifyKey)) == '1';
}

Future<void> setReceivedNotifyEnabled(bool enabled) async {
  const storage = FlutterSecureStorage();
  if (enabled) {
    await storage.write(key: _notifyKey, value: '1');
  } else {
    await storage.delete(key: _notifyKey);
  }
}

/// The chosen notification sound ('coins' by default, 'woosh', or 'default').
Future<String> getNotifySound() async {
  const storage = FlutterSecureStorage();
  final v = await storage.read(key: _notifySoundKey);
  return _allSounds.contains(v) ? v! : _soundCoins;
}

Future<void> setNotifySound(String sound) async {
  const storage = FlutterSecureStorage();
  await storage.write(key: _notifySoundKey, value: sound);
}

Future<int?> getLastNotifiedBalanceFor(String walletId) async {
  const storage = FlutterSecureStorage();
  final v = await storage.read(key: lastNotifiedBalanceKey(walletId));
  return v == null ? null : int.tryParse(v);
}

Future<void> setLastNotifiedBalanceFor(String walletId, int sats) async {
  const storage = FlutterSecureStorage();
  await storage.write(
    key: lastNotifiedBalanceKey(walletId),
    value: sats.toString(),
  );
}

/// Pure decision for the background poll: given a freshly fetched [balance] and
/// the stored [baseline] (null on first observation), returns the baseline to
/// persist and whether to notify. Notifies once on an increase and advances the
/// baseline so the same receive isn't reported again; ratchets down on spends;
/// seeds silently on first observation. Storage/UI-free so it is unit-testable.
({int baseline, bool notify}) evaluateNotify(int balance, int? baseline) {
  if (baseline == null) return (baseline: balance, notify: false);
  if (balance > baseline) return (baseline: balance, notify: true);
  if (balance < baseline) return (baseline: balance, notify: false);
  return (baseline: baseline, notify: false);
}

/// Background poll log line. debugPrint also reaches logcat in release builds
/// (tag "flutter"); wallet ids only, never keys or labels.
void _log(String message) => debugPrint('ReceivedNotify: $message');

bool get _isAndroid =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Registers the WorkManager callback. Called once from main(). No-op off
/// Android (workmanager has no desktop support).
Future<void> initReceivedNotify() async {
  if (!_isAndroid) return;
  await Workmanager().initialize(receivedNotifyDispatcher);
}

/// Schedules the periodic poll. `keep` so re-registering on each launch does
/// not reset the 15-minute timer, except on the first launch of a new build:
/// then `replace`, so a job enqueued by an older workmanager version can't
/// linger after a plugin update.
Future<void> enableReceivedNotifyTask() async {
  if (!_isAndroid) return;
  const storage = FlutterSecureStorage();
  final build = (await PackageInfo.fromPlatform()).buildNumber;
  final isNewBuild = await storage.read(key: _taskBuildKey) != build;
  await Workmanager().registerPeriodicTask(
    _taskUniqueName,
    _taskUniqueName,
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: isNewBuild
        ? ExistingPeriodicWorkPolicy.replace
        : ExistingPeriodicWorkPolicy.keep,
    constraints: Constraints(networkType: NetworkType.connected),
  );
  if (isNewBuild) {
    _log('build $build: rescheduled the poll');
    await storage.write(key: _taskBuildKey, value: build);
  }
}

Future<void> disableReceivedNotifyTask() async {
  if (!_isAndroid) return;
  await Workmanager().cancelByUniqueName(_taskUniqueName);
}

/// Requests the Android 13+ POST_NOTIFICATIONS runtime permission. Returns true
/// when granted (or not needed on older Android). No-op elsewhere.
Future<bool> requestNotifyPermission() async {
  if (!_isAndroid) return true;
  final android = FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  final granted = await android?.requestNotificationsPermission();
  return granted ?? true;
}

@pragma('vm:entry-point')
void receivedNotifyDispatcher() {
  Workmanager().executeTask((_, __) async {
    try {
      await runReceivedNotifyPoll();
    } catch (e, st) {
      // Never fail the Worker on our own errors, just try again next cycle.
      // Logged so a broken poll shows up in logcat instead of failing silently.
      _log('poll failed: $e\n$st');
    }
    return true;
  });
}

/// The background work body. Runs in a separate isolate with no app state, so
/// everything is read from secure storage. Polls each wallet, notifies on an
/// increase, and advances that wallet's notified-balance baseline.
Future<void> runReceivedNotifyPoll() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!await isReceivedNotifyEnabled()) {
    _log('disabled, skipping');
    return;
  }

  final plugin = await _initPlugin();
  final l10n = await _isolateL10n();
  final sound = await _ensureSoundChannel(plugin, l10n);

  final wallets = await listWallets();
  _log('polling ${wallets.length} wallet(s)');
  if (wallets.isEmpty) return;

  final client = await getHttpClient();
  try {
    for (final w in wallets) {
      try {
        final svc = LNbitsService(
          baseUrl: w.url,
          adminKey: w.adminKey,
          readOnly: w.readOnly,
          client: client,
        );
        final balance = await svc.getBalanceSats();
        final baseline = await getLastNotifiedBalanceFor(w.id);
        final d = evaluateNotify(balance, baseline);
        _log('wallet ${w.id}: balance $balance, baseline $baseline, '
            'notify ${d.notify}');
        if (d.notify) {
          await _showReceived(plugin, l10n, w, balance - baseline!, sound);
        }
        if (d.baseline != baseline) {
          await setLastNotifiedBalanceFor(w.id, d.baseline);
        }
      } catch (e) {
        // Per-wallet failure (unreachable server, timeout): skip and keep the
        // others going; the baseline is left untouched so it retries next time.
        _log('wallet ${w.id} failed: $e');
      }
    }
  } finally {
    client.close();
  }
}

Future<FlutterLocalNotificationsPlugin> _initPlugin() async {
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings(_notifyIcon),
    ),
  );
  return plugin;
}

/// Creates the notification channel for the currently chosen sound and removes
/// the others (a channel's sound is fixed at creation on Android 8+, so each
/// choice is its own channel; keeping only one keeps system settings tidy and
/// makes a sound change actually take effect). Also drops the legacy channel
/// from earlier builds. Returns the chosen sound.
Future<String> _ensureSoundChannel(
  FlutterLocalNotificationsPlugin plugin,
  AppLocalizations l10n,
) async {
  final sound = await getNotifySound();
  final android = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  if (android == null) return sound;
  await android.deleteNotificationChannel(channelId: _legacyChannelId);
  for (final s in _allSounds) {
    if (s != sound) {
      await android.deleteNotificationChannel(channelId: _channelIdFor(s));
    }
  }
  await android.createNotificationChannel(
    AndroidNotificationChannel(
      _channelIdFor(sound),
      l10n.notifyChannelName,
      description: l10n.notifyChannelDescription,
      importance: Importance.high,
      playSound: true,
      sound: _rawSoundFor(sound),
    ),
  );
  return sound;
}

/// Applies the chosen notification sound now (recreates the channel), so a
/// dropdown change takes effect without waiting for a poll. No-op off Android.
Future<void> applyNotifySound() async {
  if (!_isAndroid) return;
  final plugin = await _initPlugin();
  final l10n = await _isolateL10n();
  await _ensureSoundChannel(plugin, l10n);
}

const _soundPreviewChannel = MethodChannel('emberspark/sound_preview');

/// Plays a short preview of [sound] (native RingtoneManager) so the user can
/// hear a choice from the settings dropdown. No-op off Android; never throws.
Future<void> previewNotifySound(String sound) async {
  if (!_isAndroid) return;
  try {
    await _soundPreviewChannel.invokeMethod('preview', {'sound': sound});
  } catch (_) {
    // A failed preview must never disrupt settings.
  }
}

NotificationDetails _details(AppLocalizations l10n, String sound) =>
    NotificationDetails(
      android: AndroidNotificationDetails(
        _channelIdFor(sound),
        l10n.notifyChannelName,
        channelDescription: l10n.notifyChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: _notifyIcon,
        playSound: true,
        sound: _rawSoundFor(sound),
      ),
    );

/// Dev-only (see [kNotifyDebug]): posts a sample notification immediately to
/// verify permission, channel, icon, and sound independent of the poll.
Future<void> showTestNotification() async {
  WidgetsFlutterBinding.ensureInitialized();
  final plugin = await _initPlugin();
  final l10n = await _isolateL10n();
  final sound = await _ensureSoundChannel(plugin, l10n);
  await plugin.show(
    id: _taskUniqueName.hashCode,
    title: l10n.notifyReceivedTitle,
    body: l10n.notifyReceivedBody('EmberSpark', formatThousands(1000)),
    notificationDetails: _details(l10n, sound),
  );
}

Future<void> _showReceived(
  FlutterLocalNotificationsPlugin plugin,
  AppLocalizations l10n,
  WalletAccount w,
  int deltaSats,
  String sound,
) async {
  await plugin.show(
    // Stable per-wallet id so a later notification for the same wallet replaces
    // the previous one rather than stacking.
    id: w.id.hashCode,
    title: l10n.notifyReceivedTitle,
    body: l10n.notifyReceivedBody(w.label, formatThousands(deltaSats)),
    notificationDetails: _details(l10n, sound),
  );
}

/// Builds an [AppLocalizations] without a BuildContext for the background
/// isolate, from the persisted language (falling back to the device locale,
/// then English) so notification text matches the user's chosen language.
Future<AppLocalizations> _isolateL10n() async {
  var code = await getSelectedLanguageCode();
  if (code == 'system') {
    code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  }
  final supported = AppLocalizations.supportedLocales
      .any((l) => l.languageCode == code);
  return lookupAppLocalizations(Locale(supported ? code : 'en'));
}
