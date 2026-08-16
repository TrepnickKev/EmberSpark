import 'lnbits_service.dart';

/// Case-insensitive substring match of a history search [query] against a
/// [Payment]: memo, comment, payment hash, invoice, and the amount in sats
/// (the amount check is digit-only, so "1,000" or "1 000" both match 1000).
/// An empty query matches everything. Storage/UI-free so it is unit-testable.
bool paymentMatchesQuery(Payment p, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  if (p.memo.toLowerCase().contains(q)) return true;
  if (p.comment.toLowerCase().contains(q)) return true;
  if (p.paymentHash.toLowerCase().contains(q)) return true;
  if (p.bolt11.toLowerCase().contains(q)) return true;
  final digits = q.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isNotEmpty && p.amountSats.abs().toString().contains(digits)) {
    return true;
  }
  return false;
}
