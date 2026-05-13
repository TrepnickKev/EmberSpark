// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EmberSpark';

  @override
  String get appLocked => 'Locked';

  @override
  String get appUnlock => 'Unlock';

  @override
  String get appTryAgain => 'Try again';

  @override
  String get appSetupFirstToast => 'Set up the wallet first';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSave => 'Save';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonScanQr => 'Scan QR';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonAmount => 'Amount (sats)';

  @override
  String get commonUnknownError => 'Unknown error';

  @override
  String get homeScan => 'Scan QR';

  @override
  String get homeSend => 'Send';

  @override
  String get homeReceive => 'Receive';

  @override
  String get homeContacts => 'Contacts';

  @override
  String get homeSettings => 'Settings';

  @override
  String get homeLogout => 'Log out';

  @override
  String homeSatsReceived(String amount) {
    return 'Received $amount sats';
  }

  @override
  String homeSatsSent(String amount) {
    return 'Sent $amount sats';
  }

  @override
  String get homeSatsUnit => 'sats';

  @override
  String get loginTitle => 'Setup wallet';

  @override
  String get loginUrlLabel => 'LNbits URL';

  @override
  String get loginUrlHint => 'https://your.node';

  @override
  String get loginAdminKeyLabel => 'Admin API key';

  @override
  String get loginAdminKeyHelper => 'Full-access key — used for all operations';

  @override
  String get loginAdminKeyRequired => 'Admin key is required';

  @override
  String get loginScanUrlTitle => 'Scan LNbits URL';

  @override
  String get loginScanAdminTitle => 'Scan admin key';

  @override
  String get loginHint =>
      'Find the QR code in LNbits → wallet → \"API info\" → Admin key.';

  @override
  String get sendTitle => 'Send';

  @override
  String get sendBolt11Label => 'BOLT11 invoice';

  @override
  String get sendPay => 'Pay';

  @override
  String get sendPaymentSent => 'Payment sent';

  @override
  String get sendPasteFirst => 'Paste an invoice first';

  @override
  String get sendAnyAmount => 'Any amount';

  @override
  String sendAmountWithSats(String amount) {
    return '$amount sats';
  }

  @override
  String get sendToTitle => 'Send to…';

  @override
  String get sendToInputLabel => 'Address or payment data';

  @override
  String get sendToInputHint => 'BOLT11, LNURL, or user@host';

  @override
  String get sendToScanTitle => 'Scan to send';

  @override
  String get sendToContacts => 'Contacts';

  @override
  String get sendToNoContacts => 'No contacts yet';

  @override
  String get receiveTitle => 'Receive';

  @override
  String get receiveAmount => 'Amount';

  @override
  String get receiveMemo => 'Memo';

  @override
  String get receiveCreateInvoice => 'Create invoice';

  @override
  String get receiveInvoiceCopied => 'Invoice copied';

  @override
  String get receiveAmountError => 'Enter a positive amount';

  @override
  String receiveSatsApprox(String amount) {
    return '≈ $amount sats';
  }

  @override
  String get receiveRatesUnavailable => 'Live rates unavailable — sats only';

  @override
  String get receiveCurrencySats => 'sats';

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get contactsEmpty => 'No contacts yet — tap + to add one';

  @override
  String contactsDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get contactsNew => 'New contact';

  @override
  String get contactsScanTitle => 'Scan destination';

  @override
  String get contactsName => 'Name';

  @override
  String get contactsDestinationLabel => 'Lightning address, LNURL, or BOLT11';

  @override
  String get contactsRequired => 'Name and destination are required';

  @override
  String get historyTitle => 'History';

  @override
  String get historyEmpty => 'No transactions yet';

  @override
  String get historyPaymentDefault => 'Lightning payment';

  @override
  String get historyPending => 'pending';

  @override
  String historyFee(String amount) {
    return 'fee $amount';
  }

  @override
  String get historyJustNow => 'just now';

  @override
  String historyMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String historyHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String historyDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get lockedLabel => 'Locked';

  @override
  String get lockUnlock => 'Unlock';

  @override
  String get lockTryAgain => 'Try again';

  @override
  String get lnurlTitleAuthenticate => 'Authenticate';

  @override
  String get lnurlTitlePay => 'Send (LNURL)';

  @override
  String get lnurlTitleWithdraw => 'Receive (LNURL)';

  @override
  String get lnurlTitleGeneric => 'LNURL';

  @override
  String get lnurlResolvedExplain =>
      'Resolved URL — paste this in a browser to see if the server will respond outside the wallet:';

  @override
  String get lnurlCopyUrl => 'Copy URL';

  @override
  String get lnurlUrlCopied => 'URL copied';

  @override
  String lnurlAuthRegisterAt(String host) {
    return 'Register at $host';
  }

  @override
  String lnurlAuthLinkAt(String host) {
    return 'Link account at $host';
  }

  @override
  String lnurlAuthAuthenticateAt(String host) {
    return 'Authenticate at $host';
  }

  @override
  String lnurlAuthLoginAt(String host) {
    return 'Log in to $host';
  }

  @override
  String get lnurlAuthExplain =>
      'A unique signing key for this site will be derived from your wallet seed. The site sees only your public key — your wallet and balance stay private.';

  @override
  String get lnurlAuthConfirm => 'Confirm';

  @override
  String lnurlAuthSuccess(String host) {
    return 'Authenticated with $host';
  }

  @override
  String lnurlAmountRange(int min, int max) {
    return 'Range: $min – $max sats';
  }

  @override
  String lnurlAmountOutOfRange(int min, int max) {
    return 'Amount must be between $min and $max sats';
  }

  @override
  String get lnurlAmountPositive => 'Enter a positive amount';

  @override
  String get lnurlGetAndPay => 'Get invoice & pay';

  @override
  String get lnurlWithdraw => 'Withdraw';

  @override
  String get lnurlWithdrawDefaultMemo => 'LNURL-withdraw';

  @override
  String lnurlWithdrawing(int amount) {
    return 'Withdrawing $amount sats…';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Choose the app language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get settingsDisplayCurrency => 'Display currency';

  @override
  String get settingsDisplayCurrencySubtitle =>
      'Used for the fiat amount under the balance';

  @override
  String get settingsLockOnLaunch => 'Lock app on launch';

  @override
  String get settingsLockSubtitleEnabled =>
      'Require biometric or device PIN/pattern to open EmberSpark.';

  @override
  String get settingsLockSubtitleUnavailable =>
      'No screen lock is set up on this device. Configure one in system settings to enable this option.';

  @override
  String get settingsLockConfirmReason => 'Confirm to enable app lock';

  @override
  String get settingsLockNeedSetup =>
      'Set up a screen lock or biometric on your phone first.';

  @override
  String get settingsTrustTls => 'Allow unverified HTTPS';

  @override
  String get settingsTrustTlsSubtitle =>
      'Trust self-signed and incomplete-chain certificates. Required for some hobbyist Lightning servers and .onion services. Only enable for servers you trust.';

  @override
  String get settingsAbout => 'About';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutTagline => 'A small Lightning wallet for LNbits';

  @override
  String get aboutCopyright => '© 2026 Trepnick Solutions';

  @override
  String get aboutVersionLabel => 'Version';

  @override
  String get aboutCheckAgain => 'Check again';

  @override
  String get aboutCheckingForUpdates => 'Checking for updates…';

  @override
  String get aboutUpToDate => 'Up to date';

  @override
  String aboutUpdateAvailable(String version) {
    return 'Update available: v$version';
  }

  @override
  String get aboutOpenRelease => 'Open release';

  @override
  String get aboutCheckFailed => 'Couldn\'t check for updates';

  @override
  String get aboutSupportDevelopment => 'Support development';

  @override
  String get aboutSupportBody =>
      'EmberSpark is built and maintained in spare time. If it makes your sats easier to manage, consider tossing a few on-chain BTC at the address below — every bit keeps the project alive. Thank you!';

  @override
  String get aboutCopyAddress => 'Copy address';

  @override
  String get aboutAddressCopied => 'Address copied';

  @override
  String get aboutLicensesTitle => 'Open-source licenses';

  @override
  String get aboutLicensesSubtitle => 'Flutter SDK and third-party packages';

  @override
  String get errorTlsCertificate =>
      'Couldn\'t verify the server\'s TLS certificate.\nIf you trust this server, enable \'Allow unverified HTTPS\' in Settings.';

  @override
  String get errorTlsHandshake =>
      'Couldn\'t establish a secure connection to the server.\nThe server may use an outdated TLS version, or its certificate is invalid.\nIf you trust the server, try \'Allow unverified HTTPS\' in Settings.';

  @override
  String get errorHostLookup =>
      'Couldn\'t resolve the LNbits hostname.\nCheck the URL and your network connection.';

  @override
  String get errorConnectionRefused =>
      'The LNbits server refused the connection.\nCheck the URL and that the server is running.';

  @override
  String get errorConnectionDropped =>
      'The connection to the LNbits server was dropped. Try again.';

  @override
  String get errorNetworkUnreachable =>
      'No network connection. Check Wi-Fi / mobile data.';

  @override
  String get errorSocket =>
      'Couldn\'t reach the LNbits server. Check your network.';

  @override
  String get errorTimeout => 'The server didn\'t respond in time. Try again.';

  @override
  String get error401 =>
      'Authentication failed. Check your admin / invoice API keys.';

  @override
  String get error403 =>
      'The server denied access. The voucher may already be redeemed, or your IP is blocked.';

  @override
  String get error404 =>
      'Endpoint not found. Check that the LNbits URL is correct.';

  @override
  String get error500 => 'LNbits server error. Check the LNbits logs.';

  @override
  String get error502 => 'LNbits is unreachable through its proxy.';

  @override
  String get error503 => 'LNbits is temporarily unavailable.';

  @override
  String get error520 =>
      'LNbits has no Lightning backend configured (VoidWallet). Connect a Lightning node in LNbits → Server → Funding.';

  @override
  String errorServerGeneric(String code) {
    return 'Server error ($code).';
  }
}
