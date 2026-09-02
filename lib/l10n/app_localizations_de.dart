// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'EmberSpark';

  @override
  String get appLocked => 'Gesperrt';

  @override
  String get appUnlock => 'Entsperren';

  @override
  String get appTryAgain => 'Erneut versuchen';

  @override
  String get appSetupFirstToast => 'Richte zuerst die Wallet ein';

  @override
  String get commonCopy => 'Kopieren';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonContinue => 'Weiter';

  @override
  String get commonScanQr => 'QR scannen';

  @override
  String get commonScan => 'Scannen';

  @override
  String get commonShare => 'Teilen';

  @override
  String get commonNfc => 'NFC';

  @override
  String get commonPaste => 'Einfügen';

  @override
  String get commonImage => 'Bild';

  @override
  String get commonRetry => 'Erneut versuchen';

  @override
  String get commonEdit => 'Bearbeiten';

  @override
  String get commonAmount => 'Betrag (Sats)';

  @override
  String get commonUnknownError => 'Unbekannter Fehler';

  @override
  String get receiveShareSubject => 'Lightning-Rechnung';

  @override
  String get nfcHoldTag => 'NFC-Tag an das Gerät halten …';

  @override
  String get nfcWriteSuccess => 'Auf Tag geschrieben';

  @override
  String get nfcWriteFailed => 'Tag konnte nicht beschrieben werden';

  @override
  String get nfcReadFailed => 'Tag konnte nicht gelesen werden';

  @override
  String get nfcUnavailable => 'NFC auf diesem Gerät nicht verfügbar';

  @override
  String get imageNoQr => 'Kein QR-Code im Bild gefunden';

  @override
  String get clipboardEmpty => 'Zwischenablage ist leer';

  @override
  String get homeScan => 'QR scannen';

  @override
  String get homeSend => 'Senden';

  @override
  String get homeReceive => 'Empfangen';

  @override
  String get homeContacts => 'Kontakte';

  @override
  String get homeSettings => 'Einstellungen';

  @override
  String get homeLogout => 'Abmelden';

  @override
  String get homeMyContact => 'Mein Kontakt';

  @override
  String get homeBoltCard => 'Bolt Card';

  @override
  String homeSatsReceived(String amount) {
    return '$amount Sats empfangen';
  }

  @override
  String homeSatsSent(String amount) {
    return '$amount Sats gesendet';
  }

  @override
  String get homeSatsUnit => 'Sats';

  @override
  String get boltCardTitle => 'Bolt Cards';

  @override
  String get boltCardExtensionMissing =>
      'Die Boltcards-Erweiterung ist auf diesem Server nicht installiert.';

  @override
  String get boltCardNone =>
      'Noch keine Bolt Cards. Tippe auf Hinzufügen, um eine einzurichten.';

  @override
  String get boltCardAdd => 'Bolt Card hinzufügen';

  @override
  String get boltCardEdit => 'Karte bearbeiten';

  @override
  String get boltCardName => 'Kartenname';

  @override
  String get boltCardTxLimit => 'Limit pro Zahlung (Sats)';

  @override
  String get boltCardDailyLimit => 'Tageslimit (Sats)';

  @override
  String get boltCardCreate => 'Erstellen';

  @override
  String get boltCardSave => 'Speichern';

  @override
  String get boltCardProgram => 'Karte beschreiben';

  @override
  String get boltCardVerify => 'Prüfen';

  @override
  String get boltCardWipe => 'Zurücksetzen';

  @override
  String get boltCardDelete => 'Löschen';

  @override
  String get boltCardEnable => 'Aktivieren';

  @override
  String get boltCardDisable => 'Deaktivieren';

  @override
  String get boltCardEnabled => 'Aktiv';

  @override
  String get boltCardDisabled => 'Inaktiv';

  @override
  String boltCardCounter(int count) {
    return '$count Zahlungen';
  }

  @override
  String boltCardLimits(int tx, int daily) {
    return 'Pro Zahlung $tx Sats, täglich $daily Sats';
  }

  @override
  String get boltCardHoldToProgram =>
      'Halte die Karte an das Telefon, um sie zu beschreiben. Nicht entfernen, bis es fertig ist.';

  @override
  String get boltCardHoldToVerify =>
      'Halte die Karte an das Telefon, um sie zu lesen.';

  @override
  String get boltCardHoldToWipe =>
      'Halte die Karte an das Telefon, um sie zurückzusetzen. Nicht entfernen, bis es fertig ist.';

  @override
  String get boltCardProgrammed => 'Karte beschrieben.';

  @override
  String get boltCardProgramFailed => 'Karte konnte nicht beschrieben werden.';

  @override
  String get boltCardNotBlank =>
      'Diese Karte ist bereits beschrieben. Setze sie zuerst zurück.';

  @override
  String get boltCardUidAlreadyRegistered =>
      'Eine Bolt Card mit dieser UID ist auf dem Server bereits registriert. Lösche den vorhandenen Karteneintrag und versuche es erneut.';

  @override
  String get boltCardVerifyNotProgrammed =>
      'Diese Karte ist noch nicht beschrieben, es gibt nichts zu prüfen.';

  @override
  String get boltCardVerified =>
      'Karte funktioniert und verweist auf diese Wallet.';

  @override
  String get boltCardVerifiedBadge => 'Verifiziert';

  @override
  String get boltCardVerifyWrongServer =>
      'Diese Karte verweist auf einen anderen Server.';

  @override
  String get boltCardVerifyUidMismatch =>
      'Die Chip-ID dieser Karte stimmt nicht mit dem Servereintrag überein. Setze die Karte zurück und füge sie neu hinzu und beschreibe sie erneut, damit die richtige ID gespeichert wird.';

  @override
  String get boltCardVerifyCounterBehind =>
      'Der Tap-Zähler dieser Karte liegt hinter dem Server. Programmiere die Karte neu, um ihn zurückzusetzen.';

  @override
  String get boltCardTagLost =>
      'Die Karte wurde zu früh entfernt. Halte sie flach an die Rückseite des Telefons und ruhig, bis der Vorgang abgeschlossen ist, und versuche es erneut.';

  @override
  String get boltCardChargeOnlyTitle => 'Bolt Card';

  @override
  String get boltCardChargeOnlyBody =>
      'Von einer Bolt Card kann nur abgebucht, nicht bezahlt werden. Möchtest du sie abbuchen?';

  @override
  String get boltCardChargeAction => 'Abbuchen';

  @override
  String get boltCardVerifyFailed => 'Karte konnte nicht geprüft werden.';

  @override
  String get boltCardWipeConfirm =>
      'Karte auf Werksschlüssel zurücksetzen? Sie funktioniert erst wieder, wenn du sie neu beschreibst.';

  @override
  String get boltCardWiped => 'Karte auf Werksschlüssel zurückgesetzt.';

  @override
  String get boltCardWipeFailed => 'Karte konnte nicht zurückgesetzt werden.';

  @override
  String get boltCardDeleteConfirm => 'Diese Karte vom Server löschen?';

  @override
  String get loginTitle => 'Wallet einrichten';

  @override
  String get loginUrlLabel => 'LNbits-URL';

  @override
  String get loginUrlHint => 'https://deine.node';

  @override
  String get loginAdminKeyLabel => 'Admin-API-Schlüssel';

  @override
  String get loginAdminKeyHelper =>
      'Admin-Schlüssel für vollen Zugriff, oder ein Invoice/Read-Schlüssel für eine schreibgeschützte Wallet';

  @override
  String get loginAdminKeyRequired => 'Admin-Schlüssel ist erforderlich';

  @override
  String get loginScanUrlTitle => 'LNbits-URL scannen';

  @override
  String get loginScanAdminTitle => 'Admin-Schlüssel scannen';

  @override
  String get loginHint =>
      'Den QR-Code findest du in LNbits → Wallet → „API info“ → Admin-Schlüssel.';

  @override
  String get disclaimerTitle => 'Für wen ist EmberSpark?';

  @override
  String get disclaimerBody =>
      'EmberSpark ist eine App für selbst gehostete LNbits Lightning Wallets. Sie ist für Personen gedacht, die einen eigenen LNbits-Server betreiben oder von jemandem mit einem LNbits-Server Zugang erhalten haben. Trifft das nicht zu, ist diese App für dich nicht geeignet.';

  @override
  String get disclaimerAck => 'Ich verstehe';

  @override
  String get sendTitle => 'Senden';

  @override
  String get sendBolt11Label => 'BOLT11-Rechnung';

  @override
  String get sendPay => 'Bezahlen';

  @override
  String get sendPaymentSent => 'Zahlung gesendet';

  @override
  String get sendPasteFirst => 'Füge zuerst eine Rechnung ein';

  @override
  String get sendAnyAmount => 'Beliebiger Betrag';

  @override
  String sendAmountWithSats(String amount) {
    return '$amount Sats';
  }

  @override
  String get sendToTitle => 'Senden an …';

  @override
  String get sendToInputLabel => 'Adresse oder Zahlungsdaten';

  @override
  String get sendToInputHint => 'BOLT11, LNURL oder user@host';

  @override
  String get sendToScanTitle => 'Zum Senden scannen';

  @override
  String get sendToContacts => 'Kontakte';

  @override
  String get sendToNoContacts => 'Noch keine Kontakte';

  @override
  String get contactsSearchHint => 'Kontakte filtern';

  @override
  String get contactsNoMatches => 'Keine passenden Kontakte';

  @override
  String get receiveTitle => 'Empfangen';

  @override
  String get receiveReusableAddress => 'Deine wiederverwendbare Adresse';

  @override
  String get receiveAmount => 'Betrag';

  @override
  String get receiveMemo => 'Notiz';

  @override
  String get receiveCreateInvoice => 'Rechnung erstellen';

  @override
  String get receiveInvoiceCopied => 'Rechnung kopiert';

  @override
  String get receiveAmountError => 'Gib einen positiven Betrag ein';

  @override
  String get receiveEnterAmountFirst => 'Zuerst einen Betrag eingeben';

  @override
  String receiveCardCharged(int sats) {
    return '$sats sats von der Karte abgebucht';
  }

  @override
  String receiveSatsApprox(String amount) {
    return '≈ $amount Sats';
  }

  @override
  String get receiveRatesUnavailable =>
      'Wechselkurs nicht verfügbar — nur Sats';

  @override
  String get receiveCurrencySats => 'Sats';

  @override
  String get contactsTitle => 'Kontakte';

  @override
  String get contactsEmpty => 'Noch keine Kontakte — tippe + zum Hinzufügen';

  @override
  String contactsDeleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get contactsNew => 'Neuer Kontakt';

  @override
  String get contactsEdit => 'Kontakt bearbeiten';

  @override
  String get contactsScanTitle => 'Ziel scannen';

  @override
  String get contactsName => 'Name';

  @override
  String get contactsDestinationLabel => 'Lightning-Adresse, LNURL oder BOLT11';

  @override
  String get contactsRequired => 'Name und Ziel sind erforderlich';

  @override
  String get contactsInvalidDestination =>
      'Keine gültige Lightning-Adresse. Verwende eine Lightning-Adresse (user@host.tld), eine BOLT11-Rechnung, ein BOLT12-Angebot/-Rechnung (lno1…/lni1…) oder LNURL.';

  @override
  String get contactsImport => 'Kontakte importieren';

  @override
  String get contactsExport => 'Kontakte exportieren';

  @override
  String get contactsExportEmpty => 'Keine Kontakte zum Exportieren';

  @override
  String get contactsShareSubject => 'EmberSpark-Kontakte';

  @override
  String get contactsImportFailed =>
      'Diese Kontaktdatei konnte nicht gelesen werden';

  @override
  String contactsImported(int count) {
    return '$count Kontakte importiert';
  }

  @override
  String get historyTitle => 'Verlauf';

  @override
  String get historyEmpty => 'Noch keine Transaktionen';

  @override
  String get historySearchHint => 'Zahlungen durchsuchen';

  @override
  String get historyNoResults => 'Keine passenden Zahlungen';

  @override
  String get historyPaymentDefault => 'Lightning-Zahlung';

  @override
  String get historyPending => 'ausstehend';

  @override
  String historyFee(String amount) {
    return 'Gebühr $amount';
  }

  @override
  String get historyDetailsTitle => 'Zahlung';

  @override
  String get historyDirectionSent => 'Gesendet';

  @override
  String get historyDirectionReceived => 'Empfangen';

  @override
  String get historyStatusPaid => 'Bezahlt';

  @override
  String get historyStatusPendingLabel => 'Ausstehend';

  @override
  String get historyAmountLabel => 'Betrag';

  @override
  String get historyValueNow => 'Aktueller Wert';

  @override
  String get historyValueThen => 'Wert am Transaktionsdatum';

  @override
  String get historyFeeLabel => 'Gebühr';

  @override
  String get historyMemoLabel => 'Notiz';

  @override
  String get historyCommentLabel => 'Kommentar';

  @override
  String get historyTimestampLabel => 'Zeit';

  @override
  String get historyPaymentHashLabel => 'Zahlungs-Hash';

  @override
  String get historyInvoiceLabel => 'Rechnung';

  @override
  String get historyClose => 'Schließen';

  @override
  String get historyJustNow => 'gerade eben';

  @override
  String historyMinutesAgo(int minutes) {
    return 'vor $minutes Min.';
  }

  @override
  String historyHoursAgo(int hours) {
    return 'vor $hours Std.';
  }

  @override
  String historyDaysAgo(int days) {
    return 'vor $days Tagen';
  }

  @override
  String get lockedLabel => 'Gesperrt';

  @override
  String get lockUnlock => 'Entsperren';

  @override
  String get lockTryAgain => 'Erneut versuchen';

  @override
  String get lnurlTitleAuthenticate => 'Authentifizieren';

  @override
  String get lnurlTitlePay => 'Senden (LNURL)';

  @override
  String get lnurlTitleWithdraw => 'Empfangen (LNURL)';

  @override
  String get lnurlTitleGeneric => 'LNURL';

  @override
  String get lnurlResolvedExplain =>
      'Aufgelöste URL — füge sie in einen Browser ein, um zu prüfen, ob der Server außerhalb der Wallet antwortet:';

  @override
  String get lnurlCopyUrl => 'URL kopieren';

  @override
  String get lnurlUrlCopied => 'URL kopiert';

  @override
  String lnurlAuthRegisterAt(String host) {
    return 'Bei $host registrieren';
  }

  @override
  String lnurlAuthLinkAt(String host) {
    return 'Konto bei $host verknüpfen';
  }

  @override
  String lnurlAuthAuthenticateAt(String host) {
    return 'Bei $host authentifizieren';
  }

  @override
  String lnurlAuthLoginAt(String host) {
    return 'Bei $host anmelden';
  }

  @override
  String get lnurlAuthExplain =>
      'Ein eindeutiger Signaturschlüssel für diese Seite wird aus deinem Wallet-Seed abgeleitet. Die Seite sieht nur deinen öffentlichen Schlüssel — deine Wallet und dein Guthaben bleiben privat.';

  @override
  String get lnurlAuthConfirm => 'Bestätigen';

  @override
  String lnurlAuthSuccess(String host) {
    return 'Bei $host authentifiziert';
  }

  @override
  String lnurlAmountRange(int min, int max) {
    return 'Bereich: $min – $max Sats';
  }

  @override
  String lnurlAmountOutOfRange(int min, int max) {
    return 'Betrag muss zwischen $min und $max Sats liegen';
  }

  @override
  String get lnurlAmountPositive => 'Gib einen positiven Betrag ein';

  @override
  String get lnurlGetAndPay => 'Senden';

  @override
  String get lnurlWithdraw => 'Abheben';

  @override
  String get lnurlWithdrawDefaultMemo => 'LNURL-Auszahlung';

  @override
  String get withdrawChooseWallet => 'Ziel-Wallet wählen';

  @override
  String lnurlWithdrawing(int amount) {
    return '$amount Sats werden abgehoben …';
  }

  @override
  String get lnurlCommentLabel => 'Notiz (optional)';

  @override
  String lnurlCommentHelp(int max) {
    return 'Maximal $max Zeichen';
  }

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSubtitle => 'App-Sprache wählen';

  @override
  String get languageSystemDefault => 'Systemstandard';

  @override
  String get settingsDisplayCurrency => 'Anzeigewährung';

  @override
  String get settingsDisplayCurrencySubtitle =>
      'Wird für den Fiat-Betrag unter dem Guthaben verwendet';

  @override
  String get settingsLockOnLaunch => 'App beim Start sperren';

  @override
  String get settingsLockSubtitleEnabled =>
      'Biometrie oder Geräte-PIN/Muster zum Öffnen von EmberSpark erforderlich.';

  @override
  String get settingsLockSubtitleUnavailable =>
      'Auf diesem Gerät ist keine Bildschirmsperre eingerichtet. Richte in den Systemeinstellungen eine ein, um diese Option zu aktivieren.';

  @override
  String get settingsLockConfirmReason =>
      'Bestätige, um die App-Sperre zu aktivieren';

  @override
  String get settingsLockNeedSetup =>
      'Richte zuerst eine Bildschirmsperre oder Biometrie auf deinem Gerät ein.';

  @override
  String get settingsTrustTls => 'Unverifizierte HTTPS-Verbindungen erlauben';

  @override
  String get settingsTrustTlsSubtitle =>
      'Vertrauen in selbstsignierte oder unvollständige Zertifikatsketten. Nötig für manche Hobby-Lightning-Server und .onion-Adressen. Nur für Server aktivieren, denen du vertraust.';

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsNotifyReceived =>
      'Über eingehende Zahlungen benachrichtigen';

  @override
  String get settingsNotifyReceivedSubtitle =>
      'Benachrichtigungen sind designbedingt verzögert. EmberSpark prüft im Hintergrund, statt Push-Dienste von Drittanbietern zu nutzen, sodass keine Zahlungsdaten weitergegeben werden. Verbraucht etwas Akku.';

  @override
  String get settingsNotifyPermissionDenied =>
      'Erlaube Benachrichtigungen für EmberSpark in den Systemeinstellungen, um dies zu nutzen.';

  @override
  String get settingsNotifyHelp =>
      'Sofortige Benachrichtigungen (fortgeschritten)';

  @override
  String get settingsNotifyTest => 'Testbenachrichtigung senden';

  @override
  String get settingsNotifySound => 'Benachrichtigungston';

  @override
  String get notifySoundCoins => 'Münzen';

  @override
  String get notifySoundWoosh => 'Fire Woosh';

  @override
  String get notifySoundDefault => 'Gerätestandard';

  @override
  String get notifySoundPreview => 'Ton abspielen';

  @override
  String get notifyReceivedTitle => 'Zahlung empfangen';

  @override
  String notifyReceivedBody(String walletLabel, String amount) {
    return '$walletLabel: $amount Sats empfangen';
  }

  @override
  String get notifyChannelName => 'Empfangene Zahlungen';

  @override
  String get notifyChannelDescription =>
      'Benachrichtigt dich, wenn eine Wallet Sats empfängt, während die App geschlossen ist.';

  @override
  String get notifyHelpTitle => 'Sofortige Benachrichtigungen';

  @override
  String get notifyHelpIntro =>
      'Die eingebaute Option prüft den Kontostand etwa alle 15 Minuten, während die App geschlossen ist, daher kann eine Benachrichtigung verzögert sein. Für sofortige Hinweise ohne Akkuverbrauch kannst du deinen eigenen LNbits-Server mit einem selbst gehosteten ntfy-Push-Dienst verbinden.';

  @override
  String get notifyHelpHowTitle => 'So funktioniert es';

  @override
  String get notifyHelpHowBody =>
      'ntfy ist ein kostenloser, quelloffener Push-Dienst, den du selbst hosten oder auf ntfy.sh nutzen kannst. Dein LNbits-Server sendet in dem Moment, in dem eine Zahlung eintrifft, eine kurze Nachricht an ein privates ntfy-Topic, und die ntfy-App auf deinem Handy zeigt sie sofort an. Keine Google-Dienste und kein Hintergrund-Polling durch EmberSpark.';

  @override
  String get notifyHelpStepsTitle => 'Einrichten';

  @override
  String get notifyHelpStepsBody =>
      '1. Installiere die ntfy-App und abonniere ein privates Topic. Wähle einen langen, schwer zu erratenden Namen.\n2. Setze in LNbits beim Erstellen von Rechnungen den Invoice-Webhook auf die URL deines ntfy-Topics, oder betreibe ein kleines Skript, das den Zahlungsstrom deiner Wallet beobachtet und bei jedem Eingang an das Topic sendet.\n3. Sende dir eine Testzahlung, um zu prüfen, ob die Benachrichtigung ankommt.';

  @override
  String get notifyHelpCoverageNote =>
      'Hinweis: Ein Invoice-Webhook wird nur für Rechnungen ausgelöst, die diese App mit angehängtem Webhook erstellt. Zahlungen an eine feste Lightning-Adresse, einen LNURL-Pay-Link oder eine Bolt Card werden auf dem Server erstellt, daher braucht es dafür das kleine Beobachter-Skript statt eines Invoice-Webhooks.';

  @override
  String get notifyHelpExampleLabel => 'Beispiel-URL für ein ntfy-Topic';

  @override
  String get notifyHelpCopied => 'In die Zwischenablage kopiert';

  @override
  String get notifyHelpOpenNtfy => 'ntfy.sh öffnen';

  @override
  String get notifyHelpPrivacyNote =>
      'Auf dem öffentlichen ntfy.sh haben Topics keine Zugriffskontrolle, wer den Topic-Namen kennt, kann die Nachrichten lesen, samt Betrag und Verwendungszweck. Nutze einen langen, zufälligen Topic-Namen und für echte Privatsphäre ein reserviertes Topic (ntfy Pro) oder hoste ntfy selbst mit Authentifizierung.';

  @override
  String get aboutTitle => 'Über';

  @override
  String get aboutTagline => 'Eine schlanke Lightning-Wallet für LNbits';

  @override
  String get aboutCopyright => '© 2026 Trepnick Solutions';

  @override
  String get aboutVersionLabel => 'Version';

  @override
  String get aboutCheckAgain => 'Erneut prüfen';

  @override
  String get aboutCheckingForUpdates => 'Suche nach Updates …';

  @override
  String get aboutUpToDate => 'Aktuell';

  @override
  String aboutUpdateAvailable(String version) {
    return 'Update verfügbar: v$version';
  }

  @override
  String get aboutOpenRelease => 'Release öffnen';

  @override
  String get aboutCheckFailed => 'Update-Prüfung fehlgeschlagen';

  @override
  String get aboutUpdatesViaStore => 'Updates werden von Google Play verwaltet';

  @override
  String get aboutSupportDevelopment => 'Entwicklung unterstützen';

  @override
  String get aboutSupportBody =>
      'EmberSpark wird in der Freizeit entwickelt und gepflegt. Wenn dir die App hilft, deine Sats besser zu verwalten, kannst du gerne ein paar On-Chain-BTC an die Adresse unten schicken. Jedes bisschen hält das Projekt am Leben. Danke! Bug-Reports oder Feature-Wünsche auf GitHub sind genauso willkommen.';

  @override
  String get aboutDonateMethods => 'Spenden via Lightning / On-Chain';

  @override
  String get aboutContributeOnGithub => 'Auf GitHub mitwirken';

  @override
  String get aboutCopyAddress => 'Adresse kopieren';

  @override
  String get aboutAddressCopied => 'Adresse kopiert';

  @override
  String get aboutLicensesTitle => 'Open-Source-Lizenzen';

  @override
  String get aboutLicensesSubtitle => 'Flutter-SDK und Drittanbieter-Pakete';

  @override
  String get errorTlsCertificate =>
      'Das TLS-Zertifikat des Servers konnte nicht überprüft werden.\nWenn du dem Server vertraust, aktiviere „Unverifizierte HTTPS-Verbindungen erlauben“ in den Einstellungen.';

  @override
  String get errorTlsHandshake =>
      'Es konnte keine sichere Verbindung zum Server hergestellt werden.\nDer Server nutzt evtl. eine veraltete TLS-Version oder das Zertifikat ist ungültig.\nWenn du dem Server vertraust, versuche es mit „Unverifizierte HTTPS-Verbindungen erlauben“.';

  @override
  String get errorHostLookup =>
      'Der LNbits-Hostname konnte nicht aufgelöst werden.\nPrüfe die URL und deine Netzwerkverbindung.';

  @override
  String get errorConnectionRefused =>
      'Der LNbits-Server hat die Verbindung abgelehnt.\nPrüfe die URL und ob der Server läuft.';

  @override
  String get errorConnectionDropped =>
      'Die Verbindung zum LNbits-Server wurde getrennt. Versuche es erneut.';

  @override
  String get errorNetworkUnreachable =>
      'Keine Netzwerkverbindung. Prüfe WLAN / mobile Daten.';

  @override
  String get errorSocket =>
      'Der LNbits-Server konnte nicht erreicht werden. Prüfe dein Netzwerk.';

  @override
  String get errorTimeout =>
      'Der Server hat nicht rechtzeitig geantwortet. Versuche es erneut.';

  @override
  String get error401 =>
      'Authentifizierung fehlgeschlagen. Prüfe deinen Admin-/Invoice-API-Schlüssel.';

  @override
  String get error403 =>
      'Der Server hat den Zugriff verweigert. Der Gutschein wurde evtl. schon eingelöst, oder deine IP ist gesperrt.';

  @override
  String get error404 =>
      'Endpunkt nicht gefunden. Prüfe, ob die LNbits-URL korrekt ist.';

  @override
  String get error500 => 'LNbits-Serverfehler. Prüfe die LNbits-Logs.';

  @override
  String get error502 => 'LNbits ist über den Proxy nicht erreichbar.';

  @override
  String get error503 => 'LNbits ist vorübergehend nicht verfügbar.';

  @override
  String get error520 =>
      'LNbits hat kein Lightning-Backend konfiguriert (VoidWallet). Verbinde einen Lightning-Node unter LNbits → Server → Funding.';

  @override
  String get errorInsufficientFunds =>
      'Nicht genug Sats in deiner Wallet für diese Zahlung.';

  @override
  String get errorSelfPayment =>
      'Diese Rechnung stammt aus dieser Wallet. Du kannst nicht an dich selbst zahlen.';

  @override
  String get errorNotLnurl => 'Dieser Link ist kein gültiger LNURL-Dienst';

  @override
  String get errorReadOnlyWallet =>
      'Dies ist eine schreibgeschützte Wallet. Sie kann nur empfangen, nicht senden.';

  @override
  String get walletReadOnly => 'Nur Lesen';

  @override
  String get errorLnurlInsecureCallback =>
      'Der LNbits-Server hat eine unsichere (http://) Callback-URL zurückgegeben. Wahrscheinlich steht LNbits hinter einem Reverse Proxy und kennt seine öffentliche HTTPS-Adresse nicht. Setze auf dem LNbits-Server LNBITS_BASE_URL=https://dein-host in der .env und starte ihn neu. Alternativ konfiguriere den Proxy so, dass X-Forwarded-Proto: https weitergereicht wird.';

  @override
  String errorServerGeneric(String code) {
    return 'Serverfehler ($code).';
  }

  @override
  String get lnurlAuthErrorKeyInUse =>
      'Dieser Authentifizierungsschlüssel wird bereits für diese Seite verwendet. Warte einen Moment und versuche es erneut oder lade den Login-QR neu.';

  @override
  String get lnurlAuthErrorInvalidSignature =>
      'Die Seite hat die Authentifizierungssignatur abgelehnt. Bitte erneut versuchen.';

  @override
  String get lnurlAuthErrorLinkingKeyMismatch =>
      'Die Seite erkennt diesen Authentifizierungsschlüssel nicht. Das passiert meist, wenn du dich zuvor mit einem anderen Wallet-Seed authentifiziert hast.';

  @override
  String lnurlAuthErrorGeneric(String reason) {
    return 'LNURL-Auth fehlgeschlagen: $reason';
  }

  @override
  String get bolt12TitlePayOffer => 'BOLT12-Angebot bezahlen';

  @override
  String get bolt12TitlePayInvoice => 'BOLT12-Rechnung bezahlen';

  @override
  String get bolt12AmountLabel => 'Betrag (Sats)';

  @override
  String get bolt12MemoLabel => 'Notiz an den Empfänger (optional)';

  @override
  String get bolt12RawStringLabel => 'BOLT12-Zeichenkette';

  @override
  String get bolt12NotSupported =>
      'BOLT12 wird von diesem LNbits-Server nicht unterstützt. Dein Lightning-Node versteht BOLT12 evtl. nicht, oder die LNbits-BOLT12-Erweiterung ist nicht installiert.';

  @override
  String get myContactTitle => 'Mein Kontakt';

  @override
  String get myContactLnAddressSection => 'Lightning-Adresse';

  @override
  String get myContactBolt12Section => 'BOLT12-Angebot';

  @override
  String get myContactAddLnAddress => 'Lightning-Adresse hinzufügen';

  @override
  String get myContactAddBolt12 => 'BOLT12-Angebot hinzufügen';

  @override
  String get myContactLnAddressHint =>
      'user@domain. Liegt die Domain auf dem LNbits-Server, legt EmberSpark sie dort an; sonst wird sie unverändert gespeichert.';

  @override
  String get myContactBolt12Hint =>
      'lno1… — füge das Angebot ein, das dein Lightning-Node erstellt hat.';

  @override
  String get myContactInvalidLnAddress => 'Keine gültige Lightning-Adresse.';

  @override
  String get myContactInvalidBolt12 => 'Kein gültiges BOLT12-Angebot.';

  @override
  String get myContactCopied => 'Kopiert';

  @override
  String get myContactShareSubject => 'Mein Lightning-Kontakt';

  @override
  String get myContactRemoveConfirm => 'Diesen Eintrag entfernen?';

  @override
  String get myContactAutoGenerate => 'Automatisch erstellen';

  @override
  String get myContactLnurlpSection => 'LNURL-Pay-Link';

  @override
  String get myContactAddLnurlp => 'LNURL-Pay-Link hinzufügen';

  @override
  String get myContactLnurlpHint =>
      'lnurl1… — füge einen Link ein oder erstelle einen automatisch über den LNbits-Server.';

  @override
  String get myContactInvalidLnurlp => 'Kein gültiger LNURL-Pay-Link.';

  @override
  String get myContactGenerating => 'Wird erstellt …';

  @override
  String get myContactLnurlpExtensionMissing =>
      'Auf dem LNbits-Server ist die LNURL-Pay-Erweiterung nicht installiert.';

  @override
  String get myContactReadOnlyNoGenerate =>
      'Dies ist eine schreibgeschützte Wallet und kann daher keinen Link auf dem Server erstellen. Du kannst unten weiterhin einen vorhandenen einfügen.';

  @override
  String get myContactLnAddressServerUpdated =>
      'Lightning-Adresse auf dem Server aktualisiert.';

  @override
  String get myContactBolt12ExtensionMissing =>
      'Auf dem LNbits-Server ist keine BOLT12-Erweiterung installiert, oder dein Lightning-Node unterstützt BOLT12 nicht.';

  @override
  String get myContactAvatarPriority =>
      'Dein Profil-Avatar wird aus einer dieser Kennungen erzeugt. Tippe auf einen Stern, um auszuwählen, welche. Sonst gilt: Lightning-Adresse, dann BOLT12, dann LNURL.';

  @override
  String get myContactSetDefault => 'Als Standard-Identität festlegen';

  @override
  String get myContactUnsetDefault => 'Als Standard-Identität entfernen';

  @override
  String get myContactTabLnAddress => 'LN-Adresse';

  @override
  String get myContactTabLnurlp => 'LNURL';

  @override
  String get myContactTabBolt12 => 'BOLT12';

  @override
  String get myContactLnAddressUse =>
      'Einfach an Freunde und Familie weiterzugeben.';

  @override
  String get myContactLnurlpUse =>
      'Weniger identifizierende Bech32-Zeichenkette, läuft aber über denselben Server.';

  @override
  String get myContactBolt12Use =>
      'Beste Privatsphäre: Zahlungen laufen direkt über Lightning, ohne Domain-Betreiber dazwischen.';

  @override
  String get walletsMenu => 'Wallets';

  @override
  String get walletsTitle => 'Wallets';

  @override
  String get walletsEmpty => 'Noch keine Wallets — füge die erste hinzu.';

  @override
  String get walletsAdd => 'Wallet hinzufügen';

  @override
  String get walletsActive => 'Aktiv';

  @override
  String get walletsEdit => 'Wallet bearbeiten';

  @override
  String get walletsRemove => 'Wallet entfernen';

  @override
  String get walletsRemoveConfirm =>
      'Diese Wallet vom Gerät entfernen? Die zugehörigen My-Contact-Einträge werden gelöscht. Die Wallet auf dem Server ist nicht betroffen.';

  @override
  String get walletsDuplicate => 'Diese Wallet ist bereits hinzugefügt.';

  @override
  String get walletsActiveLabelTooltip => 'Tippen, um die Wallet zu wechseln';

  @override
  String get loginWalletNameLabel => 'Wallet-Name (optional)';

  @override
  String get loginWalletNameHint => 'Standardmäßig der Server-Hostname';
}
