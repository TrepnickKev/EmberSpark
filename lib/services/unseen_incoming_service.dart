import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'wallet_account_service.dart';

/// Tracks whether a wallet has received a payment the user has not yet looked
/// at, so Home can show a badge on the history button. Detection is a
/// per-wallet "acknowledged balance" baseline persisted in secure storage:
/// the badge is shown whenever the current balance sits above the baseline.
/// The baseline ratchets DOWN on spends (so a send can never mask a later
/// receive) and is reset UP to the current balance when the user opens the
/// history screen. This is what lets a payment received while the app was
/// closed be flagged on the next launch — the in-memory balance is null then.

/// Result of [evaluateUnseen]: the baseline to persist and whether the badge
/// should be shown.
typedef UnseenEval = ({int baseline, bool unseen});

/// Pure decision for the badge, given the freshly fetched [balance] and the
/// stored [baseline] (null on first observation for this wallet). Kept free of
/// storage/UI so it can be unit-tested directly.
UnseenEval evaluateUnseen(int balance, int? baseline) {
  if (baseline == null) return (baseline: balance, unseen: false);
  if (balance < baseline) return (baseline: balance, unseen: false);
  return (baseline: baseline, unseen: balance > baseline);
}

Future<int?> getLastSeenBalanceFor(String walletId) async {
  const storage = FlutterSecureStorage();
  final v = await storage.read(key: lastSeenBalanceKey(walletId));
  return v == null ? null : int.tryParse(v);
}

Future<void> setLastSeenBalanceFor(String walletId, int sats) async {
  const storage = FlutterSecureStorage();
  await storage.write(key: lastSeenBalanceKey(walletId), value: sats.toString());
}
