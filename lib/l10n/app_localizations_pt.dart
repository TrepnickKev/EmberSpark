// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'EmberSpark';

  @override
  String get appLocked => 'Bloqueado';

  @override
  String get appUnlock => 'Desbloquear';

  @override
  String get appTryAgain => 'Tentar novamente';

  @override
  String get appSetupFirstToast => 'Configure a carteira primeiro';

  @override
  String get commonCopy => 'Copiar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonScanQr => 'Escanear QR';

  @override
  String get commonScan => 'Escanear';

  @override
  String get commonShare => 'Compartilhar';

  @override
  String get commonNfc => 'NFC';

  @override
  String get commonPaste => 'Colar';

  @override
  String get commonImage => 'Imagem';

  @override
  String get commonRetry => 'Tentar novamente';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonAmount => 'Valor (sats)';

  @override
  String get commonUnknownError => 'Erro desconhecido';

  @override
  String get receiveShareSubject => 'Fatura Lightning';

  @override
  String get nfcHoldTag => 'Aproxime uma tag NFC do telefone…';

  @override
  String get nfcWriteSuccess => 'Gravado na tag';

  @override
  String get nfcWriteFailed => 'Não foi possível gravar na tag';

  @override
  String get nfcReadFailed => 'Não foi possível ler a tag';

  @override
  String get nfcUnavailable => 'NFC indisponível neste dispositivo';

  @override
  String get imageNoQr => 'Nenhum código QR encontrado na imagem';

  @override
  String get clipboardEmpty => 'A área de transferência está vazia';

  @override
  String get homeScan => 'Escanear QR';

  @override
  String get homeSend => 'Enviar';

  @override
  String get homeReceive => 'Receber';

  @override
  String get homeContacts => 'Contatos';

  @override
  String get homeSettings => 'Configurações';

  @override
  String get homeLogout => 'Sair';

  @override
  String get homeMyContact => 'Meu contato';

  @override
  String get homeBoltCard => 'Bolt Card';

  @override
  String homeSatsReceived(String amount) {
    return 'Você recebeu $amount sats';
  }

  @override
  String homeSatsSent(String amount) {
    return 'Você enviou $amount sats';
  }

  @override
  String get homeSatsUnit => 'sats';

  @override
  String get boltCardTitle => 'Bolt Cards';

  @override
  String get boltCardExtensionMissing =>
      'A extensão Boltcards não está instalada neste servidor.';

  @override
  String get boltCardNone =>
      'Ainda não há Bolt Cards. Toque em Adicionar para configurar uma.';

  @override
  String get boltCardAdd => 'Adicionar Bolt Card';

  @override
  String get boltCardEdit => 'Editar cartão';

  @override
  String get boltCardName => 'Nome do cartão';

  @override
  String get boltCardTxLimit => 'Limite por toque (sats)';

  @override
  String get boltCardDailyLimit => 'Limite diário (sats)';

  @override
  String get boltCardCreate => 'Criar';

  @override
  String get boltCardSave => 'Salvar';

  @override
  String get boltCardProgram => 'Programar cartão';

  @override
  String get boltCardVerify => 'Verificar';

  @override
  String get boltCardWipe => 'Redefinir';

  @override
  String get boltCardDelete => 'Excluir';

  @override
  String get boltCardEnable => 'Ativar';

  @override
  String get boltCardDisable => 'Desativar';

  @override
  String get boltCardEnabled => 'Ativado';

  @override
  String get boltCardDisabled => 'Desativado';

  @override
  String boltCardCounter(int count) {
    return '$count toques';
  }

  @override
  String boltCardLimits(int tx, int daily) {
    return 'Por toque $tx sats, diário $daily sats';
  }

  @override
  String get boltCardHoldToProgram =>
      'Aproxime seu cartão do telefone para programá-lo. Não o remova até terminar.';

  @override
  String get boltCardHoldToVerify =>
      'Aproxime seu cartão do telefone para lê-lo.';

  @override
  String get boltCardHoldToWipe =>
      'Aproxime seu cartão do telefone para redefini-lo. Não o remova até terminar.';

  @override
  String get boltCardProgrammed => 'Cartão programado.';

  @override
  String get boltCardProgramFailed => 'Não foi possível programar o cartão.';

  @override
  String get boltCardNotBlank =>
      'Este cartão já está programado. Redefina-o primeiro.';

  @override
  String get boltCardUidAlreadyRegistered =>
      'Já existe uma Bolt Card com este UID registrada no servidor. Exclua a entrada de cartão existente e tente novamente.';

  @override
  String get boltCardVerifyNotProgrammed =>
      'Este cartão ainda não está programado, então não há nada para verificar.';

  @override
  String get boltCardVerified =>
      'O cartão funciona e aponta para esta carteira.';

  @override
  String get boltCardVerifiedBadge => 'Verificado';

  @override
  String get boltCardVerifyWrongServer =>
      'Este cartão aponta para um servidor diferente.';

  @override
  String get boltCardVerifyUidMismatch =>
      'O ID do chip deste cartão não corresponde ao registro do servidor. Redefina o cartão, depois adicione-o e programe-o novamente para que o ID correto seja salvo.';

  @override
  String get boltCardVerifyCounterBehind =>
      'O contador de toques deste cartão está atrás do servidor. Reprograme o cartão para redefini-lo.';

  @override
  String get boltCardTagLost =>
      'O cartão foi removido cedo demais. Mantenha-o plano contra a parte de trás do telefone e imóvel até a operação terminar, depois tente novamente.';

  @override
  String get boltCardChargeOnlyTitle => 'Bolt Card';

  @override
  String get boltCardChargeOnlyBody =>
      'Um Bolt Card só pode ser cobrado, não pago. Deseja cobrá-lo?';

  @override
  String get boltCardChargeAction => 'Cobrar';

  @override
  String get boltCardVerifyFailed => 'Não foi possível verificar o cartão.';

  @override
  String get boltCardWipeConfirm =>
      'Redefinir este cartão para as chaves de fábrica? Ele deixará de funcionar até você programá-lo novamente.';

  @override
  String get boltCardWiped => 'Cartão redefinido para as chaves de fábrica.';

  @override
  String get boltCardWipeFailed => 'Não foi possível redefinir o cartão.';

  @override
  String get boltCardDeleteConfirm => 'Excluir este cartão do servidor?';

  @override
  String get loginTitle => 'Configurar carteira';

  @override
  String get loginUrlLabel => 'URL do LNbits';

  @override
  String get loginUrlHint => 'https://seu.node';

  @override
  String get loginAdminKeyLabel => 'Chave de API de administrador';

  @override
  String get loginAdminKeyHelper =>
      'Chave admin para acesso total, ou uma chave de fatura/leitura para uma carteira somente leitura';

  @override
  String get loginAdminKeyRequired => 'A chave de administrador é obrigatória';

  @override
  String get loginScanUrlTitle => 'Escanear URL do LNbits';

  @override
  String get loginScanAdminTitle => 'Escanear chave de administrador';

  @override
  String get loginHint =>
      'Encontre o código QR no LNbits → wallet → \"API info\" → Admin key.';

  @override
  String get disclaimerTitle => 'Para quem é o EmberSpark?';

  @override
  String get disclaimerBody =>
      'O EmberSpark é um cliente para carteiras Lightning LNbits auto-hospedadas. É para pessoas que executam seu próprio servidor LNbits, ou a quem alguém que o faz deu acesso a uma carteira. Se esse não é o seu caso, este app não é adequado para você.';

  @override
  String get disclaimerAck => 'Entendi';

  @override
  String get sendTitle => 'Enviar';

  @override
  String get sendBolt11Label => 'Fatura BOLT11';

  @override
  String get sendPay => 'Pagar';

  @override
  String get sendPaymentSent => 'Pagamento enviado';

  @override
  String get sendPasteFirst => 'Cole uma fatura primeiro';

  @override
  String get sendAnyAmount => 'Qualquer valor';

  @override
  String sendAmountWithSats(String amount) {
    return '$amount sats';
  }

  @override
  String get sendToTitle => 'Enviar para…';

  @override
  String get sendToInputLabel => 'Endereço ou dados de pagamento';

  @override
  String get sendToInputHint => 'BOLT11, LNURL ou user@host';

  @override
  String get sendToScanTitle => 'Escanear para enviar';

  @override
  String get sendToContacts => 'Contatos';

  @override
  String get sendToNoContacts => 'Ainda não há contatos';

  @override
  String get contactsSearchHint => 'Filtrar contatos';

  @override
  String get contactsNoMatches => 'Nenhum contato correspondente';

  @override
  String get receiveTitle => 'Receber';

  @override
  String get receiveReusableAddress => 'Seu endereço reutilizável';

  @override
  String get receiveAmount => 'Valor';

  @override
  String get receiveMemo => 'Nota';

  @override
  String get receiveCreateInvoice => 'Criar fatura';

  @override
  String get receiveInvoiceCopied => 'Fatura copiada';

  @override
  String get receiveAmountError => 'Insira um valor positivo';

  @override
  String get receiveEnterAmountFirst => 'Insira um valor primeiro';

  @override
  String receiveCardCharged(int sats) {
    return 'Cobrados $sats sats do cartão';
  }

  @override
  String receiveSatsApprox(String amount) {
    return '≈ $amount sats';
  }

  @override
  String get receiveRatesUnavailable =>
      'Cotações ao vivo indisponíveis — apenas sats';

  @override
  String get receiveCurrencySats => 'sats';

  @override
  String get contactsTitle => 'Contatos';

  @override
  String get contactsEmpty =>
      'Ainda não há contatos — toque em + para adicionar um';

  @override
  String contactsDeleteTitle(String name) {
    return 'Excluir $name?';
  }

  @override
  String get contactsNew => 'Novo contato';

  @override
  String get contactsEdit => 'Editar contato';

  @override
  String get contactsScanTitle => 'Escanear destino';

  @override
  String get contactsName => 'Nome';

  @override
  String get contactsDestinationLabel => 'Lightning address, LNURL ou BOLT11';

  @override
  String get contactsRequired => 'Nome e destino são obrigatórios';

  @override
  String get contactsInvalidDestination =>
      'Não é um destino Lightning válido. Use uma Lightning address (user@host.tld), fatura BOLT11, oferta/fatura BOLT12 (lno1…/lni1…) ou LNURL.';

  @override
  String get contactsImport => 'Importar contatos';

  @override
  String get contactsExport => 'Exportar contatos';

  @override
  String get contactsExportEmpty => 'Nenhum contato para exportar';

  @override
  String get contactsShareSubject => 'Contatos do EmberSpark';

  @override
  String get contactsImportFailed =>
      'Não foi possível ler esse arquivo de contatos';

  @override
  String contactsImported(int count) {
    return '$count contatos importados';
  }

  @override
  String get historyTitle => 'Histórico';

  @override
  String get historyEmpty => 'Ainda não há transações';

  @override
  String get historySearchHint => 'Search payments';

  @override
  String get historyNoResults => 'No matching payments';

  @override
  String get historyPaymentDefault => 'Pagamento Lightning';

  @override
  String get historyPending => 'pendente';

  @override
  String historyFee(String amount) {
    return 'taxa $amount';
  }

  @override
  String get historyDetailsTitle => 'Transação';

  @override
  String get historyDirectionSent => 'Enviado';

  @override
  String get historyDirectionReceived => 'Recebido';

  @override
  String get historyStatusPaid => 'Pago';

  @override
  String get historyStatusPendingLabel => 'Pendente';

  @override
  String get historyAmountLabel => 'Valor';

  @override
  String get historyFeeLabel => 'Taxa';

  @override
  String get historyMemoLabel => 'Nota';

  @override
  String get historyCommentLabel => 'Comentário';

  @override
  String get historyTimestampLabel => 'Horário';

  @override
  String get historyPaymentHashLabel => 'Hash do pagamento';

  @override
  String get historyInvoiceLabel => 'Fatura';

  @override
  String get historyClose => 'Fechar';

  @override
  String get historyJustNow => 'agora mesmo';

  @override
  String historyMinutesAgo(int minutes) {
    return 'há $minutes min';
  }

  @override
  String historyHoursAgo(int hours) {
    return 'há $hours h';
  }

  @override
  String historyDaysAgo(int days) {
    return 'há $days d';
  }

  @override
  String get lockedLabel => 'Bloqueado';

  @override
  String get lockUnlock => 'Desbloquear';

  @override
  String get lockTryAgain => 'Tentar novamente';

  @override
  String get lnurlTitleAuthenticate => 'Autenticar';

  @override
  String get lnurlTitlePay => 'Enviar (LNURL)';

  @override
  String get lnurlTitleWithdraw => 'Receber (LNURL)';

  @override
  String get lnurlTitleGeneric => 'LNURL';

  @override
  String get lnurlResolvedExplain =>
      'URL resolvida — cole em um navegador para ver se o servidor responde fora da carteira:';

  @override
  String get lnurlCopyUrl => 'Copiar URL';

  @override
  String get lnurlUrlCopied => 'URL copiada';

  @override
  String lnurlAuthRegisterAt(String host) {
    return 'Cadastre-se em $host';
  }

  @override
  String lnurlAuthLinkAt(String host) {
    return 'Vincule sua conta em $host';
  }

  @override
  String lnurlAuthAuthenticateAt(String host) {
    return 'Autentique-se em $host';
  }

  @override
  String lnurlAuthLoginAt(String host) {
    return 'Faça login em $host';
  }

  @override
  String get lnurlAuthExplain =>
      'Uma chave de assinatura exclusiva para este site será derivada da semente da sua carteira. O site vê apenas sua chave pública — sua carteira e seu saldo permanecem privados.';

  @override
  String get lnurlAuthConfirm => 'Confirmar';

  @override
  String lnurlAuthSuccess(String host) {
    return 'Autenticado com $host';
  }

  @override
  String lnurlAmountRange(int min, int max) {
    return 'Faixa: $min – $max sats';
  }

  @override
  String lnurlAmountOutOfRange(int min, int max) {
    return 'O valor deve estar entre $min e $max sats';
  }

  @override
  String get lnurlAmountPositive => 'Insira um valor positivo';

  @override
  String get lnurlGetAndPay => 'Enviar';

  @override
  String get lnurlWithdraw => 'Sacar';

  @override
  String get lnurlWithdrawDefaultMemo => 'LNURL-withdraw';

  @override
  String lnurlWithdrawing(int amount) {
    return 'Sacando $amount sats…';
  }

  @override
  String get lnurlCommentLabel => 'Nota (opcional)';

  @override
  String lnurlCommentHelp(int max) {
    return 'Máximo de $max caracteres';
  }

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSubtitle => 'Escolha o idioma do app';

  @override
  String get languageSystemDefault => 'Padrão do sistema';

  @override
  String get settingsDisplayCurrency => 'Moeda de exibição';

  @override
  String get settingsDisplayCurrencySubtitle =>
      'Usada para o valor em fiat abaixo do saldo';

  @override
  String get settingsLockOnLaunch => 'Bloquear o app ao abrir';

  @override
  String get settingsLockSubtitleEnabled =>
      'Exige biometria ou o PIN/padrão do dispositivo para abrir o EmberSpark.';

  @override
  String get settingsLockSubtitleUnavailable =>
      'Nenhum bloqueio de tela está configurado neste dispositivo. Configure um nas configurações do sistema para ativar esta opção.';

  @override
  String get settingsLockConfirmReason =>
      'Confirme para ativar o bloqueio do app';

  @override
  String get settingsLockNeedSetup =>
      'Configure um bloqueio de tela ou biometria no seu telefone primeiro.';

  @override
  String get settingsTrustTls => 'Permitir HTTPS não verificado';

  @override
  String get settingsTrustTlsSubtitle =>
      'Confie em certificados autoassinados ou com cadeia incompleta. Necessário para alguns servidores Lightning caseiros e serviços .onion. Ative apenas para servidores em que você confia.';

  @override
  String get settingsAbout => 'Sobre';

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
  String get aboutTitle => 'Sobre';

  @override
  String get aboutTagline => 'Uma carteira Lightning leve para o LNbits';

  @override
  String get aboutCopyright => '© 2026 Trepnick Solutions';

  @override
  String get aboutVersionLabel => 'Versão';

  @override
  String get aboutCheckAgain => 'Verificar novamente';

  @override
  String get aboutCheckingForUpdates => 'Verificando atualizações…';

  @override
  String get aboutUpToDate => 'Atualizado';

  @override
  String aboutUpdateAvailable(String version) {
    return 'Atualização disponível: v$version';
  }

  @override
  String get aboutOpenRelease => 'Abrir versão';

  @override
  String get aboutCheckFailed => 'Não foi possível verificar atualizações';

  @override
  String get aboutUpdatesViaStore =>
      'As atualizações são gerenciadas pelo Google Play';

  @override
  String get aboutSupportDevelopment => 'Apoiar o desenvolvimento';

  @override
  String get aboutSupportBody =>
      'O EmberSpark é criado e mantido no tempo livre. Se ele facilita a gestão dos seus sats, considere enviar alguns BTC on-chain para o endereço abaixo. Cada contribuição mantém o projeto vivo. Obrigado! Relatar bugs ou pedir recursos no GitHub é igualmente bem-vindo.';

  @override
  String get aboutDonateMethods => 'Doar via Lightning / On-Chain';

  @override
  String get aboutContributeOnGithub => 'Contribuir no GitHub';

  @override
  String get aboutCopyAddress => 'Copiar endereço';

  @override
  String get aboutAddressCopied => 'Endereço copiado';

  @override
  String get aboutLicensesTitle => 'Licenças de código aberto';

  @override
  String get aboutLicensesSubtitle => 'Flutter SDK e pacotes de terceiros';

  @override
  String get errorTlsCertificate =>
      'Não foi possível verificar o certificado TLS do servidor.\nSe você confia neste servidor, ative \'Permitir HTTPS não verificado\' nas Configurações.';

  @override
  String get errorTlsHandshake =>
      'Não foi possível estabelecer uma conexão segura com o servidor.\nO servidor pode usar uma versão de TLS desatualizada, ou seu certificado é inválido.\nSe você confia no servidor, tente \'Permitir HTTPS não verificado\' nas Configurações.';

  @override
  String get errorHostLookup =>
      'Não foi possível resolver o nome de host do LNbits.\nVerifique a URL e sua conexão de rede.';

  @override
  String get errorConnectionRefused =>
      'O servidor LNbits recusou a conexão.\nVerifique a URL e se o servidor está em execução.';

  @override
  String get errorConnectionDropped =>
      'A conexão com o servidor LNbits caiu. Tente novamente.';

  @override
  String get errorNetworkUnreachable =>
      'Sem conexão de rede. Verifique o Wi-Fi / os dados móveis.';

  @override
  String get errorSocket =>
      'Não foi possível acessar o servidor LNbits. Verifique sua rede.';

  @override
  String get errorTimeout =>
      'O servidor não respondeu a tempo. Tente novamente.';

  @override
  String get error401 =>
      'Falha na autenticação. Verifique suas chaves de API de administrador / de fatura.';

  @override
  String get error403 =>
      'O servidor negou o acesso. O voucher pode já ter sido resgatado, ou seu IP está bloqueado.';

  @override
  String get error404 =>
      'Endpoint não encontrado. Verifique se a URL do LNbits está correta.';

  @override
  String get error500 =>
      'Erro do servidor LNbits. Verifique os logs do LNbits.';

  @override
  String get error502 => 'O LNbits está inacessível através do seu proxy.';

  @override
  String get error503 => 'O LNbits está temporariamente indisponível.';

  @override
  String get error520 =>
      'O LNbits não tem nenhum backend Lightning configurado (VoidWallet). Conecte um nó Lightning no LNbits → Server → Funding.';

  @override
  String get errorInsufficientFunds =>
      'Não há sats suficientes na sua carteira para este pagamento.';

  @override
  String get errorSelfPayment =>
      'Esta fatura é desta carteira. Você não pode pagar a si mesmo.';

  @override
  String get errorNotLnurl => 'Este link não é um serviço LNURL válido';

  @override
  String get errorReadOnlyWallet =>
      'Esta é uma carteira somente leitura. Só pode receber, não enviar.';

  @override
  String get walletReadOnly => 'Somente leitura';

  @override
  String get errorLnurlInsecureCallback =>
      'O servidor LNbits retornou uma URL de callback insegura (http://). Isso geralmente significa que o LNbits está atrás de um proxy reverso e não conhece seu endereço HTTPS público. No host do LNbits, defina LNBITS_BASE_URL=https://seu-host no .env e reinicie. Como alternativa, configure o proxy para repassar X-Forwarded-Proto: https.';

  @override
  String errorServerGeneric(String code) {
    return 'Erro do servidor ($code).';
  }

  @override
  String get lnurlAuthErrorKeyInUse =>
      'Esta chave de autenticação já está em uso para este site. Aguarde um momento e tente novamente, ou recarregue o QR de login.';

  @override
  String get lnurlAuthErrorInvalidSignature =>
      'O site rejeitou a assinatura de autenticação. Tente novamente.';

  @override
  String get lnurlAuthErrorLinkingKeyMismatch =>
      'O site não reconhece esta chave de autenticação. Isso geralmente significa que você se autenticou antes com uma semente de carteira diferente.';

  @override
  String lnurlAuthErrorGeneric(String reason) {
    return 'LNURL-auth falhou: $reason';
  }

  @override
  String get bolt12TitlePayOffer => 'Pagar oferta BOLT12';

  @override
  String get bolt12TitlePayInvoice => 'Pagar fatura BOLT12';

  @override
  String get bolt12AmountLabel => 'Valor (sats)';

  @override
  String get bolt12MemoLabel => 'Nota do pagador (opcional)';

  @override
  String get bolt12RawStringLabel => 'String BOLT12';

  @override
  String get bolt12NotSupported =>
      'Este servidor LNbits não suporta BOLT12. Seu nó Lightning pode não entender BOLT12, ou a extensão BOLT12 do LNbits não está instalada.';

  @override
  String get myContactTitle => 'Meu contato';

  @override
  String get myContactLnAddressSection => 'Lightning Address';

  @override
  String get myContactBolt12Section => 'Oferta BOLT12';

  @override
  String get myContactAddLnAddress => 'Adicione sua Lightning address';

  @override
  String get myContactAddBolt12 => 'Adicione sua oferta BOLT12';

  @override
  String get myContactLnAddressHint =>
      'user@domain. Se o domínio for o servidor LNbits, o EmberSpark a define lá; caso contrário, é salva como está.';

  @override
  String get myContactBolt12Hint =>
      'lno1… — cole a oferta que seu nó Lightning gerou.';

  @override
  String get myContactInvalidLnAddress => 'Não é uma Lightning address válida.';

  @override
  String get myContactInvalidBolt12 => 'Não é uma oferta BOLT12 válida.';

  @override
  String get myContactCopied => 'Copiado';

  @override
  String get myContactShareSubject => 'Meu contato Lightning';

  @override
  String get myContactRemoveConfirm => 'Remover esta entrada?';

  @override
  String get myContactAutoGenerate => 'Gerar automaticamente';

  @override
  String get myContactLnurlpSection => 'Link LNURL-pay';

  @override
  String get myContactAddLnurlp => 'Adicione seu link LNURL-pay';

  @override
  String get myContactLnurlpHint =>
      'lnurl1… — cole seu link ou gere um automaticamente a partir do servidor LNbits.';

  @override
  String get myContactInvalidLnurlp => 'Não é um link LNURL-pay válido.';

  @override
  String get myContactGenerating => 'Gerando…';

  @override
  String get myContactLnurlpExtensionMissing =>
      'O LNbits não tem a extensão LNURL-pay instalada.';

  @override
  String get myContactReadOnlyNoGenerate =>
      'Esta é uma carteira somente leitura, portanto não pode criar um link no servidor. Você ainda pode colar um existente abaixo.';

  @override
  String get myContactLnAddressServerUpdated =>
      'Lightning Address atualizada no servidor.';

  @override
  String get myContactBolt12ExtensionMissing =>
      'O LNbits não tem uma extensão BOLT12 instalada, ou seu nó Lightning não suporta BOLT12.';

  @override
  String get myContactAvatarPriority =>
      'Seu avatar de perfil é gerado a partir de um destes identificadores. Toque em uma estrela para escolher qual. Caso contrário, usa a Lightning address, depois BOLT12 e depois LNURL.';

  @override
  String get myContactSetDefault => 'Definir como identidade padrão';

  @override
  String get myContactUnsetDefault => 'Remover como identidade padrão';

  @override
  String get myContactTabLnAddress => 'LN Address';

  @override
  String get myContactTabLnurlp => 'LNURL';

  @override
  String get myContactTabBolt12 => 'BOLT12';

  @override
  String get myContactLnAddressUse =>
      'Fácil de compartilhar com amigos e familiares.';

  @override
  String get myContactLnurlpUse =>
      'String bech32 menos identificável, mas roteia pelo mesmo servidor.';

  @override
  String get myContactBolt12Use =>
      'Melhor privacidade: os pagamentos vão direto pela Lightning, sem operador de domínio no meio.';

  @override
  String get walletsMenu => 'Carteiras';

  @override
  String get walletsTitle => 'Carteiras';

  @override
  String get walletsEmpty => 'Ainda não há carteiras — adicione a primeira.';

  @override
  String get walletsAdd => 'Adicionar carteira';

  @override
  String get walletsActive => 'Ativa';

  @override
  String get walletsEdit => 'Editar carteira';

  @override
  String get walletsRemove => 'Remover carteira';

  @override
  String get walletsRemoveConfirm =>
      'Remover esta carteira deste dispositivo? Suas entradas de Meu contato serão apagadas. A carteira no servidor não é afetada.';

  @override
  String get walletsDuplicate => 'Esta carteira já foi adicionada.';

  @override
  String get walletsActiveLabelTooltip => 'Toque para trocar de carteira';

  @override
  String get loginWalletNameLabel => 'Nome da carteira (opcional)';

  @override
  String get loginWalletNameHint => 'Padrão: o nome de host do servidor';
}
