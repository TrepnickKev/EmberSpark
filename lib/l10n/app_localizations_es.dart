// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'EmberSpark';

  @override
  String get appLocked => 'Bloqueado';

  @override
  String get appUnlock => 'Desbloquear';

  @override
  String get appTryAgain => 'Reintentar';

  @override
  String get appSetupFirstToast => 'Primero configura la billetera';

  @override
  String get commonCopy => 'Copiar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonScanQr => 'Escanear QR';

  @override
  String get commonScan => 'Escanear';

  @override
  String get commonShare => 'Compartir';

  @override
  String get commonNfc => 'NFC';

  @override
  String get commonPaste => 'Pegar';

  @override
  String get commonImage => 'Imagen';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonAmount => 'Importe (sats)';

  @override
  String get commonUnknownError => 'Error desconocido';

  @override
  String get receiveShareSubject => 'Factura Lightning';

  @override
  String get nfcHoldTag => 'Acerca una etiqueta NFC al teléfono…';

  @override
  String get nfcWriteSuccess => 'Escrito en la etiqueta';

  @override
  String get nfcWriteFailed => 'No se pudo escribir en la etiqueta';

  @override
  String get nfcReadFailed => 'No se pudo leer la etiqueta';

  @override
  String get nfcUnavailable => 'NFC no disponible en este dispositivo';

  @override
  String get imageNoQr => 'No se encontró ningún código QR en la imagen';

  @override
  String get clipboardEmpty => 'El portapapeles está vacío';

  @override
  String get homeScan => 'Escanear QR';

  @override
  String get homeSend => 'Enviar';

  @override
  String get homeReceive => 'Recibir';

  @override
  String get homeContacts => 'Contactos';

  @override
  String get homeSettings => 'Ajustes';

  @override
  String get homeLogout => 'Cerrar sesión';

  @override
  String get homeMyContact => 'Mi contacto';

  @override
  String get homeBoltCard => 'Bolt Card';

  @override
  String homeSatsReceived(String amount) {
    return 'Recibiste $amount sats';
  }

  @override
  String homeSatsSent(String amount) {
    return 'Enviaste $amount sats';
  }

  @override
  String get homeSatsUnit => 'sats';

  @override
  String get boltCardTitle => 'Bolt Cards';

  @override
  String get boltCardExtensionMissing =>
      'La extensión Boltcards no está instalada en este servidor.';

  @override
  String get boltCardNone =>
      'Aún no hay Bolt Cards. Toca Añadir para configurar una.';

  @override
  String get boltCardAdd => 'Añadir Bolt Card';

  @override
  String get boltCardEdit => 'Editar tarjeta';

  @override
  String get boltCardName => 'Nombre de la tarjeta';

  @override
  String get boltCardTxLimit => 'Límite por toque (sats)';

  @override
  String get boltCardDailyLimit => 'Límite diario (sats)';

  @override
  String get boltCardCreate => 'Crear';

  @override
  String get boltCardSave => 'Guardar';

  @override
  String get boltCardProgram => 'Programar tarjeta';

  @override
  String get boltCardVerify => 'Verificar';

  @override
  String get boltCardWipe => 'Restablecer';

  @override
  String get boltCardDelete => 'Eliminar';

  @override
  String get boltCardEnable => 'Activar';

  @override
  String get boltCardDisable => 'Desactivar';

  @override
  String get boltCardEnabled => 'Activada';

  @override
  String get boltCardDisabled => 'Desactivada';

  @override
  String boltCardCounter(int count) {
    return '$count toques';
  }

  @override
  String boltCardLimits(int tx, int daily) {
    return 'Por toque $tx sats, diario $daily sats';
  }

  @override
  String get boltCardHoldToProgram =>
      'Acerca la tarjeta al teléfono para programarla. No la retires hasta que termine.';

  @override
  String get boltCardHoldToVerify =>
      'Acerca la tarjeta al teléfono para leerla.';

  @override
  String get boltCardHoldToWipe =>
      'Acerca la tarjeta al teléfono para restablecerla. No la retires hasta que termine.';

  @override
  String get boltCardProgrammed => 'Tarjeta programada.';

  @override
  String get boltCardProgramFailed => 'No se pudo programar la tarjeta.';

  @override
  String get boltCardNotBlank =>
      'Esta tarjeta ya está programada. Restablécela primero.';

  @override
  String get boltCardUidAlreadyRegistered =>
      'Ya hay una Bolt Card con este UID registrada en el servidor. Elimina la entrada de tarjeta existente e inténtalo de nuevo.';

  @override
  String get boltCardVerifyNotProgrammed =>
      'Esta tarjeta aún no está programada, así que no hay nada que verificar.';

  @override
  String get boltCardVerified =>
      'La tarjeta funciona y apunta a esta billetera.';

  @override
  String get boltCardVerifiedBadge => 'Verificada';

  @override
  String get boltCardVerifyWrongServer =>
      'Esta tarjeta apunta a un servidor diferente.';

  @override
  String get boltCardVerifyUidMismatch =>
      'El ID del chip de esta tarjeta no coincide con el registro del servidor. Restablece la tarjeta, luego añádela y prográmala de nuevo para que se guarde el ID correcto.';

  @override
  String get boltCardVerifyCounterBehind =>
      'El contador de toques de esta tarjeta está por detrás del servidor. Reprograma la tarjeta para restablecerlo.';

  @override
  String get boltCardTagLost =>
      'La tarjeta se retiró demasiado pronto. Manténla plana contra la parte trasera del teléfono y quieta hasta que termine la operación, luego inténtalo de nuevo.';

  @override
  String get boltCardVerifyFailed => 'No se pudo verificar la tarjeta.';

  @override
  String get boltCardWipeConfirm =>
      '¿Restablecer esta tarjeta a las claves de fábrica? Dejará de funcionar hasta que la programes de nuevo.';

  @override
  String get boltCardWiped => 'Tarjeta restablecida a las claves de fábrica.';

  @override
  String get boltCardWipeFailed => 'No se pudo restablecer la tarjeta.';

  @override
  String get boltCardDeleteConfirm => '¿Eliminar esta tarjeta del servidor?';

  @override
  String get loginTitle => 'Configurar billetera';

  @override
  String get loginUrlLabel => 'URL de LNbits';

  @override
  String get loginUrlHint => 'https://tu.nodo';

  @override
  String get loginAdminKeyLabel => 'Clave API de administrador';

  @override
  String get loginAdminKeyHelper =>
      'Clave de acceso total — se usa para todas las operaciones';

  @override
  String get loginAdminKeyRequired =>
      'La clave de administrador es obligatoria';

  @override
  String get loginScanUrlTitle => 'Escanear URL de LNbits';

  @override
  String get loginScanAdminTitle => 'Escanear clave de administrador';

  @override
  String get loginHint =>
      'Encuentra el código QR en LNbits → wallet → \"API info\" → Admin key.';

  @override
  String get disclaimerTitle => '¿Para quién es EmberSpark?';

  @override
  String get disclaimerBody =>
      'EmberSpark es un cliente para billeteras Lightning LNbits autoalojadas. Es para personas que ejecutan su propio servidor LNbits, o a quienes alguien que lo hace les dio acceso a una billetera. Si ese no es tu caso, esta app no es adecuada para ti.';

  @override
  String get disclaimerAck => 'Entendido';

  @override
  String get sendTitle => 'Enviar';

  @override
  String get sendBolt11Label => 'Factura BOLT11';

  @override
  String get sendPay => 'Pagar';

  @override
  String get sendPaymentSent => 'Pago enviado';

  @override
  String get sendPasteFirst => 'Primero pega una factura';

  @override
  String get sendAnyAmount => 'Cualquier importe';

  @override
  String sendAmountWithSats(String amount) {
    return '$amount sats';
  }

  @override
  String get sendToTitle => 'Enviar a…';

  @override
  String get sendToInputLabel => 'Dirección o datos de pago';

  @override
  String get sendToInputHint => 'BOLT11, LNURL o user@host';

  @override
  String get sendToScanTitle => 'Escanear para enviar';

  @override
  String get sendToContacts => 'Contactos';

  @override
  String get sendToNoContacts => 'Aún no hay contactos';

  @override
  String get contactsSearchHint => 'Filtrar contactos';

  @override
  String get contactsNoMatches => 'No hay contactos coincidentes';

  @override
  String get receiveTitle => 'Recibir';

  @override
  String get receiveReusableAddress => 'Tu dirección reutilizable';

  @override
  String get receiveAmount => 'Importe';

  @override
  String get receiveMemo => 'Nota';

  @override
  String get receiveCreateInvoice => 'Crear factura';

  @override
  String get receiveInvoiceCopied => 'Factura copiada';

  @override
  String get receiveAmountError => 'Introduce un importe positivo';

  @override
  String get receiveEnterAmountFirst => 'Introduce primero un importe';

  @override
  String receiveCardCharged(int sats) {
    return 'Se cobraron $sats sats de la tarjeta';
  }

  @override
  String receiveSatsApprox(String amount) {
    return '≈ $amount sats';
  }

  @override
  String get receiveRatesUnavailable =>
      'Cotizaciones en vivo no disponibles — solo sats';

  @override
  String get receiveCurrencySats => 'sats';

  @override
  String get contactsTitle => 'Contactos';

  @override
  String get contactsEmpty => 'Aún no hay contactos — toca + para añadir uno';

  @override
  String contactsDeleteTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String get contactsNew => 'Nuevo contacto';

  @override
  String get contactsEdit => 'Editar contacto';

  @override
  String get contactsScanTitle => 'Escanear destino';

  @override
  String get contactsName => 'Nombre';

  @override
  String get contactsDestinationLabel => 'Lightning address, LNURL o BOLT11';

  @override
  String get contactsRequired => 'El nombre y el destino son obligatorios';

  @override
  String get contactsInvalidDestination =>
      'No es un destino Lightning válido. Usa una Lightning address (user@host.tld), factura BOLT11, oferta/factura BOLT12 (lno1…/lni1…) o LNURL.';

  @override
  String get contactsImport => 'Importar contactos';

  @override
  String get contactsExport => 'Exportar contactos';

  @override
  String get contactsExportEmpty => 'No hay contactos para exportar';

  @override
  String get contactsShareSubject => 'Contactos de EmberSpark';

  @override
  String get contactsImportFailed => 'No se pudo leer ese archivo de contactos';

  @override
  String contactsImported(int count) {
    return 'Se importaron $count contactos';
  }

  @override
  String get historyTitle => 'Historial';

  @override
  String get historyEmpty => 'Aún no hay transacciones';

  @override
  String get historyPaymentDefault => 'Pago Lightning';

  @override
  String get historyPending => 'pendiente';

  @override
  String historyFee(String amount) {
    return 'comisión $amount';
  }

  @override
  String get historyDetailsTitle => 'Transacción';

  @override
  String get historyDirectionSent => 'Enviado';

  @override
  String get historyDirectionReceived => 'Recibido';

  @override
  String get historyStatusPaid => 'Pagado';

  @override
  String get historyStatusPendingLabel => 'Pendiente';

  @override
  String get historyAmountLabel => 'Importe';

  @override
  String get historyFeeLabel => 'Comisión';

  @override
  String get historyMemoLabel => 'Nota';

  @override
  String get historyCommentLabel => 'Comentario';

  @override
  String get historyTimestampLabel => 'Hora';

  @override
  String get historyPaymentHashLabel => 'Hash de pago';

  @override
  String get historyInvoiceLabel => 'Factura';

  @override
  String get historyClose => 'Cerrar';

  @override
  String get historyJustNow => 'ahora mismo';

  @override
  String historyMinutesAgo(int minutes) {
    return 'hace $minutes min';
  }

  @override
  String historyHoursAgo(int hours) {
    return 'hace $hours h';
  }

  @override
  String historyDaysAgo(int days) {
    return 'hace $days d';
  }

  @override
  String get lockedLabel => 'Bloqueado';

  @override
  String get lockUnlock => 'Desbloquear';

  @override
  String get lockTryAgain => 'Reintentar';

  @override
  String get lnurlTitleAuthenticate => 'Autenticar';

  @override
  String get lnurlTitlePay => 'Enviar (LNURL)';

  @override
  String get lnurlTitleWithdraw => 'Recibir (LNURL)';

  @override
  String get lnurlTitleGeneric => 'LNURL';

  @override
  String get lnurlResolvedExplain =>
      'URL resuelta — pégala en un navegador para ver si el servidor responde fuera de la billetera:';

  @override
  String get lnurlCopyUrl => 'Copiar URL';

  @override
  String get lnurlUrlCopied => 'URL copiada';

  @override
  String lnurlAuthRegisterAt(String host) {
    return 'Regístrate en $host';
  }

  @override
  String lnurlAuthLinkAt(String host) {
    return 'Vincula tu cuenta en $host';
  }

  @override
  String lnurlAuthAuthenticateAt(String host) {
    return 'Autentícate en $host';
  }

  @override
  String lnurlAuthLoginAt(String host) {
    return 'Inicia sesión en $host';
  }

  @override
  String get lnurlAuthExplain =>
      'Se derivará una clave de firma única para este sitio a partir de la semilla de tu billetera. El sitio solo ve tu clave pública — tu billetera y tu saldo permanecen privados.';

  @override
  String get lnurlAuthConfirm => 'Confirmar';

  @override
  String lnurlAuthSuccess(String host) {
    return 'Autenticado con $host';
  }

  @override
  String lnurlAmountRange(int min, int max) {
    return 'Rango: $min – $max sats';
  }

  @override
  String lnurlAmountOutOfRange(int min, int max) {
    return 'El importe debe estar entre $min y $max sats';
  }

  @override
  String get lnurlAmountPositive => 'Introduce un importe positivo';

  @override
  String get lnurlGetAndPay => 'Enviar';

  @override
  String get lnurlWithdraw => 'Retirar';

  @override
  String get lnurlWithdrawDefaultMemo => 'LNURL-withdraw';

  @override
  String lnurlWithdrawing(int amount) {
    return 'Retirando $amount sats…';
  }

  @override
  String get lnurlCommentLabel => 'Nota (opcional)';

  @override
  String lnurlCommentHelp(int max) {
    return 'Máximo $max caracteres';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSubtitle => 'Elige el idioma de la app';

  @override
  String get languageSystemDefault => 'Predeterminado del sistema';

  @override
  String get settingsDisplayCurrency => 'Moneda de visualización';

  @override
  String get settingsDisplayCurrencySubtitle =>
      'Se usa para el importe fiat bajo el saldo';

  @override
  String get settingsLockOnLaunch => 'Bloquear la app al abrir';

  @override
  String get settingsLockSubtitleEnabled =>
      'Requiere biometría o el PIN/patrón del dispositivo para abrir EmberSpark.';

  @override
  String get settingsLockSubtitleUnavailable =>
      'No hay bloqueo de pantalla configurado en este dispositivo. Configura uno en los ajustes del sistema para activar esta opción.';

  @override
  String get settingsLockConfirmReason =>
      'Confirma para activar el bloqueo de la app';

  @override
  String get settingsLockNeedSetup =>
      'Primero configura un bloqueo de pantalla o biometría en tu teléfono.';

  @override
  String get settingsTrustTls => 'Permitir HTTPS no verificado';

  @override
  String get settingsTrustTlsSubtitle =>
      'Confía en certificados autofirmados o con cadena incompleta. Necesario para algunos servidores Lightning caseros y servicios .onion. Actívalo solo para servidores en los que confíes.';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutTagline => 'Una billetera Lightning ligera para LNbits';

  @override
  String get aboutCopyright => '© 2026 Trepnick Solutions';

  @override
  String get aboutVersionLabel => 'Versión';

  @override
  String get aboutCheckAgain => 'Comprobar de nuevo';

  @override
  String get aboutCheckingForUpdates => 'Buscando actualizaciones…';

  @override
  String get aboutUpToDate => 'Actualizada';

  @override
  String aboutUpdateAvailable(String version) {
    return 'Actualización disponible: v$version';
  }

  @override
  String get aboutOpenRelease => 'Abrir versión';

  @override
  String get aboutCheckFailed => 'No se pudo buscar actualizaciones';

  @override
  String get aboutSupportDevelopment => 'Apoyar el desarrollo';

  @override
  String get aboutSupportBody =>
      'EmberSpark se crea y mantiene en el tiempo libre. Si te facilita gestionar tus sats, considera enviar unos BTC on-chain a la dirección de abajo. Cada aporte mantiene vivo el proyecto. ¡Gracias! Reportar errores o pedir funciones en GitHub es igual de bienvenido.';

  @override
  String get aboutDonateMethods => 'Donar vía Lightning / On-Chain';

  @override
  String get aboutContributeOnGithub => 'Contribuir en GitHub';

  @override
  String get aboutCopyAddress => 'Copiar dirección';

  @override
  String get aboutAddressCopied => 'Dirección copiada';

  @override
  String get aboutLicensesTitle => 'Licencias de código abierto';

  @override
  String get aboutLicensesSubtitle => 'Flutter SDK y paquetes de terceros';

  @override
  String get errorTlsCertificate =>
      'No se pudo verificar el certificado TLS del servidor.\nSi confías en este servidor, activa \'Permitir HTTPS no verificado\' en Ajustes.';

  @override
  String get errorTlsHandshake =>
      'No se pudo establecer una conexión segura con el servidor.\nEl servidor puede usar una versión de TLS obsoleta, o su certificado no es válido.\nSi confías en el servidor, prueba \'Permitir HTTPS no verificado\' en Ajustes.';

  @override
  String get errorHostLookup =>
      'No se pudo resolver el nombre de host de LNbits.\nComprueba la URL y tu conexión de red.';

  @override
  String get errorConnectionRefused =>
      'El servidor LNbits rechazó la conexión.\nComprueba la URL y que el servidor esté en ejecución.';

  @override
  String get errorConnectionDropped =>
      'Se perdió la conexión con el servidor LNbits. Inténtalo de nuevo.';

  @override
  String get errorNetworkUnreachable =>
      'Sin conexión de red. Comprueba el Wi-Fi / los datos móviles.';

  @override
  String get errorSocket =>
      'No se pudo contactar con el servidor LNbits. Comprueba tu red.';

  @override
  String get errorTimeout =>
      'El servidor no respondió a tiempo. Inténtalo de nuevo.';

  @override
  String get error401 =>
      'Falló la autenticación. Comprueba tus claves API de administrador / de facturación.';

  @override
  String get error403 =>
      'El servidor denegó el acceso. Puede que el vale ya se haya canjeado, o que tu IP esté bloqueada.';

  @override
  String get error404 =>
      'Endpoint no encontrado. Comprueba que la URL de LNbits sea correcta.';

  @override
  String get error500 =>
      'Error del servidor LNbits. Revisa los registros de LNbits.';

  @override
  String get error502 => 'LNbits no es accesible a través de su proxy.';

  @override
  String get error503 => 'LNbits no está disponible temporalmente.';

  @override
  String get error520 =>
      'LNbits no tiene ningún backend Lightning configurado (VoidWallet). Conecta un nodo Lightning en LNbits → Server → Funding.';

  @override
  String get errorInsufficientFunds =>
      'No hay suficientes sats en tu billetera para este pago.';

  @override
  String get errorSelfPayment =>
      'Esta factura es de esta billetera. No puedes pagarte a ti mismo.';

  @override
  String get errorLnurlInsecureCallback =>
      'El servidor LNbits devolvió una URL de callback insegura (http://). Esto suele significar que LNbits está detrás de un proxy inverso y no conoce su dirección HTTPS pública. En el host de LNbits, define LNBITS_BASE_URL=https://tu-host en .env y reinícialo. Como alternativa, configura el proxy para que pase X-Forwarded-Proto: https.';

  @override
  String errorServerGeneric(String code) {
    return 'Error del servidor ($code).';
  }

  @override
  String get lnurlAuthErrorKeyInUse =>
      'Esta clave de autenticación ya está en uso para este sitio. Espera un momento e inténtalo de nuevo, o recarga el QR de inicio de sesión.';

  @override
  String get lnurlAuthErrorInvalidSignature =>
      'El sitio rechazó la firma de autenticación. Inténtalo de nuevo.';

  @override
  String get lnurlAuthErrorLinkingKeyMismatch =>
      'El sitio no reconoce esta clave de autenticación. Esto suele significar que antes te autenticaste con una semilla de billetera diferente.';

  @override
  String lnurlAuthErrorGeneric(String reason) {
    return 'LNURL-auth falló: $reason';
  }

  @override
  String get bolt12TitlePayOffer => 'Pagar oferta BOLT12';

  @override
  String get bolt12TitlePayInvoice => 'Pagar factura BOLT12';

  @override
  String get bolt12AmountLabel => 'Importe (sats)';

  @override
  String get bolt12MemoLabel => 'Nota del pagador (opcional)';

  @override
  String get bolt12RawStringLabel => 'Cadena BOLT12';

  @override
  String get bolt12NotSupported =>
      'Este servidor LNbits no admite BOLT12. Puede que tu nodo Lightning no entienda BOLT12, o que la extensión BOLT12 de LNbits no esté instalada.';

  @override
  String get myContactTitle => 'Mi contacto';

  @override
  String get myContactLnAddressSection => 'Lightning Address';

  @override
  String get myContactBolt12Section => 'Oferta BOLT12';

  @override
  String get myContactAddLnAddress => 'Añade tu Lightning address';

  @override
  String get myContactAddBolt12 => 'Añade tu oferta BOLT12';

  @override
  String get myContactLnAddressHint =>
      'user@domain. Si el dominio es el servidor LNbits, EmberSpark la configura ahí; de lo contrario se guarda tal cual.';

  @override
  String get myContactBolt12Hint =>
      'lno1… — pega la oferta que generó tu nodo Lightning.';

  @override
  String get myContactInvalidLnAddress => 'No es una Lightning address válida.';

  @override
  String get myContactInvalidBolt12 => 'No es una oferta BOLT12 válida.';

  @override
  String get myContactCopied => 'Copiado';

  @override
  String get myContactShareSubject => 'Mi contacto Lightning';

  @override
  String get myContactRemoveConfirm => '¿Quitar esta entrada?';

  @override
  String get myContactAutoGenerate => 'Autogenerar';

  @override
  String get myContactLnurlpSection => 'Enlace LNURL-pay';

  @override
  String get myContactAddLnurlp => 'Añade tu enlace LNURL-pay';

  @override
  String get myContactLnurlpHint =>
      'lnurl1… — pega tu enlace o autogenera uno desde el servidor LNbits.';

  @override
  String get myContactInvalidLnurlp => 'No es un enlace LNURL-pay válido.';

  @override
  String get myContactGenerating => 'Generando…';

  @override
  String get myContactLnurlpExtensionMissing =>
      'LNbits no tiene instalada la extensión LNURL-pay.';

  @override
  String get myContactLnAddressServerUpdated =>
      'Lightning Address actualizada en el servidor.';

  @override
  String get myContactBolt12ExtensionMissing =>
      'LNbits no tiene instalada una extensión BOLT12, o tu nodo Lightning no admite BOLT12.';

  @override
  String get myContactAvatarPriority =>
      'Tu avatar de perfil se genera a partir de uno de estos identificadores. Toca una estrella para elegir cuál. Si no, usa la Lightning address, luego BOLT12 y luego LNURL.';

  @override
  String get myContactSetDefault => 'Establecer como identidad predeterminada';

  @override
  String get myContactUnsetDefault => 'Quitar como identidad predeterminada';

  @override
  String get myContactTabLnAddress => 'LN Address';

  @override
  String get myContactTabLnurlp => 'LNURL';

  @override
  String get myContactTabBolt12 => 'BOLT12';

  @override
  String get myContactLnAddressUse =>
      'Fácil de compartir con amigos y familia.';

  @override
  String get myContactLnurlpUse =>
      'Cadena bech32 menos identificable, pero se enruta a través del mismo servidor.';

  @override
  String get myContactBolt12Use =>
      'Mejor privacidad: los pagos van directamente por Lightning, sin un operador de dominio en medio.';

  @override
  String get walletsMenu => 'Billeteras';

  @override
  String get walletsTitle => 'Billeteras';

  @override
  String get walletsEmpty => 'Aún no hay billeteras — añade la primera.';

  @override
  String get walletsAdd => 'Añadir billetera';

  @override
  String get walletsActive => 'Activa';

  @override
  String get walletsEdit => 'Editar billetera';

  @override
  String get walletsRemove => 'Quitar billetera';

  @override
  String get walletsRemoveConfirm =>
      '¿Quitar esta billetera de este dispositivo? Sus entradas de Mi contacto se borrarán. La billetera en el servidor no se ve afectada.';

  @override
  String get walletsDuplicate => 'Esta billetera ya está añadida.';

  @override
  String get walletsActiveLabelTooltip => 'Toca para cambiar de billetera';

  @override
  String get loginWalletNameLabel => 'Nombre de la billetera (opcional)';

  @override
  String get loginWalletNameHint =>
      'Por defecto, el nombre de host del servidor';
}
