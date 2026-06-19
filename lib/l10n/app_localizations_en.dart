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
  String get commonScan => 'Scan';

  @override
  String get commonShare => 'Share';

  @override
  String get commonNfc => 'NFC';

  @override
  String get commonPaste => 'Paste';

  @override
  String get commonImage => 'Image';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAmount => 'Amount (sats)';

  @override
  String get commonUnknownError => 'Unknown error';

  @override
  String get receiveShareSubject => 'Lightning invoice';

  @override
  String get nfcHoldTag => 'Hold an NFC tag near the phone…';

  @override
  String get nfcWriteSuccess => 'Written to tag';

  @override
  String get nfcWriteFailed => 'Couldn\'t write to tag';

  @override
  String get nfcReadFailed => 'Couldn\'t read tag';

  @override
  String get nfcUnavailable => 'NFC unavailable on this device';

  @override
  String get imageNoQr => 'No QR code found in the image';

  @override
  String get clipboardEmpty => 'Clipboard is empty';

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
  String get homeMyContact => 'My contact';

  @override
  String get homeBoltCard => 'Bolt Card';

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
  String get boltCardTitle => 'Bolt Cards';

  @override
  String get boltCardExtensionMissing =>
      'The Boltcards extension is not installed on this server.';

  @override
  String get boltCardNone => 'No Bolt Cards yet. Tap Add to set one up.';

  @override
  String get boltCardAdd => 'Add Bolt Card';

  @override
  String get boltCardEdit => 'Edit card';

  @override
  String get boltCardName => 'Card name';

  @override
  String get boltCardTxLimit => 'Per-tap limit (sats)';

  @override
  String get boltCardDailyLimit => 'Daily limit (sats)';

  @override
  String get boltCardCreate => 'Create';

  @override
  String get boltCardSave => 'Save';

  @override
  String get boltCardProgram => 'Program card';

  @override
  String get boltCardVerify => 'Verify';

  @override
  String get boltCardWipe => 'Wipe';

  @override
  String get boltCardDelete => 'Delete';

  @override
  String get boltCardEnable => 'Enable';

  @override
  String get boltCardDisable => 'Disable';

  @override
  String get boltCardEnabled => 'Enabled';

  @override
  String get boltCardDisabled => 'Disabled';

  @override
  String boltCardCounter(int count) {
    return '$count taps';
  }

  @override
  String boltCardLimits(int tx, int daily) {
    return 'Per tap $tx sats, daily $daily sats';
  }

  @override
  String get boltCardHoldToProgram =>
      'Hold your card to the phone to program it. Do not remove it until done.';

  @override
  String get boltCardHoldToVerify => 'Hold your card to the phone to read it.';

  @override
  String get boltCardHoldToWipe =>
      'Hold your card to the phone to reset it. Do not remove it until done.';

  @override
  String get boltCardProgrammed => 'Card programmed.';

  @override
  String get boltCardProgramFailed => 'Could not program the card.';

  @override
  String get boltCardNotBlank =>
      'This card is already programmed. Wipe it first.';

  @override
  String get boltCardUidAlreadyRegistered =>
      'A Bolt Card with this UID is already registered on the server. Delete the existing card entry and try again.';

  @override
  String get boltCardVerifyNotProgrammed =>
      'This card is not programmed yet, so there is nothing to verify.';

  @override
  String get boltCardVerified => 'Card works and points to this wallet.';

  @override
  String get boltCardVerifiedBadge => 'Verified';

  @override
  String get boltCardVerifyWrongServer =>
      'This card points to a different server.';

  @override
  String get boltCardVerifyUidMismatch =>
      'This card\'s chip ID does not match the server record. Wipe the card, then add and program it again so the correct ID is stored.';

  @override
  String get boltCardVerifyCounterBehind =>
      'This card\'s tap counter is behind the server. Re-program the card to reset it.';

  @override
  String get boltCardVerifyFailed => 'Could not verify the card.';

  @override
  String get boltCardWipeConfirm =>
      'Reset this card to factory keys? It will stop working until you program it again.';

  @override
  String get boltCardWiped => 'Card reset to factory keys.';

  @override
  String get boltCardWipeFailed => 'Could not reset the card.';

  @override
  String get boltCardDeleteConfirm => 'Delete this card from the server?';

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
  String get contactsSearchHint => 'Filter contacts';

  @override
  String get contactsNoMatches => 'No matching contacts';

  @override
  String get receiveTitle => 'Receive';

  @override
  String get receiveReusableAddress => 'Your reusable address';

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
  String get contactsEdit => 'Edit contact';

  @override
  String get contactsScanTitle => 'Scan destination';

  @override
  String get contactsName => 'Name';

  @override
  String get contactsDestinationLabel => 'Lightning address, LNURL, or BOLT11';

  @override
  String get contactsRequired => 'Name and destination are required';

  @override
  String get contactsInvalidDestination =>
      'Not a valid Lightning destination. Use a Lightning address (user@host.tld), BOLT11 invoice, BOLT12 offer/invoice (lno1…/lni1…), or LNURL.';

  @override
  String get contactsImport => 'Import contacts';

  @override
  String get contactsExport => 'Export contacts';

  @override
  String get contactsExportEmpty => 'No contacts to export';

  @override
  String get contactsShareSubject => 'EmberSpark contacts';

  @override
  String get contactsImportFailed => 'Couldn\'t read that contacts file';

  @override
  String contactsImported(int count) {
    return 'Imported $count contacts';
  }

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
  String get historyDetailsTitle => 'Transaction';

  @override
  String get historyDirectionSent => 'Sent';

  @override
  String get historyDirectionReceived => 'Received';

  @override
  String get historyStatusPaid => 'Paid';

  @override
  String get historyStatusPendingLabel => 'Pending';

  @override
  String get historyAmountLabel => 'Amount';

  @override
  String get historyFeeLabel => 'Fee';

  @override
  String get historyMemoLabel => 'Memo';

  @override
  String get historyCommentLabel => 'Comment';

  @override
  String get historyTimestampLabel => 'Time';

  @override
  String get historyPaymentHashLabel => 'Payment hash';

  @override
  String get historyInvoiceLabel => 'Invoice';

  @override
  String get historyClose => 'Close';

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
  String get lnurlGetAndPay => 'Send';

  @override
  String get lnurlWithdraw => 'Withdraw';

  @override
  String get lnurlWithdrawDefaultMemo => 'LNURL-withdraw';

  @override
  String lnurlWithdrawing(int amount) {
    return 'Withdrawing $amount sats…';
  }

  @override
  String get lnurlCommentLabel => 'Memo (optional)';

  @override
  String lnurlCommentHelp(int max) {
    return 'Max $max characters';
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
  String get aboutTagline => 'A lightweight Lightning wallet for LNbits';

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
      'EmberSpark is built and maintained in spare time. If it makes your sats easier to manage, consider tossing a few on-chain BTC at the address below. Every bit keeps the project alive. Thank you! Reporting bugs or feature requests on GitHub is just as welcome.';

  @override
  String get aboutDonateMethods => 'Donate via Lightning / On-Chain';

  @override
  String get aboutContributeOnGithub => 'Contribute on GitHub';

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
  String get errorInsufficientFunds =>
      'Not enough sats in your wallet for this payment.';

  @override
  String get errorLnurlInsecureCallback =>
      'Your LNbits server returned an insecure (http://) callback URL. This usually means LNbits sits behind a reverse proxy and doesn\'t know its public HTTPS address. On the LNbits host, set LNBITS_BASE_URL=https://your-host in .env and restart. Alternatively, configure the proxy to pass X-Forwarded-Proto: https.';

  @override
  String errorServerGeneric(String code) {
    return 'Server error ($code).';
  }

  @override
  String get lnurlAuthErrorKeyInUse =>
      'This authentication key is already in use for this site. Wait a moment and try again, or reload the login QR.';

  @override
  String get lnurlAuthErrorInvalidSignature =>
      'The site rejected the authentication signature. Please try again.';

  @override
  String get lnurlAuthErrorLinkingKeyMismatch =>
      'The site doesn\'t recognize this authentication key. This usually means you\'ve previously authenticated with a different wallet seed.';

  @override
  String lnurlAuthErrorGeneric(String reason) {
    return 'LNURL-auth failed: $reason';
  }

  @override
  String get bolt12TitlePayOffer => 'Pay BOLT12 offer';

  @override
  String get bolt12TitlePayInvoice => 'Pay BOLT12 invoice';

  @override
  String get bolt12AmountLabel => 'Amount (sats)';

  @override
  String get bolt12MemoLabel => 'Payer note (optional)';

  @override
  String get bolt12RawStringLabel => 'BOLT12 string';

  @override
  String get bolt12NotSupported =>
      'BOLT12 isn\'t supported by this LNbits server. Your Lightning node may not understand BOLT12, or the LNbits BOLT12 extension isn\'t installed.';

  @override
  String get myContactTitle => 'My contact';

  @override
  String get myContactLnAddressSection => 'Lightning Address';

  @override
  String get myContactBolt12Section => 'BOLT12 offer';

  @override
  String get myContactAddLnAddress => 'Add your Lightning address';

  @override
  String get myContactAddBolt12 => 'Add your BOLT12 offer';

  @override
  String get myContactLnAddressHint =>
      'user@your.domain — must already exist on a server you control.';

  @override
  String get myContactBolt12Hint =>
      'lno1… — paste the offer your Lightning node generated.';

  @override
  String get myContactInvalidLnAddress => 'Not a valid Lightning address.';

  @override
  String get myContactInvalidBolt12 => 'Not a valid BOLT12 offer.';

  @override
  String get myContactCopied => 'Copied';

  @override
  String get myContactShareSubject => 'My Lightning contact';

  @override
  String get myContactRemoveConfirm => 'Remove this entry?';

  @override
  String get myContactAutoGenerate => 'Auto-generate';

  @override
  String get myContactLnurlpSection => 'LNURL-pay link';

  @override
  String get myContactAddLnurlp => 'Add your LNURL-pay link';

  @override
  String get myContactLnurlpHint =>
      'lnurl1… — paste your link or auto-generate one from your LNbits server.';

  @override
  String get myContactInvalidLnurlp => 'Not a valid LNURL-pay link.';

  @override
  String get myContactGenerating => 'Generating…';

  @override
  String get myContactLnurlpExtensionMissing =>
      'LNbits doesn\'t have the LNURL-pay extension installed.';

  @override
  String get myContactBolt12ExtensionMissing =>
      'LNbits doesn\'t have a BOLT12 extension installed, or your Lightning node doesn\'t support BOLT12.';

  @override
  String get myContactAvatarPriority =>
      'Your profile avatar is generated from one of these identifiers. Tap a star to choose which one. Otherwise it uses Lightning address, then BOLT12, then LNURL.';

  @override
  String get myContactSetDefault => 'Set as default identity';

  @override
  String get myContactUnsetDefault => 'Remove as default identity';

  @override
  String get myContactTabLnAddress => 'LN Address';

  @override
  String get myContactTabLnurlp => 'LNURL';

  @override
  String get myContactTabBolt12 => 'BOLT12';

  @override
  String get myContactLnAddressUse => 'Easy to share with friends and family.';

  @override
  String get myContactLnurlpUse =>
      'Less identifying bech32 string, but routes through the same server.';

  @override
  String get myContactBolt12Use =>
      'Best privacy: payments go directly over Lightning, no domain operator in the middle.';

  @override
  String get walletsMenu => 'Wallets';

  @override
  String get walletsTitle => 'Wallets';

  @override
  String get walletsEmpty => 'No wallets yet — add your first one.';

  @override
  String get walletsAdd => 'Add wallet';

  @override
  String get walletsActive => 'Active';

  @override
  String get walletsEdit => 'Edit wallet';

  @override
  String get walletsRemove => 'Remove wallet';

  @override
  String get walletsRemoveConfirm =>
      'Remove this wallet from this device? Its My Contact entries will be cleared. The wallet on the server is not affected.';

  @override
  String get walletsDuplicate => 'This wallet is already added.';

  @override
  String get walletsActiveLabelTooltip => 'Tap to switch wallet';

  @override
  String get loginWalletNameLabel => 'Wallet name (optional)';

  @override
  String get loginWalletNameHint => 'Defaults to the server hostname';
}
