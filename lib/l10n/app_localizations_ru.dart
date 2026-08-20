// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'EmberSpark';

  @override
  String get appLocked => 'Заблокировано';

  @override
  String get appUnlock => 'Разблокировать';

  @override
  String get appTryAgain => 'Повторить';

  @override
  String get appSetupFirstToast => 'Сначала настрой кошелёк';

  @override
  String get commonCopy => 'Копировать';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonContinue => 'Продолжить';

  @override
  String get commonScanQr => 'Сканировать QR';

  @override
  String get commonScan => 'Сканировать';

  @override
  String get commonShare => 'Поделиться';

  @override
  String get commonNfc => 'NFC';

  @override
  String get commonPaste => 'Вставить';

  @override
  String get commonImage => 'Изображение';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonEdit => 'Изменить';

  @override
  String get commonAmount => 'Сумма (sats)';

  @override
  String get commonUnknownError => 'Неизвестная ошибка';

  @override
  String get receiveShareSubject => 'Счёт Lightning';

  @override
  String get nfcHoldTag => 'Поднеси NFC-метку к телефону…';

  @override
  String get nfcWriteSuccess => 'Записано на метку';

  @override
  String get nfcWriteFailed => 'Не удалось записать на метку';

  @override
  String get nfcReadFailed => 'Не удалось прочитать метку';

  @override
  String get nfcUnavailable => 'NFC недоступен на этом устройстве';

  @override
  String get imageNoQr => 'QR-код на изображении не найден';

  @override
  String get clipboardEmpty => 'Буфер обмена пуст';

  @override
  String get homeScan => 'Сканировать QR';

  @override
  String get homeSend => 'Отправить';

  @override
  String get homeReceive => 'Получить';

  @override
  String get homeContacts => 'Контакты';

  @override
  String get homeSettings => 'Настройки';

  @override
  String get homeLogout => 'Выйти';

  @override
  String get homeMyContact => 'Мой контакт';

  @override
  String get homeBoltCard => 'Bolt Card';

  @override
  String homeSatsReceived(String amount) {
    return 'Получено $amount sats';
  }

  @override
  String homeSatsSent(String amount) {
    return 'Отправлено $amount sats';
  }

  @override
  String get homeSatsUnit => 'sats';

  @override
  String get boltCardTitle => 'Bolt Cards';

  @override
  String get boltCardExtensionMissing =>
      'Расширение Boltcards не установлено на этом сервере.';

  @override
  String get boltCardNone =>
      'Пока нет ни одной Bolt Card. Нажми «Добавить», чтобы настроить.';

  @override
  String get boltCardAdd => 'Добавить Bolt Card';

  @override
  String get boltCardEdit => 'Изменить карту';

  @override
  String get boltCardName => 'Название карты';

  @override
  String get boltCardTxLimit => 'Лимит на касание (sats)';

  @override
  String get boltCardDailyLimit => 'Дневной лимит (sats)';

  @override
  String get boltCardCreate => 'Создать';

  @override
  String get boltCardSave => 'Сохранить';

  @override
  String get boltCardProgram => 'Запрограммировать карту';

  @override
  String get boltCardVerify => 'Проверить';

  @override
  String get boltCardWipe => 'Сбросить';

  @override
  String get boltCardDelete => 'Удалить';

  @override
  String get boltCardEnable => 'Включить';

  @override
  String get boltCardDisable => 'Отключить';

  @override
  String get boltCardEnabled => 'Включена';

  @override
  String get boltCardDisabled => 'Отключена';

  @override
  String boltCardCounter(int count) {
    return '$count касаний';
  }

  @override
  String boltCardLimits(int tx, int daily) {
    return 'За касание $tx sats, в день $daily sats';
  }

  @override
  String get boltCardHoldToProgram =>
      'Поднеси карту к телефону, чтобы запрограммировать её. Не убирай, пока не завершится.';

  @override
  String get boltCardHoldToVerify =>
      'Поднеси карту к телефону, чтобы прочитать её.';

  @override
  String get boltCardHoldToWipe =>
      'Поднеси карту к телефону, чтобы сбросить её. Не убирай, пока не завершится.';

  @override
  String get boltCardProgrammed => 'Карта запрограммирована.';

  @override
  String get boltCardProgramFailed => 'Не удалось запрограммировать карту.';

  @override
  String get boltCardNotBlank =>
      'Эта карта уже запрограммирована. Сначала сбрось её.';

  @override
  String get boltCardUidAlreadyRegistered =>
      'Bolt Card с этим UID уже зарегистрирована на сервере. Удали существующую запись карты и попробуй снова.';

  @override
  String get boltCardVerifyNotProgrammed =>
      'Эта карта ещё не запрограммирована, поэтому проверять нечего.';

  @override
  String get boltCardVerified => 'Карта работает и указывает на этот кошелёк.';

  @override
  String get boltCardVerifiedBadge => 'Проверено';

  @override
  String get boltCardVerifyWrongServer =>
      'Эта карта указывает на другой сервер.';

  @override
  String get boltCardVerifyUidMismatch =>
      'ID чипа этой карты не совпадает с записью на сервере. Сбрось карту, затем добавь и запрограммируй её заново, чтобы сохранился правильный ID.';

  @override
  String get boltCardVerifyCounterBehind =>
      'Счётчик касаний этой карты отстаёт от сервера. Перепрограммируй карту, чтобы сбросить его.';

  @override
  String get boltCardTagLost =>
      'Карту убрали слишком рано. Держи её плоско у задней части телефона и неподвижно до конца операции, затем попробуй снова.';

  @override
  String get boltCardChargeOnlyTitle => 'Bolt Card';

  @override
  String get boltCardChargeOnlyBody =>
      'С Bolt Card можно только списать, но не оплатить ей. Хочешь списать?';

  @override
  String get boltCardChargeAction => 'Списать';

  @override
  String get boltCardVerifyFailed => 'Не удалось проверить карту.';

  @override
  String get boltCardWipeConfirm =>
      'Сбросить эту карту к заводским ключам? Она перестанет работать, пока ты не запрограммируешь её снова.';

  @override
  String get boltCardWiped => 'Карта сброшена к заводским ключам.';

  @override
  String get boltCardWipeFailed => 'Не удалось сбросить карту.';

  @override
  String get boltCardDeleteConfirm => 'Удалить эту карту с сервера?';

  @override
  String get loginTitle => 'Настройка кошелька';

  @override
  String get loginUrlLabel => 'URL LNbits';

  @override
  String get loginUrlHint => 'https://твой.узел';

  @override
  String get loginAdminKeyLabel => 'Админ-ключ API';

  @override
  String get loginAdminKeyHelper =>
      'Admin-ключ для полного доступа или invoice/read-ключ для кошелька только для чтения';

  @override
  String get loginAdminKeyRequired => 'Требуется админ-ключ';

  @override
  String get loginScanUrlTitle => 'Сканировать URL LNbits';

  @override
  String get loginScanAdminTitle => 'Сканировать админ-ключ';

  @override
  String get loginHint =>
      'Найди QR-код в LNbits → wallet → \"API info\" → Admin key.';

  @override
  String get disclaimerTitle => 'Для кого EmberSpark?';

  @override
  String get disclaimerBody =>
      'EmberSpark — это клиент для самостоятельно размещённых кошельков Lightning на LNbits. Он для тех, кто держит собственный сервер LNbits, или кому доступ к кошельку дал тот, у кого он есть. Если это не про тебя, это приложение тебе не подходит.';

  @override
  String get disclaimerAck => 'Понятно';

  @override
  String get sendTitle => 'Отправить';

  @override
  String get sendBolt11Label => 'Счёт BOLT11';

  @override
  String get sendPay => 'Оплатить';

  @override
  String get sendPaymentSent => 'Платёж отправлен';

  @override
  String get sendPasteFirst => 'Сначала вставь счёт';

  @override
  String get sendAnyAmount => 'Любая сумма';

  @override
  String sendAmountWithSats(String amount) {
    return '$amount sats';
  }

  @override
  String get sendToTitle => 'Отправить…';

  @override
  String get sendToInputLabel => 'Адрес или платёжные данные';

  @override
  String get sendToInputHint => 'BOLT11, LNURL или user@host';

  @override
  String get sendToScanTitle => 'Сканировать для отправки';

  @override
  String get sendToContacts => 'Контакты';

  @override
  String get sendToNoContacts => 'Пока нет контактов';

  @override
  String get contactsSearchHint => 'Фильтровать контакты';

  @override
  String get contactsNoMatches => 'Нет подходящих контактов';

  @override
  String get receiveTitle => 'Получить';

  @override
  String get receiveReusableAddress => 'Твой многоразовый адрес';

  @override
  String get receiveAmount => 'Сумма';

  @override
  String get receiveMemo => 'Заметка';

  @override
  String get receiveCreateInvoice => 'Создать счёт';

  @override
  String get receiveInvoiceCopied => 'Счёт скопирован';

  @override
  String get receiveAmountError => 'Введи положительную сумму';

  @override
  String get receiveEnterAmountFirst => 'Сначала введи сумму';

  @override
  String receiveCardCharged(int sats) {
    return 'Списано $sats sats с карты';
  }

  @override
  String receiveSatsApprox(String amount) {
    return '≈ $amount sats';
  }

  @override
  String get receiveRatesUnavailable =>
      'Актуальные курсы недоступны — только sats';

  @override
  String get receiveCurrencySats => 'sats';

  @override
  String get contactsTitle => 'Контакты';

  @override
  String get contactsEmpty => 'Пока нет контактов — нажми +, чтобы добавить';

  @override
  String contactsDeleteTitle(String name) {
    return 'Удалить $name?';
  }

  @override
  String get contactsNew => 'Новый контакт';

  @override
  String get contactsEdit => 'Изменить контакт';

  @override
  String get contactsScanTitle => 'Сканировать назначение';

  @override
  String get contactsName => 'Имя';

  @override
  String get contactsDestinationLabel => 'Lightning address, LNURL или BOLT11';

  @override
  String get contactsRequired => 'Нужны имя и назначение';

  @override
  String get contactsInvalidDestination =>
      'Недопустимое назначение Lightning. Используй Lightning address (user@host.tld), счёт BOLT11, оффер/счёт BOLT12 (lno1…/lni1…) или LNURL.';

  @override
  String get contactsImport => 'Импортировать контакты';

  @override
  String get contactsExport => 'Экспортировать контакты';

  @override
  String get contactsExportEmpty => 'Нет контактов для экспорта';

  @override
  String get contactsShareSubject => 'Контакты EmberSpark';

  @override
  String get contactsImportFailed => 'Не удалось прочитать этот файл контактов';

  @override
  String contactsImported(int count) {
    return 'Импортировано контактов: $count';
  }

  @override
  String get historyTitle => 'История';

  @override
  String get historyEmpty => 'Пока нет транзакций';

  @override
  String get historySearchHint => 'Search payments';

  @override
  String get historyNoResults => 'No matching payments';

  @override
  String get historyPaymentDefault => 'Платёж Lightning';

  @override
  String get historyPending => 'в ожидании';

  @override
  String historyFee(String amount) {
    return 'комиссия $amount';
  }

  @override
  String get historyDetailsTitle => 'Транзакция';

  @override
  String get historyDirectionSent => 'Отправлено';

  @override
  String get historyDirectionReceived => 'Получено';

  @override
  String get historyStatusPaid => 'Оплачено';

  @override
  String get historyStatusPendingLabel => 'В ожидании';

  @override
  String get historyAmountLabel => 'Сумма';

  @override
  String get historyValueNow => 'Value now';

  @override
  String get historyValueThen => 'Value at the time';

  @override
  String get historyFeeLabel => 'Комиссия';

  @override
  String get historyMemoLabel => 'Заметка';

  @override
  String get historyCommentLabel => 'Комментарий';

  @override
  String get historyTimestampLabel => 'Время';

  @override
  String get historyPaymentHashLabel => 'Хеш платежа';

  @override
  String get historyInvoiceLabel => 'Счёт';

  @override
  String get historyClose => 'Закрыть';

  @override
  String get historyJustNow => 'только что';

  @override
  String historyMinutesAgo(int minutes) {
    return '$minutes мин назад';
  }

  @override
  String historyHoursAgo(int hours) {
    return '$hours ч назад';
  }

  @override
  String historyDaysAgo(int days) {
    return '$days дн назад';
  }

  @override
  String get lockedLabel => 'Заблокировано';

  @override
  String get lockUnlock => 'Разблокировать';

  @override
  String get lockTryAgain => 'Повторить';

  @override
  String get lnurlTitleAuthenticate => 'Аутентификация';

  @override
  String get lnurlTitlePay => 'Отправить (LNURL)';

  @override
  String get lnurlTitleWithdraw => 'Получить (LNURL)';

  @override
  String get lnurlTitleGeneric => 'LNURL';

  @override
  String get lnurlResolvedExplain =>
      'Разрешённый URL — вставь его в браузер, чтобы проверить, отвечает ли сервер вне кошелька:';

  @override
  String get lnurlCopyUrl => 'Копировать URL';

  @override
  String get lnurlUrlCopied => 'URL скопирован';

  @override
  String lnurlAuthRegisterAt(String host) {
    return 'Зарегистрируйся на $host';
  }

  @override
  String lnurlAuthLinkAt(String host) {
    return 'Привяжи аккаунт на $host';
  }

  @override
  String lnurlAuthAuthenticateAt(String host) {
    return 'Пройди аутентификацию на $host';
  }

  @override
  String lnurlAuthLoginAt(String host) {
    return 'Войди на $host';
  }

  @override
  String get lnurlAuthExplain =>
      'Уникальный ключ подписи для этого сайта будет получен из seed твоего кошелька. Сайт видит только твой публичный ключ — кошелёк и баланс остаются приватными.';

  @override
  String get lnurlAuthConfirm => 'Подтвердить';

  @override
  String lnurlAuthSuccess(String host) {
    return 'Аутентификация на $host выполнена';
  }

  @override
  String lnurlAmountRange(int min, int max) {
    return 'Диапазон: $min – $max sats';
  }

  @override
  String lnurlAmountOutOfRange(int min, int max) {
    return 'Сумма должна быть от $min до $max sats';
  }

  @override
  String get lnurlAmountPositive => 'Введи положительную сумму';

  @override
  String get lnurlGetAndPay => 'Отправить';

  @override
  String get lnurlWithdraw => 'Вывести';

  @override
  String get lnurlWithdrawDefaultMemo => 'LNURL-withdraw';

  @override
  String lnurlWithdrawing(int amount) {
    return 'Вывод $amount sats…';
  }

  @override
  String get lnurlCommentLabel => 'Заметка (необязательно)';

  @override
  String lnurlCommentHelp(int max) {
    return 'Не более $max символов';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSubtitle => 'Выбери язык приложения';

  @override
  String get languageSystemDefault => 'Системный по умолчанию';

  @override
  String get settingsDisplayCurrency => 'Отображаемая валюта';

  @override
  String get settingsDisplayCurrencySubtitle =>
      'Используется для суммы в фиате под балансом';

  @override
  String get settingsLockOnLaunch => 'Блокировать при запуске';

  @override
  String get settingsLockSubtitleEnabled =>
      'Требовать биометрию или PIN/графический ключ устройства для открытия EmberSpark.';

  @override
  String get settingsLockSubtitleUnavailable =>
      'На этом устройстве не настроена блокировка экрана. Настрой её в системных настройках, чтобы включить эту опцию.';

  @override
  String get settingsLockConfirmReason =>
      'Подтверди, чтобы включить блокировку приложения';

  @override
  String get settingsLockNeedSetup =>
      'Сначала настрой блокировку экрана или биометрию на телефоне.';

  @override
  String get settingsTrustTls => 'Разрешить непроверенный HTTPS';

  @override
  String get settingsTrustTlsSubtitle =>
      'Доверять самоподписанным сертификатам и с неполной цепочкой. Нужно для некоторых любительских серверов Lightning и сервисов .onion. Включай только для серверов, которым доверяешь.';

  @override
  String get settingsAbout => 'О приложении';

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
  String get aboutTitle => 'О приложении';

  @override
  String get aboutTagline => 'Лёгкий кошелёк Lightning для LNbits';

  @override
  String get aboutCopyright => '© 2026 Trepnick Solutions';

  @override
  String get aboutVersionLabel => 'Версия';

  @override
  String get aboutCheckAgain => 'Проверить снова';

  @override
  String get aboutCheckingForUpdates => 'Проверка обновлений…';

  @override
  String get aboutUpToDate => 'Актуальная версия';

  @override
  String aboutUpdateAvailable(String version) {
    return 'Доступно обновление: v$version';
  }

  @override
  String get aboutOpenRelease => 'Открыть релиз';

  @override
  String get aboutCheckFailed => 'Не удалось проверить обновления';

  @override
  String get aboutUpdatesViaStore => 'Обновлениями управляет Google Play';

  @override
  String get aboutSupportDevelopment => 'Поддержать разработку';

  @override
  String get aboutSupportBody =>
      'EmberSpark создаётся и поддерживается в свободное время. Если он упрощает управление твоими sats, отправь немного on-chain BTC на адрес ниже. Каждый вклад поддерживает проект. Спасибо! Сообщения об ошибках и предложения функций на GitHub так же приветствуются.';

  @override
  String get aboutDonateMethods => 'Поддержать через Lightning / On-Chain';

  @override
  String get aboutContributeOnGithub => 'Внести вклад на GitHub';

  @override
  String get aboutCopyAddress => 'Копировать адрес';

  @override
  String get aboutAddressCopied => 'Адрес скопирован';

  @override
  String get aboutLicensesTitle => 'Лицензии с открытым кодом';

  @override
  String get aboutLicensesSubtitle => 'Flutter SDK и сторонние пакеты';

  @override
  String get errorTlsCertificate =>
      'Не удалось проверить TLS-сертификат сервера.\nЕсли ты доверяешь этому серверу, включи «Разрешить непроверенный HTTPS» в Настройках.';

  @override
  String get errorTlsHandshake =>
      'Не удалось установить безопасное соединение с сервером.\nСервер может использовать устаревшую версию TLS, или его сертификат недействителен.\nЕсли ты доверяешь серверу, попробуй «Разрешить непроверенный HTTPS» в Настройках.';

  @override
  String get errorHostLookup =>
      'Не удалось разрешить имя хоста LNbits.\nПроверь URL и сетевое соединение.';

  @override
  String get errorConnectionRefused =>
      'Сервер LNbits отклонил соединение.\nПроверь URL и что сервер запущен.';

  @override
  String get errorConnectionDropped =>
      'Соединение с сервером LNbits разорвано. Повтори попытку.';

  @override
  String get errorNetworkUnreachable =>
      'Нет сетевого соединения. Проверь Wi-Fi / мобильные данные.';

  @override
  String get errorSocket =>
      'Не удалось связаться с сервером LNbits. Проверь свою сеть.';

  @override
  String get errorTimeout => 'Сервер не ответил вовремя. Повтори попытку.';

  @override
  String get error401 =>
      'Ошибка аутентификации. Проверь свои админ / invoice API-ключи.';

  @override
  String get error403 =>
      'Сервер отказал в доступе. Возможно, ваучер уже использован, или твой IP заблокирован.';

  @override
  String get error404 => 'Эндпоинт не найден. Проверь, что URL LNbits верный.';

  @override
  String get error500 => 'Ошибка сервера LNbits. Проверь логи LNbits.';

  @override
  String get error502 => 'LNbits недоступен через свой прокси.';

  @override
  String get error503 => 'LNbits временно недоступен.';

  @override
  String get error520 =>
      'В LNbits не настроен бэкенд Lightning (VoidWallet). Подключи узел Lightning в LNbits → Server → Funding.';

  @override
  String get errorInsufficientFunds =>
      'В твоём кошельке недостаточно sats для этого платежа.';

  @override
  String get errorSelfPayment =>
      'Этот счёт создан этим же кошельком. Нельзя платить самому себе.';

  @override
  String get errorNotLnurl =>
      'Эта ссылка не является действительным сервисом LNURL';

  @override
  String get errorReadOnlyWallet =>
      'Это кошелёк только для чтения. Он может только получать, но не отправлять.';

  @override
  String get walletReadOnly => 'Только чтение';

  @override
  String get errorLnurlInsecureCallback =>
      'Сервер LNbits вернул небезопасный (http://) callback-URL. Обычно это значит, что LNbits находится за обратным прокси и не знает свой публичный HTTPS-адрес. На хосте LNbits задай LNBITS_BASE_URL=https://твой-host в .env и перезапусти. Либо настрой прокси на передачу X-Forwarded-Proto: https.';

  @override
  String errorServerGeneric(String code) {
    return 'Ошибка сервера ($code).';
  }

  @override
  String get lnurlAuthErrorKeyInUse =>
      'Этот ключ аутентификации уже используется для этого сайта. Подожди немного и повтори, или обнови QR-код входа.';

  @override
  String get lnurlAuthErrorInvalidSignature =>
      'Сайт отклонил подпись аутентификации. Повтори попытку.';

  @override
  String get lnurlAuthErrorLinkingKeyMismatch =>
      'Сайт не распознаёт этот ключ аутентификации. Обычно это значит, что раньше ты проходил аутентификацию с другим seed кошелька.';

  @override
  String lnurlAuthErrorGeneric(String reason) {
    return 'Ошибка LNURL-auth: $reason';
  }

  @override
  String get bolt12TitlePayOffer => 'Оплатить оффер BOLT12';

  @override
  String get bolt12TitlePayInvoice => 'Оплатить счёт BOLT12';

  @override
  String get bolt12AmountLabel => 'Сумма (sats)';

  @override
  String get bolt12MemoLabel => 'Заметка плательщика (необязательно)';

  @override
  String get bolt12RawStringLabel => 'Строка BOLT12';

  @override
  String get bolt12NotSupported =>
      'Этот сервер LNbits не поддерживает BOLT12. Возможно, твой узел Lightning не понимает BOLT12, или расширение BOLT12 для LNbits не установлено.';

  @override
  String get myContactTitle => 'Мой контакт';

  @override
  String get myContactLnAddressSection => 'Lightning Address';

  @override
  String get myContactBolt12Section => 'Оффер BOLT12';

  @override
  String get myContactAddLnAddress => 'Добавь свой Lightning address';

  @override
  String get myContactAddBolt12 => 'Добавь свой оффер BOLT12';

  @override
  String get myContactLnAddressHint =>
      'user@domain. Если домен — это сервер LNbits, EmberSpark задаст её там; иначе она сохраняется как есть.';

  @override
  String get myContactBolt12Hint =>
      'lno1… — вставь оффер, созданный твоим узлом Lightning.';

  @override
  String get myContactInvalidLnAddress => 'Недопустимый Lightning address.';

  @override
  String get myContactInvalidBolt12 => 'Недопустимый оффер BOLT12.';

  @override
  String get myContactCopied => 'Скопировано';

  @override
  String get myContactShareSubject => 'Мой контакт Lightning';

  @override
  String get myContactRemoveConfirm => 'Удалить эту запись?';

  @override
  String get myContactAutoGenerate => 'Создать автоматически';

  @override
  String get myContactLnurlpSection => 'Ссылка LNURL-pay';

  @override
  String get myContactAddLnurlp => 'Добавь свою ссылку LNURL-pay';

  @override
  String get myContactLnurlpHint =>
      'lnurl1… — вставь свою ссылку или создай автоматически с сервера LNbits.';

  @override
  String get myContactInvalidLnurlp => 'Недопустимая ссылка LNURL-pay.';

  @override
  String get myContactGenerating => 'Создание…';

  @override
  String get myContactLnurlpExtensionMissing =>
      'В LNbits не установлено расширение LNURL-pay.';

  @override
  String get myContactReadOnlyNoGenerate =>
      'Это кошелёк только для чтения, поэтому он не может создать ссылку на сервере. Вы всё же можете вставить существующую ниже.';

  @override
  String get myContactLnAddressServerUpdated =>
      'Lightning Address обновлён на сервере.';

  @override
  String get myContactBolt12ExtensionMissing =>
      'В LNbits не установлено расширение BOLT12, или твой узел Lightning не поддерживает BOLT12.';

  @override
  String get myContactAvatarPriority =>
      'Аватар профиля создаётся из одного из этих идентификаторов. Нажми звезду, чтобы выбрать нужный. Иначе используется Lightning address, затем BOLT12, затем LNURL.';

  @override
  String get myContactSetDefault => 'Сделать основной личностью';

  @override
  String get myContactUnsetDefault => 'Убрать как основную личность';

  @override
  String get myContactTabLnAddress => 'LN Address';

  @override
  String get myContactTabLnurlp => 'LNURL';

  @override
  String get myContactTabBolt12 => 'BOLT12';

  @override
  String get myContactLnAddressUse => 'Удобно делиться с друзьями и семьёй.';

  @override
  String get myContactLnurlpUse =>
      'Менее опознаваемая строка bech32, но проходит через тот же сервер.';

  @override
  String get myContactBolt12Use =>
      'Лучшая приватность: платежи идут напрямую по Lightning, без оператора домена посередине.';

  @override
  String get walletsMenu => 'Кошельки';

  @override
  String get walletsTitle => 'Кошельки';

  @override
  String get walletsEmpty => 'Пока нет кошельков — добавь первый.';

  @override
  String get walletsAdd => 'Добавить кошелёк';

  @override
  String get walletsActive => 'Активен';

  @override
  String get walletsEdit => 'Изменить кошелёк';

  @override
  String get walletsRemove => 'Удалить кошелёк';

  @override
  String get walletsRemoveConfirm =>
      'Удалить этот кошелёк с этого устройства? Его записи «Мой контакт» будут очищены. Кошелёк на сервере не затрагивается.';

  @override
  String get walletsDuplicate => 'Этот кошелёк уже добавлен.';

  @override
  String get walletsActiveLabelTooltip => 'Нажми, чтобы сменить кошелёк';

  @override
  String get loginWalletNameLabel => 'Имя кошелька (необязательно)';

  @override
  String get loginWalletNameHint => 'По умолчанию — имя хоста сервера';
}
