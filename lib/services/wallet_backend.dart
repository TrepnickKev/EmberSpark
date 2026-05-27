import 'lnbits_service.dart';

export 'lnbits_service.dart' show Payment;

/// Universal Lightning wallet operations.
///
/// Today only [LNbitsService] implements this. Future backends (Nostr Wallet
/// Connect, etc.) will implement it too, and [loadWalletBackend] will return
/// the right instance based on the user's stored credentials. Backend-specific
/// features (LNURLp link creation, BOLT12 offer creation, LNbits server
/// wallet UUID for avatar seeding) stay on the concrete [LNbitsService]
/// class and are accessed directly from the screens that need them. Phase 1
/// NWC work will decide how to model those capabilities cross-backend.
abstract class WalletBackend {
  /// Current spendable balance in sats.
  Future<int> getBalanceSats();

  /// Pays a BOLT11 invoice. Returns when the backend has accepted the
  /// payment for sending; the resulting payment may still be in flight.
  Future<void> payInvoice(String bolt11);

  /// Creates an incoming BOLT11 invoice and returns the bech32 string.
  Future<String> createInvoice({
    required int amountSats,
    required String memo,
  });

  /// Lists recent payments, newest first.
  Future<List<Payment>> listPayments({int limit = 50});

  /// Whether the invoice identified by [paymentHash] (lower-case hex) has
  /// been paid. Used by the Receive screen to detect its own invoice
  /// settling. Returns false on not-found / transient errors.
  Future<bool> isInvoicePaid(String paymentHash);
}

/// Loads the appropriate backend for the currently-selected wallet account.
///
/// Today this always returns an [LNbitsService] because LNbits is the only
/// supported backend. The wrapper exists so screens depend on the abstract
/// [WalletBackend] type, keeping the eventual NWC addition a localized
/// change inside this function instead of a global refactor.
Future<WalletBackend> loadWalletBackend() async {
  return await LNbitsService.fromStorage();
}
