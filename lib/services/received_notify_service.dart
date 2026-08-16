import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
const _taskUniqueName = 'emberspark-balance-poll';
const _channelId = 'received_payments';

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

bool get _isAndroid =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Registers the WorkManager callback. Called once from main(). No-op off
/// Android (workmanager has no desktop support).
Future<void> initReceivedNotify() async {
  if (!_isAndroid) return;
  await Workmanager().initialize(receivedNotifyDispatcher);
}

/// Schedules the periodic poll. `keep` so re-registering on each launch does
/// not reset the 15-minute timer.
Future<void> enableReceivedNotifyTask() async {
  if (!_isAndroid) return;
  await Workmanager().registerPeriodicTask(
    _taskUniqueName,
    _taskUniqueName,
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    constraints: Constraints(networkType: NetworkType.connected),
  );
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
    } catch (_) {
      // Never fail the Worker on our own errors — just try again next cycle.
    }
    return true;
  });
}

/// The background work body. Runs in a separate isolate with no app state, so
/// everything is read from secure storage. Polls each wallet, notifies on an
/// increase, and advances that wallet's notified-balance baseline.
Future<void> runReceivedNotifyPoll() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!await isReceivedNotifyEnabled()) return;

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_notify'),
    ),
  );

  final l10n = await _isolateL10n();
  final wallets = await listWallets();
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
        if (d.notify) {
          await _showReceived(plugin, l10n, w, balance - baseline!);
        }
        if (d.baseline != baseline) {
          await setLastNotifiedBalanceFor(w.id, d.baseline);
        }
      } catch (_) {
        // Per-wallet failure (unreachable server, timeout): skip and keep the
        // others going; the baseline is left untouched so it retries next time.
      }
    }
  } finally {
    client.close();
  }
}

Future<void> _showReceived(
  FlutterLocalNotificationsPlugin plugin,
  AppLocalizations l10n,
  WalletAccount w,
  int deltaSats,
) async {
  final details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      l10n.notifyChannelName,
      channelDescription: l10n.notifyChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_stat_notify',
    ),
  );
  await plugin.show(
    // Stable per-wallet id so a later notification for the same wallet replaces
    // the previous one rather than stacking.
    w.id.hashCode,
    l10n.notifyReceivedTitle,
    l10n.notifyReceivedBody(w.label, formatThousands(deltaSats)),
    details,
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
