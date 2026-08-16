// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'EmberSpark';

  @override
  String get appLocked => 'Verrouillé';

  @override
  String get appUnlock => 'Déverrouiller';

  @override
  String get appTryAgain => 'Réessayer';

  @override
  String get appSetupFirstToast => 'Configure d\'abord le portefeuille';

  @override
  String get commonCopy => 'Copier';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonScanQr => 'Scanner un QR';

  @override
  String get commonScan => 'Scanner';

  @override
  String get commonShare => 'Partager';

  @override
  String get commonNfc => 'NFC';

  @override
  String get commonPaste => 'Coller';

  @override
  String get commonImage => 'Image';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonAmount => 'Montant (sats)';

  @override
  String get commonUnknownError => 'Erreur inconnue';

  @override
  String get receiveShareSubject => 'Facture Lightning';

  @override
  String get nfcHoldTag => 'Approche une étiquette NFC du téléphone…';

  @override
  String get nfcWriteSuccess => 'Écrit sur l\'étiquette';

  @override
  String get nfcWriteFailed => 'Impossible d\'écrire sur l\'étiquette';

  @override
  String get nfcReadFailed => 'Impossible de lire l\'étiquette';

  @override
  String get nfcUnavailable => 'NFC indisponible sur cet appareil';

  @override
  String get imageNoQr => 'Aucun code QR trouvé dans l\'image';

  @override
  String get clipboardEmpty => 'Le presse-papiers est vide';

  @override
  String get homeScan => 'Scanner un QR';

  @override
  String get homeSend => 'Envoyer';

  @override
  String get homeReceive => 'Recevoir';

  @override
  String get homeContacts => 'Contacts';

  @override
  String get homeSettings => 'Paramètres';

  @override
  String get homeLogout => 'Se déconnecter';

  @override
  String get homeMyContact => 'Mon contact';

  @override
  String get homeBoltCard => 'Bolt Card';

  @override
  String homeSatsReceived(String amount) {
    return 'Tu as reçu $amount sats';
  }

  @override
  String homeSatsSent(String amount) {
    return 'Tu as envoyé $amount sats';
  }

  @override
  String get homeSatsUnit => 'sats';

  @override
  String get boltCardTitle => 'Bolt Cards';

  @override
  String get boltCardExtensionMissing =>
      'L\'extension Boltcards n\'est pas installée sur ce serveur.';

  @override
  String get boltCardNone =>
      'Aucune Bolt Card pour l\'instant. Touche Ajouter pour en configurer une.';

  @override
  String get boltCardAdd => 'Ajouter une Bolt Card';

  @override
  String get boltCardEdit => 'Modifier la carte';

  @override
  String get boltCardName => 'Nom de la carte';

  @override
  String get boltCardTxLimit => 'Limite par tap (sats)';

  @override
  String get boltCardDailyLimit => 'Limite quotidienne (sats)';

  @override
  String get boltCardCreate => 'Créer';

  @override
  String get boltCardSave => 'Enregistrer';

  @override
  String get boltCardProgram => 'Programmer la carte';

  @override
  String get boltCardVerify => 'Vérifier';

  @override
  String get boltCardWipe => 'Réinitialiser';

  @override
  String get boltCardDelete => 'Supprimer';

  @override
  String get boltCardEnable => 'Activer';

  @override
  String get boltCardDisable => 'Désactiver';

  @override
  String get boltCardEnabled => 'Activée';

  @override
  String get boltCardDisabled => 'Désactivée';

  @override
  String boltCardCounter(int count) {
    return '$count taps';
  }

  @override
  String boltCardLimits(int tx, int daily) {
    return 'Par tap $tx sats, par jour $daily sats';
  }

  @override
  String get boltCardHoldToProgram =>
      'Maintiens ta carte contre le téléphone pour la programmer. Ne la retire pas avant la fin.';

  @override
  String get boltCardHoldToVerify =>
      'Maintiens ta carte contre le téléphone pour la lire.';

  @override
  String get boltCardHoldToWipe =>
      'Maintiens ta carte contre le téléphone pour la réinitialiser. Ne la retire pas avant la fin.';

  @override
  String get boltCardProgrammed => 'Carte programmée.';

  @override
  String get boltCardProgramFailed => 'Impossible de programmer la carte.';

  @override
  String get boltCardNotBlank =>
      'Cette carte est déjà programmée. Réinitialise-la d\'abord.';

  @override
  String get boltCardUidAlreadyRegistered =>
      'Une Bolt Card avec cet UID est déjà enregistrée sur le serveur. Supprime l\'entrée de carte existante et réessaie.';

  @override
  String get boltCardVerifyNotProgrammed =>
      'Cette carte n\'est pas encore programmée, il n\'y a donc rien à vérifier.';

  @override
  String get boltCardVerified =>
      'La carte fonctionne et pointe vers ce portefeuille.';

  @override
  String get boltCardVerifiedBadge => 'Vérifiée';

  @override
  String get boltCardVerifyWrongServer =>
      'Cette carte pointe vers un serveur différent.';

  @override
  String get boltCardVerifyUidMismatch =>
      'L\'ID de la puce de cette carte ne correspond pas à l\'enregistrement du serveur. Réinitialise la carte, puis ajoute-la et programme-la à nouveau pour que le bon ID soit enregistré.';

  @override
  String get boltCardVerifyCounterBehind =>
      'Le compteur de taps de cette carte est en retard sur le serveur. Reprogramme la carte pour le réinitialiser.';

  @override
  String get boltCardTagLost =>
      'La carte a été retirée trop tôt. Maintiens-la à plat contre l\'arrière du téléphone et immobile jusqu\'à la fin de l\'opération, puis réessaie.';

  @override
  String get boltCardChargeOnlyTitle => 'Bolt Card';

  @override
  String get boltCardChargeOnlyBody =>
      'Une Bolt Card ne peut être que débitée, pas payée. Veux-tu la débiter ?';

  @override
  String get boltCardChargeAction => 'Débiter';

  @override
  String get boltCardVerifyFailed => 'Impossible de vérifier la carte.';

  @override
  String get boltCardWipeConfirm =>
      'Réinitialiser cette carte aux clés d\'usine ? Elle cessera de fonctionner jusqu\'à ce que tu la reprogrammes.';

  @override
  String get boltCardWiped => 'Carte réinitialisée aux clés d\'usine.';

  @override
  String get boltCardWipeFailed => 'Impossible de réinitialiser la carte.';

  @override
  String get boltCardDeleteConfirm => 'Supprimer cette carte du serveur ?';

  @override
  String get loginTitle => 'Configurer le portefeuille';

  @override
  String get loginUrlLabel => 'URL LNbits';

  @override
  String get loginUrlHint => 'https://ton.noeud';

  @override
  String get loginAdminKeyLabel => 'Clé API admin';

  @override
  String get loginAdminKeyHelper =>
      'Clé admin pour l\'accès complet, ou une clé invoice/lecture pour un portefeuille en lecture seule';

  @override
  String get loginAdminKeyRequired => 'La clé admin est requise';

  @override
  String get loginScanUrlTitle => 'Scanner l\'URL LNbits';

  @override
  String get loginScanAdminTitle => 'Scanner la clé admin';

  @override
  String get loginHint =>
      'Trouve le code QR dans LNbits → wallet → \"API info\" → Admin key.';

  @override
  String get disclaimerTitle => 'À qui s\'adresse EmberSpark ?';

  @override
  String get disclaimerBody =>
      'EmberSpark est un client pour les portefeuilles Lightning LNbits auto-hébergés. Il s\'adresse aux personnes qui gèrent leur propre serveur LNbits, ou à qui quelqu\'un qui en a un a donné accès à un portefeuille. Si ce n\'est pas ton cas, cette app n\'est pas faite pour toi.';

  @override
  String get disclaimerAck => 'J\'ai compris';

  @override
  String get sendTitle => 'Envoyer';

  @override
  String get sendBolt11Label => 'Facture BOLT11';

  @override
  String get sendPay => 'Payer';

  @override
  String get sendPaymentSent => 'Paiement envoyé';

  @override
  String get sendPasteFirst => 'Colle d\'abord une facture';

  @override
  String get sendAnyAmount => 'N\'importe quel montant';

  @override
  String sendAmountWithSats(String amount) {
    return '$amount sats';
  }

  @override
  String get sendToTitle => 'Envoyer à…';

  @override
  String get sendToInputLabel => 'Adresse ou données de paiement';

  @override
  String get sendToInputHint => 'BOLT11, LNURL ou user@host';

  @override
  String get sendToScanTitle => 'Scanner pour envoyer';

  @override
  String get sendToContacts => 'Contacts';

  @override
  String get sendToNoContacts => 'Aucun contact pour l\'instant';

  @override
  String get contactsSearchHint => 'Filtrer les contacts';

  @override
  String get contactsNoMatches => 'Aucun contact correspondant';

  @override
  String get receiveTitle => 'Recevoir';

  @override
  String get receiveReusableAddress => 'Ton adresse réutilisable';

  @override
  String get receiveAmount => 'Montant';

  @override
  String get receiveMemo => 'Note';

  @override
  String get receiveCreateInvoice => 'Créer une facture';

  @override
  String get receiveInvoiceCopied => 'Facture copiée';

  @override
  String get receiveAmountError => 'Saisis un montant positif';

  @override
  String get receiveEnterAmountFirst => 'Saisis d\'abord un montant';

  @override
  String receiveCardCharged(int sats) {
    return '$sats sats débités de la carte';
  }

  @override
  String receiveSatsApprox(String amount) {
    return '≈ $amount sats';
  }

  @override
  String get receiveRatesUnavailable =>
      'Cours en direct indisponibles — sats uniquement';

  @override
  String get receiveCurrencySats => 'sats';

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get contactsEmpty =>
      'Aucun contact pour l\'instant — touche + pour en ajouter un';

  @override
  String contactsDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get contactsNew => 'Nouveau contact';

  @override
  String get contactsEdit => 'Modifier le contact';

  @override
  String get contactsScanTitle => 'Scanner la destination';

  @override
  String get contactsName => 'Nom';

  @override
  String get contactsDestinationLabel => 'Lightning address, LNURL ou BOLT11';

  @override
  String get contactsRequired => 'Le nom et la destination sont requis';

  @override
  String get contactsInvalidDestination =>
      'Ce n\'est pas une destination Lightning valide. Utilise une Lightning address (user@host.tld), une facture BOLT11, une offre/facture BOLT12 (lno1…/lni1…) ou LNURL.';

  @override
  String get contactsImport => 'Importer des contacts';

  @override
  String get contactsExport => 'Exporter des contacts';

  @override
  String get contactsExportEmpty => 'Aucun contact à exporter';

  @override
  String get contactsShareSubject => 'Contacts EmberSpark';

  @override
  String get contactsImportFailed =>
      'Impossible de lire ce fichier de contacts';

  @override
  String contactsImported(int count) {
    return '$count contacts importés';
  }

  @override
  String get historyTitle => 'Historique';

  @override
  String get historyEmpty => 'Aucune transaction pour l\'instant';

  @override
  String get historySearchHint => 'Search payments';

  @override
  String get historyNoResults => 'No matching payments';

  @override
  String get historyPaymentDefault => 'Paiement Lightning';

  @override
  String get historyPending => 'en attente';

  @override
  String historyFee(String amount) {
    return 'frais $amount';
  }

  @override
  String get historyDetailsTitle => 'Transaction';

  @override
  String get historyDirectionSent => 'Envoyé';

  @override
  String get historyDirectionReceived => 'Reçu';

  @override
  String get historyStatusPaid => 'Payé';

  @override
  String get historyStatusPendingLabel => 'En attente';

  @override
  String get historyAmountLabel => 'Montant';

  @override
  String get historyFeeLabel => 'Frais';

  @override
  String get historyMemoLabel => 'Note';

  @override
  String get historyCommentLabel => 'Commentaire';

  @override
  String get historyTimestampLabel => 'Heure';

  @override
  String get historyPaymentHashLabel => 'Hash de paiement';

  @override
  String get historyInvoiceLabel => 'Facture';

  @override
  String get historyClose => 'Fermer';

  @override
  String get historyJustNow => 'à l\'instant';

  @override
  String historyMinutesAgo(int minutes) {
    return 'il y a $minutes min';
  }

  @override
  String historyHoursAgo(int hours) {
    return 'il y a $hours h';
  }

  @override
  String historyDaysAgo(int days) {
    return 'il y a $days j';
  }

  @override
  String get lockedLabel => 'Verrouillé';

  @override
  String get lockUnlock => 'Déverrouiller';

  @override
  String get lockTryAgain => 'Réessayer';

  @override
  String get lnurlTitleAuthenticate => 'Authentifier';

  @override
  String get lnurlTitlePay => 'Envoyer (LNURL)';

  @override
  String get lnurlTitleWithdraw => 'Recevoir (LNURL)';

  @override
  String get lnurlTitleGeneric => 'LNURL';

  @override
  String get lnurlResolvedExplain =>
      'URL résolue — colle-la dans un navigateur pour voir si le serveur répond en dehors du portefeuille :';

  @override
  String get lnurlCopyUrl => 'Copier l\'URL';

  @override
  String get lnurlUrlCopied => 'URL copiée';

  @override
  String lnurlAuthRegisterAt(String host) {
    return 'Inscris-toi sur $host';
  }

  @override
  String lnurlAuthLinkAt(String host) {
    return 'Lie ton compte sur $host';
  }

  @override
  String lnurlAuthAuthenticateAt(String host) {
    return 'Authentifie-toi sur $host';
  }

  @override
  String lnurlAuthLoginAt(String host) {
    return 'Connecte-toi à $host';
  }

  @override
  String get lnurlAuthExplain =>
      'Une clé de signature unique pour ce site sera dérivée de la seed de ton portefeuille. Le site ne voit que ta clé publique — ton portefeuille et ton solde restent privés.';

  @override
  String get lnurlAuthConfirm => 'Confirmer';

  @override
  String lnurlAuthSuccess(String host) {
    return 'Authentifié auprès de $host';
  }

  @override
  String lnurlAmountRange(int min, int max) {
    return 'Plage : $min – $max sats';
  }

  @override
  String lnurlAmountOutOfRange(int min, int max) {
    return 'Le montant doit être compris entre $min et $max sats';
  }

  @override
  String get lnurlAmountPositive => 'Saisis un montant positif';

  @override
  String get lnurlGetAndPay => 'Envoyer';

  @override
  String get lnurlWithdraw => 'Retirer';

  @override
  String get lnurlWithdrawDefaultMemo => 'LNURL-withdraw';

  @override
  String lnurlWithdrawing(int amount) {
    return 'Retrait de $amount sats…';
  }

  @override
  String get lnurlCommentLabel => 'Note (facultatif)';

  @override
  String lnurlCommentHelp(int max) {
    return 'Max $max caractères';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSubtitle => 'Choisis la langue de l\'app';

  @override
  String get languageSystemDefault => 'Par défaut du système';

  @override
  String get settingsDisplayCurrency => 'Devise d\'affichage';

  @override
  String get settingsDisplayCurrencySubtitle =>
      'Utilisée pour le montant en fiat sous le solde';

  @override
  String get settingsLockOnLaunch => 'Verrouiller l\'app au lancement';

  @override
  String get settingsLockSubtitleEnabled =>
      'Exige la biométrie ou le PIN/schéma de l\'appareil pour ouvrir EmberSpark.';

  @override
  String get settingsLockSubtitleUnavailable =>
      'Aucun verrouillage d\'écran n\'est configuré sur cet appareil. Configures-en un dans les paramètres système pour activer cette option.';

  @override
  String get settingsLockConfirmReason =>
      'Confirme pour activer le verrouillage de l\'app';

  @override
  String get settingsLockNeedSetup =>
      'Configure d\'abord un verrouillage d\'écran ou la biométrie sur ton téléphone.';

  @override
  String get settingsTrustTls => 'Autoriser HTTPS non vérifié';

  @override
  String get settingsTrustTlsSubtitle =>
      'Fais confiance aux certificats auto-signés ou à chaîne incomplète. Nécessaire pour certains serveurs Lightning amateurs et services .onion. À activer uniquement pour les serveurs de confiance.';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsNotifyReceived => 'Notify me about received payments';

  @override
  String get settingsNotifyReceivedSubtitle =>
      'Checks periodically in the background while the app is closed. May be delayed and uses some battery.';

  @override
  String get settingsNotifyPermissionDenied =>
      'Allow notifications for EmberSpark in system settings to use this.';

  @override
  String get settingsNotifyHelp => 'Get instant notifications (advanced)';

  @override
  String get settingsNotifyTest => 'Send test notification';

  @override
  String get settingsNotifySound => 'Notification sound';

  @override
  String get notifySoundCoins => 'Coins';

  @override
  String get notifySoundWoosh => 'Fire Woosh';

  @override
  String get notifySoundDefault => 'Device default';

  @override
  String get notifySoundPreview => 'Play sound';

  @override
  String get notifyReceivedTitle => 'Payment received';

  @override
  String notifyReceivedBody(String walletLabel, String amount) {
    return '$walletLabel: received $amount sats';
  }

  @override
  String get notifyChannelName => 'Received payments';

  @override
  String get notifyChannelDescription =>
      'Notifies you when a wallet receives sats while the app is closed.';

  @override
  String get notifyHelpTitle => 'Instant notifications';

  @override
  String get notifyHelpIntro =>
      'The built-in option checks your balance about every 15 minutes while the app is closed, so a notification can be delayed. For instant alerts without draining the battery, you can connect your own LNbits server to a self-hosted ntfy push service.';

  @override
  String get notifyHelpHowTitle => 'How it works';

  @override
  String get notifyHelpHowBody =>
      'ntfy is a free, open-source push service you can self-host or use at ntfy.sh. Your LNbits server sends a short message to a private ntfy topic the moment a payment arrives, and the ntfy app on your phone shows it instantly. No Google services and no background polling from EmberSpark.';

  @override
  String get notifyHelpStepsTitle => 'Set it up';

  @override
  String get notifyHelpStepsBody =>
      '1. Install the ntfy app and subscribe to a private topic. Pick a long, hard-to-guess name.\n2. In LNbits, set the invoice webhook to your ntfy topic URL when you create invoices, or run a small script that watches your wallet\'s payment stream and posts to the topic on every receive.\n3. Send yourself a test payment to confirm the notification arrives.';

  @override
  String get notifyHelpCoverageNote =>
      'Note: a per-invoice webhook only fires for invoices this app creates with a webhook attached. Payments to a static Lightning Address, LNURL-pay link, or Bolt Card are created on the server, so covering those needs the small watcher script rather than a per-invoice webhook.';

  @override
  String get notifyHelpExampleLabel => 'Example ntfy topic URL';

  @override
  String get notifyHelpCopied => 'Copied to clipboard';

  @override
  String get notifyHelpOpenNtfy => 'Open ntfy.sh';

  @override
  String get notifyHelpPrivacyNote =>
      'On the public ntfy.sh, topics have no access control, so anyone who knows the topic name can read its messages, including the amount and memo. Use a long, random topic name, and for real privacy use a reserved topic (ntfy Pro) or self-host ntfy with authentication.';

  @override
  String get aboutTitle => 'À propos';

  @override
  String get aboutTagline => 'Un portefeuille Lightning léger pour LNbits';

  @override
  String get aboutCopyright => '© 2026 Trepnick Solutions';

  @override
  String get aboutVersionLabel => 'Version';

  @override
  String get aboutCheckAgain => 'Vérifier à nouveau';

  @override
  String get aboutCheckingForUpdates => 'Recherche de mises à jour…';

  @override
  String get aboutUpToDate => 'À jour';

  @override
  String aboutUpdateAvailable(String version) {
    return 'Mise à jour disponible : v$version';
  }

  @override
  String get aboutOpenRelease => 'Ouvrir la version';

  @override
  String get aboutCheckFailed => 'Impossible de vérifier les mises à jour';

  @override
  String get aboutUpdatesViaStore =>
      'Les mises à jour sont gérées par Google Play';

  @override
  String get aboutSupportDevelopment => 'Soutenir le développement';

  @override
  String get aboutSupportBody =>
      'EmberSpark est développé et maintenu sur le temps libre. S\'il te facilite la gestion de tes sats, envisage d\'envoyer quelques BTC on-chain à l\'adresse ci-dessous. Chaque contribution garde le projet en vie. Merci ! Signaler des bugs ou proposer des fonctionnalités sur GitHub est tout aussi bienvenu.';

  @override
  String get aboutDonateMethods => 'Faire un don via Lightning / On-Chain';

  @override
  String get aboutContributeOnGithub => 'Contribuer sur GitHub';

  @override
  String get aboutCopyAddress => 'Copier l\'adresse';

  @override
  String get aboutAddressCopied => 'Adresse copiée';

  @override
  String get aboutLicensesTitle => 'Licences open source';

  @override
  String get aboutLicensesSubtitle => 'SDK Flutter et paquets tiers';

  @override
  String get errorTlsCertificate =>
      'Impossible de vérifier le certificat TLS du serveur.\nSi tu fais confiance à ce serveur, active \'Autoriser HTTPS non vérifié\' dans les Paramètres.';

  @override
  String get errorTlsHandshake =>
      'Impossible d\'établir une connexion sécurisée avec le serveur.\nLe serveur utilise peut-être une version de TLS obsolète, ou son certificat n\'est pas valide.\nSi tu fais confiance au serveur, essaie \'Autoriser HTTPS non vérifié\' dans les Paramètres.';

  @override
  String get errorHostLookup =>
      'Impossible de résoudre le nom d\'hôte LNbits.\nVérifie l\'URL et ta connexion réseau.';

  @override
  String get errorConnectionRefused =>
      'Le serveur LNbits a refusé la connexion.\nVérifie l\'URL et que le serveur est en cours d\'exécution.';

  @override
  String get errorConnectionDropped =>
      'La connexion au serveur LNbits a été interrompue. Réessaie.';

  @override
  String get errorNetworkUnreachable =>
      'Aucune connexion réseau. Vérifie le Wi-Fi / les données mobiles.';

  @override
  String get errorSocket =>
      'Impossible de joindre le serveur LNbits. Vérifie ton réseau.';

  @override
  String get errorTimeout => 'Le serveur n\'a pas répondu à temps. Réessaie.';

  @override
  String get error401 =>
      'Échec de l\'authentification. Vérifie tes clés API admin / de facturation.';

  @override
  String get error403 =>
      'Le serveur a refusé l\'accès. Le bon a peut-être déjà été utilisé, ou ton IP est bloquée.';

  @override
  String get error404 =>
      'Endpoint introuvable. Vérifie que l\'URL LNbits est correcte.';

  @override
  String get error500 => 'Erreur du serveur LNbits. Consulte les logs LNbits.';

  @override
  String get error502 => 'LNbits est injoignable via son proxy.';

  @override
  String get error503 => 'LNbits est temporairement indisponible.';

  @override
  String get error520 =>
      'LNbits n\'a aucun backend Lightning configuré (VoidWallet). Connecte un nœud Lightning dans LNbits → Server → Funding.';

  @override
  String get errorInsufficientFunds =>
      'Pas assez de sats dans ton portefeuille pour ce paiement.';

  @override
  String get errorSelfPayment =>
      'Cette facture provient de ce portefeuille. Tu ne peux pas te payer toi-même.';

  @override
  String get errorNotLnurl => 'Ce lien n\'est pas un service LNURL valide';

  @override
  String get errorReadOnlyWallet =>
      'Ceci est un portefeuille en lecture seule. Il peut seulement recevoir, pas envoyer.';

  @override
  String get walletReadOnly => 'Lecture seule';

  @override
  String get errorLnurlInsecureCallback =>
      'Le serveur LNbits a renvoyé une URL de callback non sécurisée (http://). Cela signifie généralement que LNbits est derrière un reverse proxy et ne connaît pas son adresse HTTPS publique. Sur l\'hôte LNbits, définis LNBITS_BASE_URL=https://ton-hote dans .env et redémarre. Sinon, configure le proxy pour transmettre X-Forwarded-Proto: https.';

  @override
  String errorServerGeneric(String code) {
    return 'Erreur du serveur ($code).';
  }

  @override
  String get lnurlAuthErrorKeyInUse =>
      'Cette clé d\'authentification est déjà utilisée pour ce site. Attends un instant et réessaie, ou recharge le QR de connexion.';

  @override
  String get lnurlAuthErrorInvalidSignature =>
      'Le site a rejeté la signature d\'authentification. Réessaie.';

  @override
  String get lnurlAuthErrorLinkingKeyMismatch =>
      'Le site ne reconnaît pas cette clé d\'authentification. Cela signifie généralement que tu t\'es déjà authentifié avec une seed de portefeuille différente.';

  @override
  String lnurlAuthErrorGeneric(String reason) {
    return 'Échec de LNURL-auth : $reason';
  }

  @override
  String get bolt12TitlePayOffer => 'Payer une offre BOLT12';

  @override
  String get bolt12TitlePayInvoice => 'Payer une facture BOLT12';

  @override
  String get bolt12AmountLabel => 'Montant (sats)';

  @override
  String get bolt12MemoLabel => 'Note du payeur (facultatif)';

  @override
  String get bolt12RawStringLabel => 'Chaîne BOLT12';

  @override
  String get bolt12NotSupported =>
      'BOLT12 n\'est pas pris en charge par ce serveur LNbits. Ton nœud Lightning ne comprend peut-être pas BOLT12, ou l\'extension BOLT12 de LNbits n\'est pas installée.';

  @override
  String get myContactTitle => 'Mon contact';

  @override
  String get myContactLnAddressSection => 'Lightning Address';

  @override
  String get myContactBolt12Section => 'Offre BOLT12';

  @override
  String get myContactAddLnAddress => 'Ajoute ta Lightning address';

  @override
  String get myContactAddBolt12 => 'Ajoute ton offre BOLT12';

  @override
  String get myContactLnAddressHint =>
      'user@domain. Si le domaine est le serveur LNbits, EmberSpark la configure là-bas ; sinon elle est enregistrée telle quelle.';

  @override
  String get myContactBolt12Hint =>
      'lno1… — colle l\'offre générée par ton nœud Lightning.';

  @override
  String get myContactInvalidLnAddress =>
      'Ce n\'est pas une Lightning address valide.';

  @override
  String get myContactInvalidBolt12 => 'Ce n\'est pas une offre BOLT12 valide.';

  @override
  String get myContactCopied => 'Copié';

  @override
  String get myContactShareSubject => 'Mon contact Lightning';

  @override
  String get myContactRemoveConfirm => 'Supprimer cette entrée ?';

  @override
  String get myContactAutoGenerate => 'Générer automatiquement';

  @override
  String get myContactLnurlpSection => 'Lien LNURL-pay';

  @override
  String get myContactAddLnurlp => 'Ajoute ton lien LNURL-pay';

  @override
  String get myContactLnurlpHint =>
      'lnurl1… — colle ton lien ou génères-en un automatiquement depuis le serveur LNbits.';

  @override
  String get myContactInvalidLnurlp =>
      'Ce n\'est pas un lien LNURL-pay valide.';

  @override
  String get myContactGenerating => 'Génération…';

  @override
  String get myContactLnurlpExtensionMissing =>
      'LNbits n\'a pas l\'extension LNURL-pay installée.';

  @override
  String get myContactReadOnlyNoGenerate =>
      'Ceci est un portefeuille en lecture seule, il ne peut donc pas créer de lien sur le serveur. Vous pouvez toujours en coller un existant ci-dessous.';

  @override
  String get myContactLnAddressServerUpdated =>
      'Lightning Address mise à jour sur le serveur.';

  @override
  String get myContactBolt12ExtensionMissing =>
      'LNbits n\'a pas d\'extension BOLT12 installée, ou ton nœud Lightning ne prend pas en charge BOLT12.';

  @override
  String get myContactAvatarPriority =>
      'Ton avatar de profil est généré à partir de l\'un de ces identifiants. Touche une étoile pour choisir lequel. Sinon, il utilise la Lightning address, puis BOLT12, puis LNURL.';

  @override
  String get myContactSetDefault => 'Définir comme identité par défaut';

  @override
  String get myContactUnsetDefault => 'Retirer comme identité par défaut';

  @override
  String get myContactTabLnAddress => 'LN Address';

  @override
  String get myContactTabLnurlp => 'LNURL';

  @override
  String get myContactTabBolt12 => 'BOLT12';

  @override
  String get myContactLnAddressUse => 'Facile à partager avec tes proches.';

  @override
  String get myContactLnurlpUse =>
      'Chaîne bech32 moins identifiante, mais elle passe par le même serveur.';

  @override
  String get myContactBolt12Use =>
      'Meilleure confidentialité : les paiements passent directement par Lightning, sans opérateur de domaine intermédiaire.';

  @override
  String get walletsMenu => 'Portefeuilles';

  @override
  String get walletsTitle => 'Portefeuilles';

  @override
  String get walletsEmpty =>
      'Aucun portefeuille pour l\'instant — ajoute le premier.';

  @override
  String get walletsAdd => 'Ajouter un portefeuille';

  @override
  String get walletsActive => 'Actif';

  @override
  String get walletsEdit => 'Modifier le portefeuille';

  @override
  String get walletsRemove => 'Retirer le portefeuille';

  @override
  String get walletsRemoveConfirm =>
      'Retirer ce portefeuille de cet appareil ? Ses entrées Mon contact seront effacées. Le portefeuille sur le serveur n\'est pas affecté.';

  @override
  String get walletsDuplicate => 'Ce portefeuille est déjà ajouté.';

  @override
  String get walletsActiveLabelTooltip => 'Touche pour changer de portefeuille';

  @override
  String get loginWalletNameLabel => 'Nom du portefeuille (facultatif)';

  @override
  String get loginWalletNameHint => 'Par défaut : le nom d\'hôte du serveur';
}
