import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'EmberSpark'**
  String get appTitle;

  /// No description provided for @appLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get appLocked;

  /// No description provided for @appUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get appUnlock;

  /// No description provided for @appTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get appTryAgain;

  /// No description provided for @appSetupFirstToast.
  ///
  /// In en, this message translates to:
  /// **'Set up the wallet first'**
  String get appSetupFirstToast;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get commonScanQr;

  /// No description provided for @commonScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get commonScan;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @commonNfc.
  ///
  /// In en, this message translates to:
  /// **'NFC'**
  String get commonNfc;

  /// No description provided for @commonPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get commonPaste;

  /// No description provided for @commonImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get commonImage;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (sats)'**
  String get commonAmount;

  /// No description provided for @commonUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get commonUnknownError;

  /// No description provided for @receiveShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Lightning invoice'**
  String get receiveShareSubject;

  /// No description provided for @nfcHoldTag.
  ///
  /// In en, this message translates to:
  /// **'Hold an NFC tag near the phone…'**
  String get nfcHoldTag;

  /// No description provided for @nfcWriteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Written to tag'**
  String get nfcWriteSuccess;

  /// No description provided for @nfcWriteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t write to tag'**
  String get nfcWriteFailed;

  /// No description provided for @nfcReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read tag'**
  String get nfcReadFailed;

  /// No description provided for @nfcUnavailable.
  ///
  /// In en, this message translates to:
  /// **'NFC unavailable on this device'**
  String get nfcUnavailable;

  /// No description provided for @imageNoQr.
  ///
  /// In en, this message translates to:
  /// **'No QR code found in the image'**
  String get imageNoQr;

  /// No description provided for @clipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Clipboard is empty'**
  String get clipboardEmpty;

  /// No description provided for @homeScan.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get homeScan;

  /// No description provided for @homeSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get homeSend;

  /// No description provided for @homeReceive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get homeReceive;

  /// No description provided for @homeContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get homeContacts;

  /// No description provided for @homeSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettings;

  /// No description provided for @homeLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get homeLogout;

  /// No description provided for @homeMyContact.
  ///
  /// In en, this message translates to:
  /// **'My contact'**
  String get homeMyContact;

  /// No description provided for @homeBoltCard.
  ///
  /// In en, this message translates to:
  /// **'Bolt Card'**
  String get homeBoltCard;

  /// No description provided for @homeSatsReceived.
  ///
  /// In en, this message translates to:
  /// **'Received {amount} sats'**
  String homeSatsReceived(String amount);

  /// No description provided for @homeSatsSent.
  ///
  /// In en, this message translates to:
  /// **'Sent {amount} sats'**
  String homeSatsSent(String amount);

  /// No description provided for @homeSatsUnit.
  ///
  /// In en, this message translates to:
  /// **'sats'**
  String get homeSatsUnit;

  /// No description provided for @boltCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Bolt Cards'**
  String get boltCardTitle;

  /// No description provided for @boltCardExtensionMissing.
  ///
  /// In en, this message translates to:
  /// **'The Boltcards extension is not installed on this server.'**
  String get boltCardExtensionMissing;

  /// No description provided for @boltCardNone.
  ///
  /// In en, this message translates to:
  /// **'No Bolt Cards yet. Tap Add to set one up.'**
  String get boltCardNone;

  /// No description provided for @boltCardAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Bolt Card'**
  String get boltCardAdd;

  /// No description provided for @boltCardEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get boltCardEdit;

  /// No description provided for @boltCardName.
  ///
  /// In en, this message translates to:
  /// **'Card name'**
  String get boltCardName;

  /// No description provided for @boltCardTxLimit.
  ///
  /// In en, this message translates to:
  /// **'Per-tap limit (sats)'**
  String get boltCardTxLimit;

  /// No description provided for @boltCardDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily limit (sats)'**
  String get boltCardDailyLimit;

  /// No description provided for @boltCardCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get boltCardCreate;

  /// No description provided for @boltCardSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get boltCardSave;

  /// No description provided for @boltCardProgram.
  ///
  /// In en, this message translates to:
  /// **'Program card'**
  String get boltCardProgram;

  /// No description provided for @boltCardVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get boltCardVerify;

  /// No description provided for @boltCardWipe.
  ///
  /// In en, this message translates to:
  /// **'Wipe'**
  String get boltCardWipe;

  /// No description provided for @boltCardDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get boltCardDelete;

  /// No description provided for @boltCardEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get boltCardEnable;

  /// No description provided for @boltCardDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get boltCardDisable;

  /// No description provided for @boltCardEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get boltCardEnabled;

  /// No description provided for @boltCardDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get boltCardDisabled;

  /// No description provided for @boltCardCounter.
  ///
  /// In en, this message translates to:
  /// **'{count} taps'**
  String boltCardCounter(int count);

  /// No description provided for @boltCardLimits.
  ///
  /// In en, this message translates to:
  /// **'Per tap {tx} sats, daily {daily} sats'**
  String boltCardLimits(int tx, int daily);

  /// No description provided for @boltCardHoldToProgram.
  ///
  /// In en, this message translates to:
  /// **'Hold your card to the phone to program it. Do not remove it until done.'**
  String get boltCardHoldToProgram;

  /// No description provided for @boltCardHoldToVerify.
  ///
  /// In en, this message translates to:
  /// **'Hold your card to the phone to read it.'**
  String get boltCardHoldToVerify;

  /// No description provided for @boltCardHoldToWipe.
  ///
  /// In en, this message translates to:
  /// **'Hold your card to the phone to reset it. Do not remove it until done.'**
  String get boltCardHoldToWipe;

  /// No description provided for @boltCardProgrammed.
  ///
  /// In en, this message translates to:
  /// **'Card programmed.'**
  String get boltCardProgrammed;

  /// No description provided for @boltCardProgramFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not program the card.'**
  String get boltCardProgramFailed;

  /// No description provided for @boltCardNotBlank.
  ///
  /// In en, this message translates to:
  /// **'This card is already programmed. Wipe it first.'**
  String get boltCardNotBlank;

  /// No description provided for @boltCardUidAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'A Bolt Card with this UID is already registered on the server. Delete the existing card entry and try again.'**
  String get boltCardUidAlreadyRegistered;

  /// No description provided for @boltCardVerifyNotProgrammed.
  ///
  /// In en, this message translates to:
  /// **'This card is not programmed yet, so there is nothing to verify.'**
  String get boltCardVerifyNotProgrammed;

  /// No description provided for @boltCardVerified.
  ///
  /// In en, this message translates to:
  /// **'Card works and points to this wallet.'**
  String get boltCardVerified;

  /// No description provided for @boltCardVerifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get boltCardVerifiedBadge;

  /// No description provided for @boltCardVerifyWrongServer.
  ///
  /// In en, this message translates to:
  /// **'This card points to a different server.'**
  String get boltCardVerifyWrongServer;

  /// No description provided for @boltCardVerifyUidMismatch.
  ///
  /// In en, this message translates to:
  /// **'This card\'s chip ID does not match the server record. Wipe the card, then add and program it again so the correct ID is stored.'**
  String get boltCardVerifyUidMismatch;

  /// No description provided for @boltCardVerifyCounterBehind.
  ///
  /// In en, this message translates to:
  /// **'This card\'s tap counter is behind the server. Re-program the card to reset it.'**
  String get boltCardVerifyCounterBehind;

  /// No description provided for @boltCardTagLost.
  ///
  /// In en, this message translates to:
  /// **'The card moved away too soon. Hold it flat against the back of the phone and keep it still until the operation finishes, then try again.'**
  String get boltCardTagLost;

  /// No description provided for @boltCardVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not verify the card.'**
  String get boltCardVerifyFailed;

  /// No description provided for @boltCardWipeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset this card to factory keys? It will stop working until you program it again.'**
  String get boltCardWipeConfirm;

  /// No description provided for @boltCardWiped.
  ///
  /// In en, this message translates to:
  /// **'Card reset to factory keys.'**
  String get boltCardWiped;

  /// No description provided for @boltCardWipeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not reset the card.'**
  String get boltCardWipeFailed;

  /// No description provided for @boltCardDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this card from the server?'**
  String get boltCardDeleteConfirm;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup wallet'**
  String get loginTitle;

  /// No description provided for @loginUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'LNbits URL'**
  String get loginUrlLabel;

  /// No description provided for @loginUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://your.node'**
  String get loginUrlHint;

  /// No description provided for @loginAdminKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin API key'**
  String get loginAdminKeyLabel;

  /// No description provided for @loginAdminKeyHelper.
  ///
  /// In en, this message translates to:
  /// **'Full-access key — used for all operations'**
  String get loginAdminKeyHelper;

  /// No description provided for @loginAdminKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'Admin key is required'**
  String get loginAdminKeyRequired;

  /// No description provided for @loginScanUrlTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan LNbits URL'**
  String get loginScanUrlTitle;

  /// No description provided for @loginScanAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan admin key'**
  String get loginScanAdminTitle;

  /// No description provided for @loginHint.
  ///
  /// In en, this message translates to:
  /// **'Find the QR code in LNbits → wallet → \"API info\" → Admin key.'**
  String get loginHint;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Who is EmberSpark for?'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'EmberSpark is a client for self-hosted LNbits Lightning wallets. It is for people who run their own LNbits server, or who were given wallet access by someone who does. If that is not you, this app is not suitable for you.'**
  String get disclaimerBody;

  /// No description provided for @disclaimerAck.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get disclaimerAck;

  /// No description provided for @sendTitle.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendTitle;

  /// No description provided for @sendBolt11Label.
  ///
  /// In en, this message translates to:
  /// **'BOLT11 invoice'**
  String get sendBolt11Label;

  /// No description provided for @sendPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get sendPay;

  /// No description provided for @sendPaymentSent.
  ///
  /// In en, this message translates to:
  /// **'Payment sent'**
  String get sendPaymentSent;

  /// No description provided for @sendPasteFirst.
  ///
  /// In en, this message translates to:
  /// **'Paste an invoice first'**
  String get sendPasteFirst;

  /// No description provided for @sendAnyAmount.
  ///
  /// In en, this message translates to:
  /// **'Any amount'**
  String get sendAnyAmount;

  /// No description provided for @sendAmountWithSats.
  ///
  /// In en, this message translates to:
  /// **'{amount} sats'**
  String sendAmountWithSats(String amount);

  /// No description provided for @sendToTitle.
  ///
  /// In en, this message translates to:
  /// **'Send to…'**
  String get sendToTitle;

  /// No description provided for @sendToInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Address or payment data'**
  String get sendToInputLabel;

  /// No description provided for @sendToInputHint.
  ///
  /// In en, this message translates to:
  /// **'BOLT11, LNURL, or user@host'**
  String get sendToInputHint;

  /// No description provided for @sendToScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan to send'**
  String get sendToScanTitle;

  /// No description provided for @sendToContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get sendToContacts;

  /// No description provided for @sendToNoContacts.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet'**
  String get sendToNoContacts;

  /// No description provided for @contactsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Filter contacts'**
  String get contactsSearchHint;

  /// No description provided for @contactsNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matching contacts'**
  String get contactsNoMatches;

  /// No description provided for @receiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receiveTitle;

  /// No description provided for @receiveReusableAddress.
  ///
  /// In en, this message translates to:
  /// **'Your reusable address'**
  String get receiveReusableAddress;

  /// No description provided for @receiveAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get receiveAmount;

  /// No description provided for @receiveMemo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get receiveMemo;

  /// No description provided for @receiveCreateInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create invoice'**
  String get receiveCreateInvoice;

  /// No description provided for @receiveInvoiceCopied.
  ///
  /// In en, this message translates to:
  /// **'Invoice copied'**
  String get receiveInvoiceCopied;

  /// No description provided for @receiveAmountError.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive amount'**
  String get receiveAmountError;

  /// No description provided for @receiveSatsApprox.
  ///
  /// In en, this message translates to:
  /// **'≈ {amount} sats'**
  String receiveSatsApprox(String amount);

  /// No description provided for @receiveRatesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Live rates unavailable — sats only'**
  String get receiveRatesUnavailable;

  /// No description provided for @receiveCurrencySats.
  ///
  /// In en, this message translates to:
  /// **'sats'**
  String get receiveCurrencySats;

  /// No description provided for @contactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contactsTitle;

  /// No description provided for @contactsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet — tap + to add one'**
  String get contactsEmpty;

  /// No description provided for @contactsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String contactsDeleteTitle(String name);

  /// No description provided for @contactsNew.
  ///
  /// In en, this message translates to:
  /// **'New contact'**
  String get contactsNew;

  /// No description provided for @contactsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit contact'**
  String get contactsEdit;

  /// No description provided for @contactsScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan destination'**
  String get contactsScanTitle;

  /// No description provided for @contactsName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get contactsName;

  /// No description provided for @contactsDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Lightning address, LNURL, or BOLT11'**
  String get contactsDestinationLabel;

  /// No description provided for @contactsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name and destination are required'**
  String get contactsRequired;

  /// No description provided for @contactsInvalidDestination.
  ///
  /// In en, this message translates to:
  /// **'Not a valid Lightning destination. Use a Lightning address (user@host.tld), BOLT11 invoice, BOLT12 offer/invoice (lno1…/lni1…), or LNURL.'**
  String get contactsInvalidDestination;

  /// No description provided for @contactsImport.
  ///
  /// In en, this message translates to:
  /// **'Import contacts'**
  String get contactsImport;

  /// No description provided for @contactsExport.
  ///
  /// In en, this message translates to:
  /// **'Export contacts'**
  String get contactsExport;

  /// No description provided for @contactsExportEmpty.
  ///
  /// In en, this message translates to:
  /// **'No contacts to export'**
  String get contactsExportEmpty;

  /// No description provided for @contactsShareSubject.
  ///
  /// In en, this message translates to:
  /// **'EmberSpark contacts'**
  String get contactsShareSubject;

  /// No description provided for @contactsImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read that contacts file'**
  String get contactsImportFailed;

  /// Snackbar after a contacts import; count is how many new contacts were added.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} contacts'**
  String contactsImported(int count);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get historyEmpty;

  /// No description provided for @historyPaymentDefault.
  ///
  /// In en, this message translates to:
  /// **'Lightning payment'**
  String get historyPaymentDefault;

  /// No description provided for @historyPending.
  ///
  /// In en, this message translates to:
  /// **'pending'**
  String get historyPending;

  /// No description provided for @historyFee.
  ///
  /// In en, this message translates to:
  /// **'fee {amount}'**
  String historyFee(String amount);

  /// No description provided for @historyDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get historyDetailsTitle;

  /// No description provided for @historyDirectionSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get historyDirectionSent;

  /// No description provided for @historyDirectionReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get historyDirectionReceived;

  /// No description provided for @historyStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get historyStatusPaid;

  /// No description provided for @historyStatusPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get historyStatusPendingLabel;

  /// No description provided for @historyAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get historyAmountLabel;

  /// No description provided for @historyFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get historyFeeLabel;

  /// No description provided for @historyMemoLabel.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get historyMemoLabel;

  /// No description provided for @historyCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get historyCommentLabel;

  /// No description provided for @historyTimestampLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get historyTimestampLabel;

  /// No description provided for @historyPaymentHashLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment hash'**
  String get historyPaymentHashLabel;

  /// No description provided for @historyInvoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get historyInvoiceLabel;

  /// No description provided for @historyClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get historyClose;

  /// No description provided for @historyJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get historyJustNow;

  /// No description provided for @historyMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String historyMinutesAgo(int minutes);

  /// No description provided for @historyHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String historyHoursAgo(int hours);

  /// No description provided for @historyDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String historyDaysAgo(int days);

  /// No description provided for @lockedLabel.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockedLabel;

  /// No description provided for @lockUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockUnlock;

  /// No description provided for @lockTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get lockTryAgain;

  /// No description provided for @lnurlTitleAuthenticate.
  ///
  /// In en, this message translates to:
  /// **'Authenticate'**
  String get lnurlTitleAuthenticate;

  /// No description provided for @lnurlTitlePay.
  ///
  /// In en, this message translates to:
  /// **'Send (LNURL)'**
  String get lnurlTitlePay;

  /// No description provided for @lnurlTitleWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Receive (LNURL)'**
  String get lnurlTitleWithdraw;

  /// No description provided for @lnurlTitleGeneric.
  ///
  /// In en, this message translates to:
  /// **'LNURL'**
  String get lnurlTitleGeneric;

  /// No description provided for @lnurlResolvedExplain.
  ///
  /// In en, this message translates to:
  /// **'Resolved URL — paste this in a browser to see if the server will respond outside the wallet:'**
  String get lnurlResolvedExplain;

  /// No description provided for @lnurlCopyUrl.
  ///
  /// In en, this message translates to:
  /// **'Copy URL'**
  String get lnurlCopyUrl;

  /// No description provided for @lnurlUrlCopied.
  ///
  /// In en, this message translates to:
  /// **'URL copied'**
  String get lnurlUrlCopied;

  /// No description provided for @lnurlAuthRegisterAt.
  ///
  /// In en, this message translates to:
  /// **'Register at {host}'**
  String lnurlAuthRegisterAt(String host);

  /// No description provided for @lnurlAuthLinkAt.
  ///
  /// In en, this message translates to:
  /// **'Link account at {host}'**
  String lnurlAuthLinkAt(String host);

  /// No description provided for @lnurlAuthAuthenticateAt.
  ///
  /// In en, this message translates to:
  /// **'Authenticate at {host}'**
  String lnurlAuthAuthenticateAt(String host);

  /// No description provided for @lnurlAuthLoginAt.
  ///
  /// In en, this message translates to:
  /// **'Log in to {host}'**
  String lnurlAuthLoginAt(String host);

  /// No description provided for @lnurlAuthExplain.
  ///
  /// In en, this message translates to:
  /// **'A unique signing key for this site will be derived from your wallet seed. The site sees only your public key — your wallet and balance stay private.'**
  String get lnurlAuthExplain;

  /// No description provided for @lnurlAuthConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get lnurlAuthConfirm;

  /// No description provided for @lnurlAuthSuccess.
  ///
  /// In en, this message translates to:
  /// **'Authenticated with {host}'**
  String lnurlAuthSuccess(String host);

  /// No description provided for @lnurlAmountRange.
  ///
  /// In en, this message translates to:
  /// **'Range: {min} – {max} sats'**
  String lnurlAmountRange(int min, int max);

  /// No description provided for @lnurlAmountOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Amount must be between {min} and {max} sats'**
  String lnurlAmountOutOfRange(int min, int max);

  /// No description provided for @lnurlAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive amount'**
  String get lnurlAmountPositive;

  /// No description provided for @lnurlGetAndPay.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get lnurlGetAndPay;

  /// No description provided for @lnurlWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get lnurlWithdraw;

  /// No description provided for @lnurlWithdrawDefaultMemo.
  ///
  /// In en, this message translates to:
  /// **'LNURL-withdraw'**
  String get lnurlWithdrawDefaultMemo;

  /// No description provided for @lnurlWithdrawing.
  ///
  /// In en, this message translates to:
  /// **'Withdrawing {amount} sats…'**
  String lnurlWithdrawing(int amount);

  /// Label for the LUD-12 comment field on the LNURL-pay screen.
  ///
  /// In en, this message translates to:
  /// **'Memo (optional)'**
  String get lnurlCommentLabel;

  /// Helper text under the LUD-12 comment field; shows the endpoint-advertised max length.
  ///
  /// In en, this message translates to:
  /// **'Max {max} characters'**
  String lnurlCommentHelp(int max);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the app language'**
  String get settingsLanguageSubtitle;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @settingsDisplayCurrency.
  ///
  /// In en, this message translates to:
  /// **'Display currency'**
  String get settingsDisplayCurrency;

  /// No description provided for @settingsDisplayCurrencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used for the fiat amount under the balance'**
  String get settingsDisplayCurrencySubtitle;

  /// No description provided for @settingsLockOnLaunch.
  ///
  /// In en, this message translates to:
  /// **'Lock app on launch'**
  String get settingsLockOnLaunch;

  /// No description provided for @settingsLockSubtitleEnabled.
  ///
  /// In en, this message translates to:
  /// **'Require biometric or device PIN/pattern to open EmberSpark.'**
  String get settingsLockSubtitleEnabled;

  /// No description provided for @settingsLockSubtitleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No screen lock is set up on this device. Configure one in system settings to enable this option.'**
  String get settingsLockSubtitleUnavailable;

  /// No description provided for @settingsLockConfirmReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm to enable app lock'**
  String get settingsLockConfirmReason;

  /// No description provided for @settingsLockNeedSetup.
  ///
  /// In en, this message translates to:
  /// **'Set up a screen lock or biometric on your phone first.'**
  String get settingsLockNeedSetup;

  /// No description provided for @settingsTrustTls.
  ///
  /// In en, this message translates to:
  /// **'Allow unverified HTTPS'**
  String get settingsTrustTls;

  /// No description provided for @settingsTrustTlsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trust self-signed and incomplete-chain certificates. Required for some hobbyist Lightning servers and .onion services. Only enable for servers you trust.'**
  String get settingsTrustTlsSubtitle;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'A lightweight Lightning wallet for LNbits'**
  String get aboutTagline;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Trepnick Solutions'**
  String get aboutCopyright;

  /// No description provided for @aboutVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersionLabel;

  /// No description provided for @aboutCheckAgain.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get aboutCheckAgain;

  /// No description provided for @aboutCheckingForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates…'**
  String get aboutCheckingForUpdates;

  /// No description provided for @aboutUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get aboutUpToDate;

  /// No description provided for @aboutUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available: v{version}'**
  String aboutUpdateAvailable(String version);

  /// No description provided for @aboutOpenRelease.
  ///
  /// In en, this message translates to:
  /// **'Open release'**
  String get aboutOpenRelease;

  /// No description provided for @aboutCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check for updates'**
  String get aboutCheckFailed;

  /// No description provided for @aboutSupportDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Support development'**
  String get aboutSupportDevelopment;

  /// No description provided for @aboutSupportBody.
  ///
  /// In en, this message translates to:
  /// **'EmberSpark is built and maintained in spare time. If it makes your sats easier to manage, consider tossing a few on-chain BTC at the address below. Every bit keeps the project alive. Thank you! Reporting bugs or feature requests on GitHub is just as welcome.'**
  String get aboutSupportBody;

  /// No description provided for @aboutDonateMethods.
  ///
  /// In en, this message translates to:
  /// **'Donate via Lightning / On-Chain'**
  String get aboutDonateMethods;

  /// No description provided for @aboutContributeOnGithub.
  ///
  /// In en, this message translates to:
  /// **'Contribute on GitHub'**
  String get aboutContributeOnGithub;

  /// No description provided for @aboutCopyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get aboutCopyAddress;

  /// No description provided for @aboutAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get aboutAddressCopied;

  /// No description provided for @aboutLicensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get aboutLicensesTitle;

  /// No description provided for @aboutLicensesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter SDK and third-party packages'**
  String get aboutLicensesSubtitle;

  /// No description provided for @errorTlsCertificate.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t verify the server\'s TLS certificate.\nIf you trust this server, enable \'Allow unverified HTTPS\' in Settings.'**
  String get errorTlsCertificate;

  /// No description provided for @errorTlsHandshake.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t establish a secure connection to the server.\nThe server may use an outdated TLS version, or its certificate is invalid.\nIf you trust the server, try \'Allow unverified HTTPS\' in Settings.'**
  String get errorTlsHandshake;

  /// No description provided for @errorHostLookup.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t resolve the LNbits hostname.\nCheck the URL and your network connection.'**
  String get errorHostLookup;

  /// No description provided for @errorConnectionRefused.
  ///
  /// In en, this message translates to:
  /// **'The LNbits server refused the connection.\nCheck the URL and that the server is running.'**
  String get errorConnectionRefused;

  /// No description provided for @errorConnectionDropped.
  ///
  /// In en, this message translates to:
  /// **'The connection to the LNbits server was dropped. Try again.'**
  String get errorConnectionDropped;

  /// No description provided for @errorNetworkUnreachable.
  ///
  /// In en, this message translates to:
  /// **'No network connection. Check Wi-Fi / mobile data.'**
  String get errorNetworkUnreachable;

  /// No description provided for @errorSocket.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the LNbits server. Check your network.'**
  String get errorSocket;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server didn\'t respond in time. Try again.'**
  String get errorTimeout;

  /// No description provided for @error401.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Check your admin / invoice API keys.'**
  String get error401;

  /// No description provided for @error403.
  ///
  /// In en, this message translates to:
  /// **'The server denied access. The voucher may already be redeemed, or your IP is blocked.'**
  String get error403;

  /// No description provided for @error404.
  ///
  /// In en, this message translates to:
  /// **'Endpoint not found. Check that the LNbits URL is correct.'**
  String get error404;

  /// No description provided for @error500.
  ///
  /// In en, this message translates to:
  /// **'LNbits server error. Check the LNbits logs.'**
  String get error500;

  /// No description provided for @error502.
  ///
  /// In en, this message translates to:
  /// **'LNbits is unreachable through its proxy.'**
  String get error502;

  /// No description provided for @error503.
  ///
  /// In en, this message translates to:
  /// **'LNbits is temporarily unavailable.'**
  String get error503;

  /// No description provided for @error520.
  ///
  /// In en, this message translates to:
  /// **'LNbits has no Lightning backend configured (VoidWallet). Connect a Lightning node in LNbits → Server → Funding.'**
  String get error520;

  /// No description provided for @errorInsufficientFunds.
  ///
  /// In en, this message translates to:
  /// **'Not enough sats in your wallet for this payment.'**
  String get errorInsufficientFunds;

  /// No description provided for @errorLnurlInsecureCallback.
  ///
  /// In en, this message translates to:
  /// **'The LNbits server returned an insecure (http://) callback URL. This usually means LNbits sits behind a reverse proxy and doesn\'t know its public HTTPS address. On the LNbits host, set LNBITS_BASE_URL=https://your-host in .env and restart. Alternatively, configure the proxy to pass X-Forwarded-Proto: https.'**
  String get errorLnurlInsecureCallback;

  /// No description provided for @errorServerGeneric.
  ///
  /// In en, this message translates to:
  /// **'Server error ({code}).'**
  String errorServerGeneric(String code);

  /// No description provided for @lnurlAuthErrorKeyInUse.
  ///
  /// In en, this message translates to:
  /// **'This authentication key is already in use for this site. Wait a moment and try again, or reload the login QR.'**
  String get lnurlAuthErrorKeyInUse;

  /// No description provided for @lnurlAuthErrorInvalidSignature.
  ///
  /// In en, this message translates to:
  /// **'The site rejected the authentication signature. Please try again.'**
  String get lnurlAuthErrorInvalidSignature;

  /// No description provided for @lnurlAuthErrorLinkingKeyMismatch.
  ///
  /// In en, this message translates to:
  /// **'The site doesn\'t recognize this authentication key. This usually means you\'ve previously authenticated with a different wallet seed.'**
  String get lnurlAuthErrorLinkingKeyMismatch;

  /// No description provided for @lnurlAuthErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'LNURL-auth failed: {reason}'**
  String lnurlAuthErrorGeneric(String reason);

  /// No description provided for @bolt12TitlePayOffer.
  ///
  /// In en, this message translates to:
  /// **'Pay BOLT12 offer'**
  String get bolt12TitlePayOffer;

  /// No description provided for @bolt12TitlePayInvoice.
  ///
  /// In en, this message translates to:
  /// **'Pay BOLT12 invoice'**
  String get bolt12TitlePayInvoice;

  /// No description provided for @bolt12AmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (sats)'**
  String get bolt12AmountLabel;

  /// No description provided for @bolt12MemoLabel.
  ///
  /// In en, this message translates to:
  /// **'Payer note (optional)'**
  String get bolt12MemoLabel;

  /// No description provided for @bolt12RawStringLabel.
  ///
  /// In en, this message translates to:
  /// **'BOLT12 string'**
  String get bolt12RawStringLabel;

  /// No description provided for @bolt12NotSupported.
  ///
  /// In en, this message translates to:
  /// **'BOLT12 isn\'t supported by this LNbits server. Your Lightning node may not understand BOLT12, or the LNbits BOLT12 extension isn\'t installed.'**
  String get bolt12NotSupported;

  /// No description provided for @myContactTitle.
  ///
  /// In en, this message translates to:
  /// **'My contact'**
  String get myContactTitle;

  /// No description provided for @myContactLnAddressSection.
  ///
  /// In en, this message translates to:
  /// **'Lightning Address'**
  String get myContactLnAddressSection;

  /// No description provided for @myContactBolt12Section.
  ///
  /// In en, this message translates to:
  /// **'BOLT12 offer'**
  String get myContactBolt12Section;

  /// No description provided for @myContactAddLnAddress.
  ///
  /// In en, this message translates to:
  /// **'Add your Lightning address'**
  String get myContactAddLnAddress;

  /// No description provided for @myContactAddBolt12.
  ///
  /// In en, this message translates to:
  /// **'Add your BOLT12 offer'**
  String get myContactAddBolt12;

  /// No description provided for @myContactLnAddressHint.
  ///
  /// In en, this message translates to:
  /// **'user@domain. If the domain is the LNbits server, EmberSpark sets it there; otherwise it is saved as is.'**
  String get myContactLnAddressHint;

  /// No description provided for @myContactBolt12Hint.
  ///
  /// In en, this message translates to:
  /// **'lno1… — paste the offer your Lightning node generated.'**
  String get myContactBolt12Hint;

  /// No description provided for @myContactInvalidLnAddress.
  ///
  /// In en, this message translates to:
  /// **'Not a valid Lightning address.'**
  String get myContactInvalidLnAddress;

  /// No description provided for @myContactInvalidBolt12.
  ///
  /// In en, this message translates to:
  /// **'Not a valid BOLT12 offer.'**
  String get myContactInvalidBolt12;

  /// No description provided for @myContactCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get myContactCopied;

  /// No description provided for @myContactShareSubject.
  ///
  /// In en, this message translates to:
  /// **'My Lightning contact'**
  String get myContactShareSubject;

  /// No description provided for @myContactRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this entry?'**
  String get myContactRemoveConfirm;

  /// No description provided for @myContactAutoGenerate.
  ///
  /// In en, this message translates to:
  /// **'Auto-generate'**
  String get myContactAutoGenerate;

  /// No description provided for @myContactLnurlpSection.
  ///
  /// In en, this message translates to:
  /// **'LNURL-pay link'**
  String get myContactLnurlpSection;

  /// No description provided for @myContactAddLnurlp.
  ///
  /// In en, this message translates to:
  /// **'Add your LNURL-pay link'**
  String get myContactAddLnurlp;

  /// No description provided for @myContactLnurlpHint.
  ///
  /// In en, this message translates to:
  /// **'lnurl1… — paste your link or auto-generate one from the LNbits server.'**
  String get myContactLnurlpHint;

  /// No description provided for @myContactInvalidLnurlp.
  ///
  /// In en, this message translates to:
  /// **'Not a valid LNURL-pay link.'**
  String get myContactInvalidLnurlp;

  /// No description provided for @myContactGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating…'**
  String get myContactGenerating;

  /// No description provided for @myContactLnurlpExtensionMissing.
  ///
  /// In en, this message translates to:
  /// **'LNbits doesn\'t have the LNURL-pay extension installed.'**
  String get myContactLnurlpExtensionMissing;

  /// No description provided for @myContactLnAddressServerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Lightning Address updated on the server.'**
  String get myContactLnAddressServerUpdated;

  /// No description provided for @myContactBolt12ExtensionMissing.
  ///
  /// In en, this message translates to:
  /// **'LNbits doesn\'t have a BOLT12 extension installed, or your Lightning node doesn\'t support BOLT12.'**
  String get myContactBolt12ExtensionMissing;

  /// No description provided for @myContactAvatarPriority.
  ///
  /// In en, this message translates to:
  /// **'Your profile avatar is generated from one of these identifiers. Tap a star to choose which one. Otherwise it uses Lightning address, then BOLT12, then LNURL.'**
  String get myContactAvatarPriority;

  /// Tooltip to pin this identifier as the default profile avatar / avatar-tap tab.
  ///
  /// In en, this message translates to:
  /// **'Set as default identity'**
  String get myContactSetDefault;

  /// Tooltip to clear the default identity, reverting to the priority order.
  ///
  /// In en, this message translates to:
  /// **'Remove as default identity'**
  String get myContactUnsetDefault;

  /// No description provided for @myContactTabLnAddress.
  ///
  /// In en, this message translates to:
  /// **'LN Address'**
  String get myContactTabLnAddress;

  /// No description provided for @myContactTabLnurlp.
  ///
  /// In en, this message translates to:
  /// **'LNURL'**
  String get myContactTabLnurlp;

  /// No description provided for @myContactTabBolt12.
  ///
  /// In en, this message translates to:
  /// **'BOLT12'**
  String get myContactTabBolt12;

  /// No description provided for @myContactLnAddressUse.
  ///
  /// In en, this message translates to:
  /// **'Easy to share with friends and family.'**
  String get myContactLnAddressUse;

  /// No description provided for @myContactLnurlpUse.
  ///
  /// In en, this message translates to:
  /// **'Less identifying bech32 string, but routes through the same server.'**
  String get myContactLnurlpUse;

  /// No description provided for @myContactBolt12Use.
  ///
  /// In en, this message translates to:
  /// **'Best privacy: payments go directly over Lightning, no domain operator in the middle.'**
  String get myContactBolt12Use;

  /// No description provided for @walletsMenu.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get walletsMenu;

  /// No description provided for @walletsTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get walletsTitle;

  /// No description provided for @walletsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No wallets yet — add your first one.'**
  String get walletsEmpty;

  /// No description provided for @walletsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add wallet'**
  String get walletsAdd;

  /// No description provided for @walletsActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get walletsActive;

  /// No description provided for @walletsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit wallet'**
  String get walletsEdit;

  /// No description provided for @walletsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove wallet'**
  String get walletsRemove;

  /// No description provided for @walletsRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this wallet from this device? Its My Contact entries will be cleared. The wallet on the server is not affected.'**
  String get walletsRemoveConfirm;

  /// No description provided for @walletsDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This wallet is already added.'**
  String get walletsDuplicate;

  /// No description provided for @walletsActiveLabelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Tap to switch wallet'**
  String get walletsActiveLabelTooltip;

  /// No description provided for @loginWalletNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet name (optional)'**
  String get loginWalletNameLabel;

  /// No description provided for @loginWalletNameHint.
  ///
  /// In en, this message translates to:
  /// **'Defaults to the server hostname'**
  String get loginWalletNameHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'pt',
    'ru',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
