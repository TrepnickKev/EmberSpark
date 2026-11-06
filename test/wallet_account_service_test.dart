import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ember_spark/services/received_notify_service.dart';
import 'package:ember_spark/services/unseen_incoming_service.dart';
import 'package:ember_spark/services/wallet_account_service.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('removeWallet drops both balance baselines of that wallet only', () async {
    final a = await addWallet(url: 'https://a.example', adminKey: 'ka');
    final b = await addWallet(url: 'https://b.example', adminKey: 'kb');
    for (final w in [a, b]) {
      await setLastSeenBalanceFor(w.id, 100);
      await setLastNotifiedBalanceFor(w.id, 100);
    }

    await removeWallet(a.id);

    expect(await getLastSeenBalanceFor(a.id), isNull);
    expect(await getLastNotifiedBalanceFor(a.id), isNull);
    expect(await getLastSeenBalanceFor(b.id), 100);
    expect(await getLastNotifiedBalanceFor(b.id), 100);
  });
}
