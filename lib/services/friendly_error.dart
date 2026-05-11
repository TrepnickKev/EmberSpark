/// Maps a thrown exception to a short user-readable message. Tries to
/// recognise the most common failure modes (TLS, network, common HTTP
/// statuses) and falls back to a cleaned-up version of the original text.
String friendlyError(Object e) {
  final s = e.toString();

  // --- TLS / certificate issues -----------------------------------------
  if (s.contains('CERTIFICATE_VERIFY_FAILED') ||
      s.contains('unable to get local issuer certificate')) {
    return "Couldn't verify the server's TLS certificate.\n"
        "If you trust this server, enable 'Allow unverified HTTPS' in Settings.";
  }
  if (s.contains('HandshakeException') ||
      s.contains('HANDSHAKE_FAILURE') ||
      s.contains('SSLV3_ALERT')) {
    return "Couldn't establish a secure connection to the server.\n"
        "The server may use an outdated TLS version, or its certificate is invalid.\n"
        "If you trust the server, try 'Allow unverified HTTPS' in Settings.";
  }

  // --- Network issues ---------------------------------------------------
  if (s.contains('Failed host lookup')) {
    return "Couldn't resolve the LNbits hostname.\n"
        'Check the URL and your network connection.';
  }
  if (s.contains('Connection refused')) {
    return 'The LNbits server refused the connection.\n'
        'Check the URL and that the server is running.';
  }
  if (s.contains('Connection closed') || s.contains('Connection reset')) {
    return 'The connection to the LNbits server was dropped. Try again.';
  }
  if (s.contains('Network is unreachable') ||
      s.contains('No address associated with hostname')) {
    return 'No network connection. Check Wi-Fi / mobile data.';
  }
  if (s.contains('SocketException')) {
    return "Couldn't reach the LNbits server. Check your network.";
  }
  if (s.contains('TimeoutException') ||
      s.contains('Operation timed out') ||
      s.contains('timed out')) {
    return "The server didn't respond in time. Try again.";
  }

  // --- HTTP status codes (we wrap them like "LNbits 4xx: ..." or
  //     "Payment failed (4xx): ..." in the service layer) ------------------
  final code = RegExp(r'\b(401|403|404|5\d\d)\b').firstMatch(s);
  if (code != null) {
    return switch (code.group(1)!) {
      '401' => 'Authentication failed. Check your admin / invoice API keys.',
      '403' => 'The server denied access. The voucher may already be redeemed, '
          'or your IP is blocked.',
      '404' => 'Endpoint not found. Check that the LNbits URL is correct.',
      '500' => 'LNbits server error. Check the LNbits logs.',
      '502' => 'LNbits is unreachable through its proxy.',
      '503' => 'LNbits is temporarily unavailable.',
      '520' => 'LNbits has no Lightning backend configured (VoidWallet). '
          'Connect a Lightning node in LNbits → Server → Funding.',
      _ => 'Server error (${code.group(1)}).',
    };
  }

  // --- Fallback ---------------------------------------------------------
  return s
      .replaceFirst(RegExp(r'^Exception:\s*'), '')
      .replaceFirst(RegExp(r'^FormatException:\s*'), '');
}
