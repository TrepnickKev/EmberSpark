// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'EmberSpark';

  @override
  String get appLocked => 'Kilitli';

  @override
  String get appUnlock => 'Kilidi aç';

  @override
  String get appTryAgain => 'Tekrar dene';

  @override
  String get appSetupFirstToast => 'Önce cüzdanı kur';

  @override
  String get commonCopy => 'Kopyala';

  @override
  String get commonCancel => 'İptal';

  @override
  String get commonDelete => 'Sil';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonContinue => 'Devam et';

  @override
  String get commonScanQr => 'QR tara';

  @override
  String get commonScan => 'Tara';

  @override
  String get commonShare => 'Paylaş';

  @override
  String get commonNfc => 'NFC';

  @override
  String get commonPaste => 'Yapıştır';

  @override
  String get commonImage => 'Görsel';

  @override
  String get commonRetry => 'Tekrar dene';

  @override
  String get commonEdit => 'Düzenle';

  @override
  String get commonAmount => 'Tutar (sats)';

  @override
  String get commonUnknownError => 'Bilinmeyen hata';

  @override
  String get receiveShareSubject => 'Lightning faturası';

  @override
  String get nfcHoldTag => 'Telefona bir NFC etiketi yaklaştır…';

  @override
  String get nfcWriteSuccess => 'Etikete yazıldı';

  @override
  String get nfcWriteFailed => 'Etikete yazılamadı';

  @override
  String get nfcReadFailed => 'Etiket okunamadı';

  @override
  String get nfcUnavailable => 'Bu cihazda NFC kullanılamıyor';

  @override
  String get imageNoQr => 'Görselde QR kodu bulunamadı';

  @override
  String get clipboardEmpty => 'Pano boş';

  @override
  String get homeScan => 'QR tara';

  @override
  String get homeSend => 'Gönder';

  @override
  String get homeReceive => 'Al';

  @override
  String get homeContacts => 'Kişiler';

  @override
  String get homeSettings => 'Ayarlar';

  @override
  String get homeLogout => 'Çıkış yap';

  @override
  String get homeMyContact => 'Kişi bilgim';

  @override
  String get homeBoltCard => 'Bolt Card';

  @override
  String homeSatsReceived(String amount) {
    return '$amount sats aldın';
  }

  @override
  String homeSatsSent(String amount) {
    return '$amount sats gönderdin';
  }

  @override
  String get homeSatsUnit => 'sats';

  @override
  String get boltCardTitle => 'Bolt Cards';

  @override
  String get boltCardExtensionMissing =>
      'Bu sunucuda Boltcards eklentisi yüklü değil.';

  @override
  String get boltCardNone =>
      'Henüz Bolt Card yok. Bir tane kurmak için Ekle\'ye dokun.';

  @override
  String get boltCardAdd => 'Bolt Card ekle';

  @override
  String get boltCardEdit => 'Kartı düzenle';

  @override
  String get boltCardName => 'Kart adı';

  @override
  String get boltCardTxLimit => 'Dokunuş başına limit (sats)';

  @override
  String get boltCardDailyLimit => 'Günlük limit (sats)';

  @override
  String get boltCardCreate => 'Oluştur';

  @override
  String get boltCardSave => 'Kaydet';

  @override
  String get boltCardProgram => 'Kartı programla';

  @override
  String get boltCardVerify => 'Doğrula';

  @override
  String get boltCardWipe => 'Sıfırla';

  @override
  String get boltCardDelete => 'Sil';

  @override
  String get boltCardEnable => 'Etkinleştir';

  @override
  String get boltCardDisable => 'Devre dışı bırak';

  @override
  String get boltCardEnabled => 'Etkin';

  @override
  String get boltCardDisabled => 'Devre dışı';

  @override
  String boltCardCounter(int count) {
    return '$count dokunuş';
  }

  @override
  String boltCardLimits(int tx, int daily) {
    return 'Dokunuş başına $tx sats, günlük $daily sats';
  }

  @override
  String get boltCardHoldToProgram =>
      'Programlamak için kartını telefona yaklaştır. İşlem bitene kadar çekme.';

  @override
  String get boltCardHoldToVerify => 'Okumak için kartını telefona yaklaştır.';

  @override
  String get boltCardHoldToWipe =>
      'Sıfırlamak için kartını telefona yaklaştır. İşlem bitene kadar çekme.';

  @override
  String get boltCardProgrammed => 'Kart programlandı.';

  @override
  String get boltCardProgramFailed => 'Kart programlanamadı.';

  @override
  String get boltCardNotBlank => 'Bu kart zaten programlanmış. Önce sıfırla.';

  @override
  String get boltCardUidAlreadyRegistered =>
      'Bu UID\'ye sahip bir Bolt Card sunucuda zaten kayıtlı. Mevcut kart kaydını sil ve tekrar dene.';

  @override
  String get boltCardVerifyNotProgrammed =>
      'Bu kart henüz programlanmamış, bu yüzden doğrulanacak bir şey yok.';

  @override
  String get boltCardVerified => 'Kart çalışıyor ve bu cüzdanı gösteriyor.';

  @override
  String get boltCardVerifiedBadge => 'Doğrulandı';

  @override
  String get boltCardVerifyWrongServer =>
      'Bu kart farklı bir sunucuyu gösteriyor.';

  @override
  String get boltCardVerifyUidMismatch =>
      'Bu kartın çip kimliği sunucu kaydıyla eşleşmiyor. Kartı sıfırla, sonra doğru kimliğin kaydedilmesi için yeniden ekleyip programla.';

  @override
  String get boltCardVerifyCounterBehind =>
      'Bu kartın dokunuş sayacı sunucunun gerisinde. Sıfırlamak için kartı yeniden programla.';

  @override
  String get boltCardTagLost =>
      'Kart çok erken uzaklaştırıldı. İşlem bitene kadar telefonun arkasına düz ve sabit tut, sonra tekrar dene.';

  @override
  String get boltCardChargeOnlyTitle => 'Bolt Card';

  @override
  String get boltCardChargeOnlyBody =>
      'Bir Bolt Card yalnızca tahsil edilebilir, ödeme yapılamaz. Tahsil etmek ister misin?';

  @override
  String get boltCardChargeAction => 'Tahsil et';

  @override
  String get boltCardVerifyFailed => 'Kart doğrulanamadı.';

  @override
  String get boltCardWipeConfirm =>
      'Bu kart fabrika anahtarlarına sıfırlansın mı? Yeniden programlayana kadar çalışmayı durduracak.';

  @override
  String get boltCardWiped => 'Kart fabrika anahtarlarına sıfırlandı.';

  @override
  String get boltCardWipeFailed => 'Kart sıfırlanamadı.';

  @override
  String get boltCardDeleteConfirm => 'Bu kart sunucudan silinsin mi?';

  @override
  String get loginTitle => 'Cüzdanı kur';

  @override
  String get loginUrlLabel => 'LNbits URL\'si';

  @override
  String get loginUrlHint => 'https://senin.node';

  @override
  String get loginAdminKeyLabel => 'Yönetici API anahtarı';

  @override
  String get loginAdminKeyHelper =>
      'Tam erişim için admin anahtarı veya salt okunur cüzdan için invoice/read anahtarı';

  @override
  String get loginAdminKeyRequired => 'Yönetici anahtarı gerekli';

  @override
  String get loginScanUrlTitle => 'LNbits URL\'sini tara';

  @override
  String get loginScanAdminTitle => 'Yönetici anahtarını tara';

  @override
  String get loginHint =>
      'QR kodunu LNbits → wallet → \"API info\" → Admin key yolunda bul.';

  @override
  String get disclaimerTitle => 'EmberSpark kimin için?';

  @override
  String get disclaimerBody =>
      'EmberSpark, kendi barındırdığın LNbits Lightning cüzdanları için bir istemcidir. Kendi LNbits sunucusunu çalıştıranlar ya da böyle birinin cüzdan erişimi verdiği kişiler içindir. Bu sen değilsen, bu uygulama sana uygun değildir.';

  @override
  String get disclaimerAck => 'Anladım';

  @override
  String get sendTitle => 'Gönder';

  @override
  String get sendBolt11Label => 'BOLT11 faturası';

  @override
  String get sendPay => 'Öde';

  @override
  String get sendPaymentSent => 'Ödeme gönderildi';

  @override
  String get sendPasteFirst => 'Önce bir fatura yapıştır';

  @override
  String get sendAnyAmount => 'Herhangi bir tutar';

  @override
  String sendAmountWithSats(String amount) {
    return '$amount sats';
  }

  @override
  String get sendToTitle => 'Şuraya gönder…';

  @override
  String get sendToInputLabel => 'Adres veya ödeme verisi';

  @override
  String get sendToInputHint => 'BOLT11, LNURL veya user@host';

  @override
  String get sendToScanTitle => 'Göndermek için tara';

  @override
  String get sendToContacts => 'Kişiler';

  @override
  String get sendToNoContacts => 'Henüz kişi yok';

  @override
  String get contactsSearchHint => 'Kişileri filtrele';

  @override
  String get contactsNoMatches => 'Eşleşen kişi yok';

  @override
  String get receiveTitle => 'Al';

  @override
  String get receiveReusableAddress => 'Yeniden kullanılabilir adresin';

  @override
  String get receiveAmount => 'Tutar';

  @override
  String get receiveMemo => 'Not';

  @override
  String get receiveCreateInvoice => 'Fatura oluştur';

  @override
  String get receiveInvoiceCopied => 'Fatura kopyalandı';

  @override
  String get receiveAmountError => 'Pozitif bir tutar gir';

  @override
  String get receiveEnterAmountFirst => 'Önce bir tutar girin';

  @override
  String receiveCardCharged(int sats) {
    return 'Karttan $sats sats çekildi';
  }

  @override
  String receiveSatsApprox(String amount) {
    return '≈ $amount sats';
  }

  @override
  String get receiveRatesUnavailable => 'Canlı kurlar yok — yalnızca sats';

  @override
  String get receiveCurrencySats => 'sats';

  @override
  String get contactsTitle => 'Kişiler';

  @override
  String get contactsEmpty => 'Henüz kişi yok — eklemek için + simgesine dokun';

  @override
  String contactsDeleteTitle(String name) {
    return '$name silinsin mi?';
  }

  @override
  String get contactsNew => 'Yeni kişi';

  @override
  String get contactsEdit => 'Kişiyi düzenle';

  @override
  String get contactsScanTitle => 'Hedefi tara';

  @override
  String get contactsName => 'Ad';

  @override
  String get contactsDestinationLabel => 'Lightning address, LNURL veya BOLT11';

  @override
  String get contactsRequired => 'Ad ve hedef gerekli';

  @override
  String get contactsInvalidDestination =>
      'Geçerli bir Lightning hedefi değil. Bir Lightning address (user@host.tld), BOLT11 faturası, BOLT12 teklifi/faturası (lno1…/lni1…) veya LNURL kullan.';

  @override
  String get contactsImport => 'Kişileri içe aktar';

  @override
  String get contactsExport => 'Kişileri dışa aktar';

  @override
  String get contactsExportEmpty => 'Dışa aktarılacak kişi yok';

  @override
  String get contactsShareSubject => 'EmberSpark kişileri';

  @override
  String get contactsImportFailed => 'Bu kişi dosyası okunamadı';

  @override
  String contactsImported(int count) {
    return '$count kişi içe aktarıldı';
  }

  @override
  String get historyTitle => 'Geçmiş';

  @override
  String get historyEmpty => 'Henüz işlem yok';

  @override
  String get historyPaymentDefault => 'Lightning ödemesi';

  @override
  String get historyPending => 'beklemede';

  @override
  String historyFee(String amount) {
    return 'ücret $amount';
  }

  @override
  String get historyDetailsTitle => 'İşlem';

  @override
  String get historyDirectionSent => 'Gönderildi';

  @override
  String get historyDirectionReceived => 'Alındı';

  @override
  String get historyStatusPaid => 'Ödendi';

  @override
  String get historyStatusPendingLabel => 'Beklemede';

  @override
  String get historyAmountLabel => 'Tutar';

  @override
  String get historyFeeLabel => 'Ücret';

  @override
  String get historyMemoLabel => 'Not';

  @override
  String get historyCommentLabel => 'Yorum';

  @override
  String get historyTimestampLabel => 'Zaman';

  @override
  String get historyPaymentHashLabel => 'Ödeme hash\'i';

  @override
  String get historyInvoiceLabel => 'Fatura';

  @override
  String get historyClose => 'Kapat';

  @override
  String get historyJustNow => 'az önce';

  @override
  String historyMinutesAgo(int minutes) {
    return '$minutes dk önce';
  }

  @override
  String historyHoursAgo(int hours) {
    return '$hours sa önce';
  }

  @override
  String historyDaysAgo(int days) {
    return '$days g önce';
  }

  @override
  String get lockedLabel => 'Kilitli';

  @override
  String get lockUnlock => 'Kilidi aç';

  @override
  String get lockTryAgain => 'Tekrar dene';

  @override
  String get lnurlTitleAuthenticate => 'Kimlik doğrula';

  @override
  String get lnurlTitlePay => 'Gönder (LNURL)';

  @override
  String get lnurlTitleWithdraw => 'Al (LNURL)';

  @override
  String get lnurlTitleGeneric => 'LNURL';

  @override
  String get lnurlResolvedExplain =>
      'Çözümlenen URL — sunucunun cüzdan dışında yanıt verip vermediğini görmek için bunu bir tarayıcıya yapıştır:';

  @override
  String get lnurlCopyUrl => 'URL\'yi kopyala';

  @override
  String get lnurlUrlCopied => 'URL kopyalandı';

  @override
  String lnurlAuthRegisterAt(String host) {
    return '$host adresinde kayıt ol';
  }

  @override
  String lnurlAuthLinkAt(String host) {
    return '$host adresinde hesabını bağla';
  }

  @override
  String lnurlAuthAuthenticateAt(String host) {
    return '$host adresinde kimlik doğrula';
  }

  @override
  String lnurlAuthLoginAt(String host) {
    return '$host adresine giriş yap';
  }

  @override
  String get lnurlAuthExplain =>
      'Bu site için benzersiz bir imzalama anahtarı cüzdan tohumundan türetilecek. Site yalnızca genel anahtarını görür — cüzdanın ve bakiyen gizli kalır.';

  @override
  String get lnurlAuthConfirm => 'Onayla';

  @override
  String lnurlAuthSuccess(String host) {
    return '$host ile kimlik doğrulandı';
  }

  @override
  String lnurlAmountRange(int min, int max) {
    return 'Aralık: $min – $max sats';
  }

  @override
  String lnurlAmountOutOfRange(int min, int max) {
    return 'Tutar $min ile $max sats arasında olmalı';
  }

  @override
  String get lnurlAmountPositive => 'Pozitif bir tutar gir';

  @override
  String get lnurlGetAndPay => 'Gönder';

  @override
  String get lnurlWithdraw => 'Çek';

  @override
  String get lnurlWithdrawDefaultMemo => 'LNURL-withdraw';

  @override
  String lnurlWithdrawing(int amount) {
    return '$amount sats çekiliyor…';
  }

  @override
  String get lnurlCommentLabel => 'Not (isteğe bağlı)';

  @override
  String lnurlCommentHelp(int max) {
    return 'En fazla $max karakter';
  }

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLanguageSubtitle => 'Uygulama dilini seç';

  @override
  String get languageSystemDefault => 'Sistem varsayılanı';

  @override
  String get settingsDisplayCurrency => 'Görüntüleme para birimi';

  @override
  String get settingsDisplayCurrencySubtitle =>
      'Bakiyenin altındaki fiat tutarı için kullanılır';

  @override
  String get settingsLockOnLaunch => 'Açılışta uygulamayı kilitle';

  @override
  String get settingsLockSubtitleEnabled =>
      'EmberSpark\'ı açmak için biyometrik veya cihaz PIN\'i/deseni gerektirir.';

  @override
  String get settingsLockSubtitleUnavailable =>
      'Bu cihazda ekran kilidi ayarlı değil. Bu seçeneği etkinleştirmek için sistem ayarlarından bir tane ayarla.';

  @override
  String get settingsLockConfirmReason =>
      'Uygulama kilidini etkinleştirmek için onayla';

  @override
  String get settingsLockNeedSetup =>
      'Önce telefonunda bir ekran kilidi veya biyometri ayarla.';

  @override
  String get settingsTrustTls => 'Doğrulanmamış HTTPS\'e izin ver';

  @override
  String get settingsTrustTlsSubtitle =>
      'Kendinden imzalı ve zinciri eksik sertifikalara güven. Bazı amatör Lightning sunucuları ve .onion hizmetleri için gerekli. Yalnızca güvendiğin sunucular için etkinleştir.';

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get aboutTitle => 'Hakkında';

  @override
  String get aboutTagline => 'LNbits için hafif bir Lightning cüzdanı';

  @override
  String get aboutCopyright => '© 2026 Trepnick Solutions';

  @override
  String get aboutVersionLabel => 'Sürüm';

  @override
  String get aboutCheckAgain => 'Tekrar kontrol et';

  @override
  String get aboutCheckingForUpdates => 'Güncellemeler kontrol ediliyor…';

  @override
  String get aboutUpToDate => 'Güncel';

  @override
  String aboutUpdateAvailable(String version) {
    return 'Güncelleme mevcut: v$version';
  }

  @override
  String get aboutOpenRelease => 'Sürümü aç';

  @override
  String get aboutCheckFailed => 'Güncellemeler kontrol edilemedi';

  @override
  String get aboutUpdatesViaStore =>
      'Güncellemeler Google Play tarafından yönetilir';

  @override
  String get aboutSupportDevelopment => 'Geliştirmeyi destekle';

  @override
  String get aboutSupportBody =>
      'EmberSpark boş zamanlarda geliştirilir ve bakımı yapılır. Sats\'larını yönetmeni kolaylaştırıyorsa, aşağıdaki adrese birkaç on-chain BTC göndermeyi düşün. Her katkı projeyi ayakta tutar. Teşekkürler! GitHub\'da hata bildirmek veya özellik istemek de aynı derecede memnuniyetle karşılanır.';

  @override
  String get aboutDonateMethods => 'Lightning / On-Chain ile bağış yap';

  @override
  String get aboutContributeOnGithub => 'GitHub\'da katkıda bulun';

  @override
  String get aboutCopyAddress => 'Adresi kopyala';

  @override
  String get aboutAddressCopied => 'Adres kopyalandı';

  @override
  String get aboutLicensesTitle => 'Açık kaynak lisansları';

  @override
  String get aboutLicensesSubtitle => 'Flutter SDK ve üçüncü taraf paketler';

  @override
  String get errorTlsCertificate =>
      'Sunucunun TLS sertifikası doğrulanamadı.\nBu sunucuya güveniyorsan Ayarlar\'da \'Doğrulanmamış HTTPS\'e izin ver\'i etkinleştir.';

  @override
  String get errorTlsHandshake =>
      'Sunucuyla güvenli bir bağlantı kurulamadı.\nSunucu güncel olmayan bir TLS sürümü kullanıyor olabilir veya sertifikası geçersiz.\nSunucuya güveniyorsan Ayarlar\'da \'Doğrulanmamış HTTPS\'e izin ver\'i dene.';

  @override
  String get errorHostLookup =>
      'LNbits ana bilgisayar adı çözümlenemedi.\nURL\'yi ve ağ bağlantını kontrol et.';

  @override
  String get errorConnectionRefused =>
      'LNbits sunucusu bağlantıyı reddetti.\nURL\'yi ve sunucunun çalışıp çalışmadığını kontrol et.';

  @override
  String get errorConnectionDropped =>
      'LNbits sunucusuyla bağlantı koptu. Tekrar dene.';

  @override
  String get errorNetworkUnreachable =>
      'Ağ bağlantısı yok. Wi-Fi / mobil veriyi kontrol et.';

  @override
  String get errorSocket => 'LNbits sunucusuna ulaşılamadı. Ağını kontrol et.';

  @override
  String get errorTimeout => 'Sunucu zamanında yanıt vermedi. Tekrar dene.';

  @override
  String get error401 =>
      'Kimlik doğrulama başarısız. Yönetici / fatura API anahtarlarını kontrol et.';

  @override
  String get error403 =>
      'Sunucu erişimi reddetti. Kupon zaten kullanılmış olabilir veya IP\'n engellenmiş olabilir.';

  @override
  String get error404 =>
      'Uç nokta bulunamadı. LNbits URL\'sinin doğru olduğunu kontrol et.';

  @override
  String get error500 =>
      'LNbits sunucu hatası. LNbits günlüklerini kontrol et.';

  @override
  String get error502 => 'LNbits, proxy\'si üzerinden erişilemiyor.';

  @override
  String get error503 => 'LNbits geçici olarak kullanılamıyor.';

  @override
  String get error520 =>
      'LNbits\'te yapılandırılmış bir Lightning arka ucu yok (VoidWallet). LNbits → Server → Funding yolundan bir Lightning düğümü bağla.';

  @override
  String get errorInsufficientFunds =>
      'Bu ödeme için cüzdanında yeterli sats yok.';

  @override
  String get errorSelfPayment =>
      'Bu fatura bu cüzdana ait. Kendine ödeme yapamazsın.';

  @override
  String get errorNotLnurl => 'Bu bağlantı geçerli bir LNURL hizmeti değil';

  @override
  String get errorReadOnlyWallet =>
      'Bu salt okunur bir cüzdan. Yalnızca alabilir, gönderemez.';

  @override
  String get walletReadOnly => 'Salt okunur';

  @override
  String get errorLnurlInsecureCallback =>
      'LNbits sunucusu güvensiz bir (http://) geri çağırma URL\'si döndürdü. Bu genellikle LNbits\'in ters proxy arkasında olduğu ve genel HTTPS adresini bilmediği anlamına gelir. LNbits ana bilgisayarında .env içinde LNBITS_BASE_URL=https://senin-host ayarla ve yeniden başlat. Alternatif olarak, proxy\'yi X-Forwarded-Proto: https iletecek şekilde yapılandır.';

  @override
  String errorServerGeneric(String code) {
    return 'Sunucu hatası ($code).';
  }

  @override
  String get lnurlAuthErrorKeyInUse =>
      'Bu kimlik doğrulama anahtarı bu site için zaten kullanılıyor. Biraz bekleyip tekrar dene veya giriş QR\'ını yeniden yükle.';

  @override
  String get lnurlAuthErrorInvalidSignature =>
      'Site kimlik doğrulama imzasını reddetti. Lütfen tekrar dene.';

  @override
  String get lnurlAuthErrorLinkingKeyMismatch =>
      'Site bu kimlik doğrulama anahtarını tanımıyor. Bu genellikle daha önce farklı bir cüzdan tohumuyla kimlik doğruladığın anlamına gelir.';

  @override
  String lnurlAuthErrorGeneric(String reason) {
    return 'LNURL-auth başarısız: $reason';
  }

  @override
  String get bolt12TitlePayOffer => 'BOLT12 teklifini öde';

  @override
  String get bolt12TitlePayInvoice => 'BOLT12 faturasını öde';

  @override
  String get bolt12AmountLabel => 'Tutar (sats)';

  @override
  String get bolt12MemoLabel => 'Ödeyen notu (isteğe bağlı)';

  @override
  String get bolt12RawStringLabel => 'BOLT12 dizesi';

  @override
  String get bolt12NotSupported =>
      'Bu LNbits sunucusu BOLT12\'yi desteklemiyor. Lightning düğümün BOLT12\'yi anlamıyor olabilir veya LNbits BOLT12 eklentisi yüklü değil.';

  @override
  String get myContactTitle => 'Kişi bilgim';

  @override
  String get myContactLnAddressSection => 'Lightning Address';

  @override
  String get myContactBolt12Section => 'BOLT12 teklifi';

  @override
  String get myContactAddLnAddress => 'Lightning address\'ini ekle';

  @override
  String get myContactAddBolt12 => 'BOLT12 teklifini ekle';

  @override
  String get myContactLnAddressHint =>
      'user@domain. Alan adı LNbits sunucusuysa EmberSpark onu orada ayarlar; değilse olduğu gibi kaydedilir.';

  @override
  String get myContactBolt12Hint =>
      'lno1… — Lightning düğümünün oluşturduğu teklifi yapıştır.';

  @override
  String get myContactInvalidLnAddress =>
      'Geçerli bir Lightning address değil.';

  @override
  String get myContactInvalidBolt12 => 'Geçerli bir BOLT12 teklifi değil.';

  @override
  String get myContactCopied => 'Kopyalandı';

  @override
  String get myContactShareSubject => 'Lightning kişi bilgim';

  @override
  String get myContactRemoveConfirm => 'Bu giriş kaldırılsın mı?';

  @override
  String get myContactAutoGenerate => 'Otomatik oluştur';

  @override
  String get myContactLnurlpSection => 'LNURL-pay bağlantısı';

  @override
  String get myContactAddLnurlp => 'LNURL-pay bağlantını ekle';

  @override
  String get myContactLnurlpHint =>
      'lnurl1… — bağlantını yapıştır veya LNbits sunucusundan otomatik oluştur.';

  @override
  String get myContactInvalidLnurlp =>
      'Geçerli bir LNURL-pay bağlantısı değil.';

  @override
  String get myContactGenerating => 'Oluşturuluyor…';

  @override
  String get myContactLnurlpExtensionMissing =>
      'LNbits\'te LNURL-pay eklentisi yüklü değil.';

  @override
  String get myContactLnAddressServerUpdated =>
      'Lightning Address sunucuda güncellendi.';

  @override
  String get myContactBolt12ExtensionMissing =>
      'LNbits\'te BOLT12 eklentisi yüklü değil veya Lightning düğümün BOLT12\'yi desteklemiyor.';

  @override
  String get myContactAvatarPriority =>
      'Profil avatarın bu tanımlayıcılardan biriyle oluşturulur. Hangisi olacağını seçmek için bir yıldıza dokun. Aksi halde önce Lightning address, sonra BOLT12, sonra LNURL kullanılır.';

  @override
  String get myContactSetDefault => 'Varsayılan kimlik olarak ayarla';

  @override
  String get myContactUnsetDefault => 'Varsayılan kimlikten kaldır';

  @override
  String get myContactTabLnAddress => 'LN Address';

  @override
  String get myContactTabLnurlp => 'LNURL';

  @override
  String get myContactTabBolt12 => 'BOLT12';

  @override
  String get myContactLnAddressUse => 'Arkadaşlar ve aileyle paylaşması kolay.';

  @override
  String get myContactLnurlpUse =>
      'Daha az tanımlayıcı bech32 dizesi, ama aynı sunucu üzerinden yönlendirir.';

  @override
  String get myContactBolt12Use =>
      'En iyi gizlilik: ödemeler doğrudan Lightning üzerinden gider, aradaki bir alan adı operatörü olmadan.';

  @override
  String get walletsMenu => 'Cüzdanlar';

  @override
  String get walletsTitle => 'Cüzdanlar';

  @override
  String get walletsEmpty => 'Henüz cüzdan yok — ilkini ekle.';

  @override
  String get walletsAdd => 'Cüzdan ekle';

  @override
  String get walletsActive => 'Aktif';

  @override
  String get walletsEdit => 'Cüzdanı düzenle';

  @override
  String get walletsRemove => 'Cüzdanı kaldır';

  @override
  String get walletsRemoveConfirm =>
      'Bu cüzdan bu cihazdan kaldırılsın mı? Kişi bilgim girişleri temizlenecek. Sunucudaki cüzdan etkilenmez.';

  @override
  String get walletsDuplicate => 'Bu cüzdan zaten eklenmiş.';

  @override
  String get walletsActiveLabelTooltip => 'Cüzdan değiştirmek için dokun';

  @override
  String get loginWalletNameLabel => 'Cüzdan adı (isteğe bağlı)';

  @override
  String get loginWalletNameHint =>
      'Varsayılan olarak sunucu ana bilgisayar adı';
}
