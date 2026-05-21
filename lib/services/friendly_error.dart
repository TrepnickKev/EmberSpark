import '../l10n/app_localizations.dart';

/// Maps a thrown exception to a short user-readable message. Tries to
/// recognise the most common failure modes (TLS, network, common HTTP
/// statuses) and falls back to a cleaned-up version of the original text.
String friendlyError(AppLocalizations l10n, Object e) {
  final s = e.toString();

  // --- TLS / certificate issues -----------------------------------------
  if (s.contains('CERTIFICATE_VERIFY_FAILED') ||
      s.contains('unable to get local issuer certificate')) {
    return l10n.errorTlsCertificate;
  }
  if (s.contains('HandshakeException') ||
      s.contains('HANDSHAKE_FAILURE') ||
      s.contains('SSLV3_ALERT')) {
    return l10n.errorTlsHandshake;
  }

  // --- Network issues ---------------------------------------------------
  if (s.contains('Failed host lookup')) {
    return l10n.errorHostLookup;
  }
  if (s.contains('Connection refused')) {
    return l10n.errorConnectionRefused;
  }
  if (s.contains('Connection closed') || s.contains('Connection reset')) {
    return l10n.errorConnectionDropped;
  }
  if (s.contains('Network is unreachable') ||
      s.contains('No address associated with hostname')) {
    return l10n.errorNetworkUnreachable;
  }
  if (s.contains('SocketException')) {
    return l10n.errorSocket;
  }
  if (s.contains('TimeoutException') ||
      s.contains('Operation timed out') ||
      s.contains('timed out')) {
    return l10n.errorTimeout;
  }

  // --- Insufficient funds (LNbits 400 / 520 body usually contains one of
  //     these substrings when the wallet balance is too low for the pay) --
  final lower = s.toLowerCase();
  if (lower.contains('insufficient') ||
      lower.contains('not enough') ||
      (lower.contains('balance') && lower.contains('payment'))) {
    return l10n.errorInsufficientFunds;
  }

  // --- LNbits behind a reverse proxy emitting http:// callback URLs that
  //     its own Pydantic validator then rejects. Server-side misconfig;
  //     surface a diagnostic instead of the raw JSON blob.
  if (lower.contains('http scheme is only allowed for localhost') ||
      lower.contains('parsingmodel[callbackurl]')) {
    return l10n.errorLnurlInsecureCallback;
  }

  // --- HTTP status codes (we wrap them like "LNbits 4xx: ..." or
  //     "Payment failed (4xx): ..." in the service layer) ------------------
  final code = RegExp(r'\b(401|403|404|5\d\d)\b').firstMatch(s);
  if (code != null) {
    return switch (code.group(1)!) {
      '401' => l10n.error401,
      '403' => l10n.error403,
      '404' => l10n.error404,
      '500' => l10n.error500,
      '502' => l10n.error502,
      '503' => l10n.error503,
      '520' => l10n.error520,
      _ => l10n.errorServerGeneric(code.group(1)!),
    };
  }

  // --- Fallback ---------------------------------------------------------
  return s
      .replaceFirst(RegExp(r'^Exception:\s*'), '')
      .replaceFirst(RegExp(r'^FormatException:\s*'), '');
}
