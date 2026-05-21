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
  String get loginTitle => 'Wallet einrichten';

  @override
  String get loginUrlLabel => 'LNbits-URL';

  @override
  String get loginUrlHint => 'https://deine.node';

  @override
  String get loginAdminKeyLabel => 'Admin-API-Schlüssel';

  @override
  String get loginAdminKeyHelper =>
      'Vollzugriffs-Schlüssel — wird für alle Operationen verwendet';

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
  String get receiveTitle => 'Empfangen';

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
  String get historyTitle => 'Verlauf';

  @override
  String get historyEmpty => 'Noch keine Transaktionen';

  @override
  String get historyPaymentDefault => 'Lightning-Zahlung';

  @override
  String get historyPending => 'ausstehend';

  @override
  String historyFee(String amount) {
    return 'Gebühr $amount';
  }

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
  String get lnurlGetAndPay => 'Rechnung holen & bezahlen';

  @override
  String get lnurlWithdraw => 'Abheben';

  @override
  String get lnurlWithdrawDefaultMemo => 'LNURL-Auszahlung';

  @override
  String lnurlWithdrawing(int amount) {
    return '$amount Sats werden abgehoben …';
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
  String get aboutTitle => 'Über';

  @override
  String get aboutTagline => 'Eine kleine Lightning-Wallet für LNbits';

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
  String get aboutSupportDevelopment => 'Entwicklung unterstützen';

  @override
  String get aboutSupportBody =>
      'EmberSpark wird in der Freizeit gebaut und gepflegt. Wenn dir die App hilft, deine Sats besser zu verwalten, kannst du gerne ein paar On-Chain-BTC an die Adresse unten schicken. Jedes bisschen hält das Projekt am Leben. Danke! Bug-Reports oder Feature-Wünsche auf GitHub sind genauso willkommen.';

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
  String get errorLnurlInsecureCallback =>
      'Dein LNbits-Server hat eine unsichere (http://) Callback-URL zurückgegeben. Wahrscheinlich steht LNbits hinter einem Reverse Proxy und kennt seine öffentliche HTTPS-Adresse nicht. Setze auf dem LNbits-Server LNBITS_BASE_URL=https://dein-host in der .env und starte ihn neu. Alternativ konfiguriere den Proxy so, dass X-Forwarded-Proto: https weitergereicht wird.';

  @override
  String errorServerGeneric(String code) {
    return 'Serverfehler ($code).';
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
      'user@deine.domain — muss bereits auf einem von dir kontrollierten Server existieren.';

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
      'lnurl1… — füge einen Link ein oder erstelle einen automatisch über deinen LNbits-Server.';

  @override
  String get myContactInvalidLnurlp => 'Kein gültiger LNURL-Pay-Link.';

  @override
  String get myContactGenerating => 'Wird erstellt …';

  @override
  String get myContactLnurlpExtensionMissing =>
      'Auf deinem LNbits-Server ist die LNURL-Pay-Erweiterung nicht installiert.';

  @override
  String get myContactBolt12ExtensionMissing =>
      'Auf deinem LNbits-Server ist keine BOLT12-Erweiterung installiert, oder dein Lightning-Node unterstützt BOLT12 nicht.';

  @override
  String get myContactAvatarPriority =>
      'Dein Profil-Avatar wird aus diesen Kennungen erzeugt. Der höchstpriorisierte gesetzte Wert dient als Seed. Änderst du ihn, ändert sich auch der Avatar.\n\nReihenfolge: Lightning-Adresse > BOLT12-Angebot > LNURL-Pay-Link > LNbits-Wallet-UUID > lokale ID.';

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
