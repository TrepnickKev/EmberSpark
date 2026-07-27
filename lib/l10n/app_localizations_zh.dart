// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'EmberSpark';

  @override
  String get appLocked => '已锁定';

  @override
  String get appUnlock => '解锁';

  @override
  String get appTryAgain => '重试';

  @override
  String get appSetupFirstToast => '请先设置钱包';

  @override
  String get commonCopy => '复制';

  @override
  String get commonCancel => '取消';

  @override
  String get commonDelete => '删除';

  @override
  String get commonSave => '保存';

  @override
  String get commonContinue => '继续';

  @override
  String get commonScanQr => '扫描二维码';

  @override
  String get commonScan => '扫描';

  @override
  String get commonShare => '分享';

  @override
  String get commonNfc => 'NFC';

  @override
  String get commonPaste => '粘贴';

  @override
  String get commonImage => '图片';

  @override
  String get commonRetry => '重试';

  @override
  String get commonEdit => '编辑';

  @override
  String get commonAmount => '金额（sats）';

  @override
  String get commonUnknownError => '未知错误';

  @override
  String get receiveShareSubject => 'Lightning 发票';

  @override
  String get nfcHoldTag => '将 NFC 标签靠近手机…';

  @override
  String get nfcWriteSuccess => '已写入标签';

  @override
  String get nfcWriteFailed => '无法写入标签';

  @override
  String get nfcReadFailed => '无法读取标签';

  @override
  String get nfcUnavailable => '此设备不支持 NFC';

  @override
  String get imageNoQr => '图片中未找到二维码';

  @override
  String get clipboardEmpty => '剪贴板为空';

  @override
  String get homeScan => '扫描二维码';

  @override
  String get homeSend => '发送';

  @override
  String get homeReceive => '接收';

  @override
  String get homeContacts => '联系人';

  @override
  String get homeSettings => '设置';

  @override
  String get homeLogout => '退出登录';

  @override
  String get homeMyContact => '我的联系方式';

  @override
  String get homeBoltCard => 'Bolt Card';

  @override
  String homeSatsReceived(String amount) {
    return '已收到 $amount sats';
  }

  @override
  String homeSatsSent(String amount) {
    return '已发送 $amount sats';
  }

  @override
  String get homeSatsUnit => 'sats';

  @override
  String get boltCardTitle => 'Bolt Cards';

  @override
  String get boltCardExtensionMissing => '此服务器未安装 Boltcards 扩展。';

  @override
  String get boltCardNone => '还没有 Bolt Card。点按“添加”来设置一张。';

  @override
  String get boltCardAdd => '添加 Bolt Card';

  @override
  String get boltCardEdit => '编辑卡片';

  @override
  String get boltCardName => '卡片名称';

  @override
  String get boltCardTxLimit => '每次点按限额（sats）';

  @override
  String get boltCardDailyLimit => '每日限额（sats）';

  @override
  String get boltCardCreate => '创建';

  @override
  String get boltCardSave => '保存';

  @override
  String get boltCardProgram => '写入卡片';

  @override
  String get boltCardVerify => '验证';

  @override
  String get boltCardWipe => '重置';

  @override
  String get boltCardDelete => '删除';

  @override
  String get boltCardEnable => '启用';

  @override
  String get boltCardDisable => '停用';

  @override
  String get boltCardEnabled => '已启用';

  @override
  String get boltCardDisabled => '已停用';

  @override
  String boltCardCounter(int count) {
    return '$count 次点按';
  }

  @override
  String boltCardLimits(int tx, int daily) {
    return '每次点按 $tx sats，每日 $daily sats';
  }

  @override
  String get boltCardHoldToProgram => '将卡片贴近手机以写入。完成前请勿移开。';

  @override
  String get boltCardHoldToVerify => '将卡片贴近手机以读取。';

  @override
  String get boltCardHoldToWipe => '将卡片贴近手机以重置。完成前请勿移开。';

  @override
  String get boltCardProgrammed => '卡片已写入。';

  @override
  String get boltCardProgramFailed => '无法写入卡片。';

  @override
  String get boltCardNotBlank => '此卡片已写入。请先重置。';

  @override
  String get boltCardUidAlreadyRegistered =>
      '服务器上已注册了具有此 UID 的 Bolt Card。请删除现有卡片记录后重试。';

  @override
  String get boltCardVerifyNotProgrammed => '此卡片尚未写入，因此没有可验证的内容。';

  @override
  String get boltCardVerified => '卡片可用，且指向此钱包。';

  @override
  String get boltCardVerifiedBadge => '已验证';

  @override
  String get boltCardVerifyWrongServer => '此卡片指向另一个服务器。';

  @override
  String get boltCardVerifyUidMismatch =>
      '此卡片的芯片 ID 与服务器记录不匹配。请重置卡片，然后重新添加并写入，以便保存正确的 ID。';

  @override
  String get boltCardVerifyCounterBehind => '此卡片的点按计数器落后于服务器。请重新写入卡片以重置它。';

  @override
  String get boltCardTagLost => '卡片移开得太早。请将它平贴在手机背面并保持不动，直到操作完成，然后重试。';

  @override
  String get boltCardChargeOnlyTitle => 'Bolt Card';

  @override
  String get boltCardChargeOnlyBody => 'Bolt Card 只能收款，不能付款。你想收款吗？';

  @override
  String get boltCardChargeAction => '收款';

  @override
  String get boltCardVerifyFailed => '无法验证卡片。';

  @override
  String get boltCardWipeConfirm => '将此卡片重置为出厂密钥吗？在你重新写入之前它将停止工作。';

  @override
  String get boltCardWiped => '卡片已重置为出厂密钥。';

  @override
  String get boltCardWipeFailed => '无法重置卡片。';

  @override
  String get boltCardDeleteConfirm => '从服务器删除此卡片吗？';

  @override
  String get loginTitle => '设置钱包';

  @override
  String get loginUrlLabel => 'LNbits 网址';

  @override
  String get loginUrlHint => 'https://your.node';

  @override
  String get loginAdminKeyLabel => '管理员 API 密钥';

  @override
  String get loginAdminKeyHelper => '管理员密钥用于完全访问，或使用 invoice/read 密钥创建只读钱包';

  @override
  String get loginAdminKeyRequired => '需要管理员密钥';

  @override
  String get loginScanUrlTitle => '扫描 LNbits 网址';

  @override
  String get loginScanAdminTitle => '扫描管理员密钥';

  @override
  String get loginHint =>
      '在 LNbits → wallet → \"API info\" → Admin key 中找到二维码。';

  @override
  String get disclaimerTitle => 'EmberSpark 适合谁？';

  @override
  String get disclaimerBody =>
      'EmberSpark 是自托管 LNbits Lightning 钱包的客户端。它适合运行自己的 LNbits 服务器的人，或由这样的人授予钱包访问权限的人。如果你不属于这两者，此应用不适合你。';

  @override
  String get disclaimerAck => '我明白了';

  @override
  String get sendTitle => '发送';

  @override
  String get sendBolt11Label => 'BOLT11 发票';

  @override
  String get sendPay => '支付';

  @override
  String get sendPaymentSent => '支付已发送';

  @override
  String get sendPasteFirst => '请先粘贴一张发票';

  @override
  String get sendAnyAmount => '任意金额';

  @override
  String sendAmountWithSats(String amount) {
    return '$amount sats';
  }

  @override
  String get sendToTitle => '发送至…';

  @override
  String get sendToInputLabel => '地址或支付数据';

  @override
  String get sendToInputHint => 'BOLT11、LNURL 或 user@host';

  @override
  String get sendToScanTitle => '扫描以发送';

  @override
  String get sendToContacts => '联系人';

  @override
  String get sendToNoContacts => '还没有联系人';

  @override
  String get contactsSearchHint => '筛选联系人';

  @override
  String get contactsNoMatches => '没有匹配的联系人';

  @override
  String get receiveTitle => '接收';

  @override
  String get receiveReusableAddress => '你的可重复使用地址';

  @override
  String get receiveAmount => '金额';

  @override
  String get receiveMemo => '备注';

  @override
  String get receiveCreateInvoice => '创建发票';

  @override
  String get receiveInvoiceCopied => '发票已复制';

  @override
  String get receiveAmountError => '请输入一个正数金额';

  @override
  String get receiveEnterAmountFirst => '请先输入金额';

  @override
  String receiveCardCharged(int sats) {
    return '已从卡中收取 $sats sats';
  }

  @override
  String receiveSatsApprox(String amount) {
    return '≈ $amount sats';
  }

  @override
  String get receiveRatesUnavailable => '实时汇率不可用 — 仅显示 sats';

  @override
  String get receiveCurrencySats => 'sats';

  @override
  String get contactsTitle => '联系人';

  @override
  String get contactsEmpty => '还没有联系人 — 点按 + 添加一个';

  @override
  String contactsDeleteTitle(String name) {
    return '删除 $name 吗？';
  }

  @override
  String get contactsNew => '新建联系人';

  @override
  String get contactsEdit => '编辑联系人';

  @override
  String get contactsScanTitle => '扫描目标';

  @override
  String get contactsName => '名称';

  @override
  String get contactsDestinationLabel => 'Lightning address、LNURL 或 BOLT11';

  @override
  String get contactsRequired => '需要名称和目标';

  @override
  String get contactsInvalidDestination =>
      '不是有效的 Lightning 目标。请使用 Lightning address（user@host.tld）、BOLT11 发票、BOLT12 offer/发票（lno1…/lni1…）或 LNURL。';

  @override
  String get contactsImport => '导入联系人';

  @override
  String get contactsExport => '导出联系人';

  @override
  String get contactsExportEmpty => '没有可导出的联系人';

  @override
  String get contactsShareSubject => 'EmberSpark 联系人';

  @override
  String get contactsImportFailed => '无法读取该联系人文件';

  @override
  String contactsImported(int count) {
    return '已导入 $count 个联系人';
  }

  @override
  String get historyTitle => '历史';

  @override
  String get historyEmpty => '还没有交易';

  @override
  String get historyPaymentDefault => 'Lightning 支付';

  @override
  String get historyPending => '待处理';

  @override
  String historyFee(String amount) {
    return '手续费 $amount';
  }

  @override
  String get historyDetailsTitle => '交易';

  @override
  String get historyDirectionSent => '已发送';

  @override
  String get historyDirectionReceived => '已接收';

  @override
  String get historyStatusPaid => '已支付';

  @override
  String get historyStatusPendingLabel => '待处理';

  @override
  String get historyAmountLabel => '金额';

  @override
  String get historyFeeLabel => '手续费';

  @override
  String get historyMemoLabel => '备注';

  @override
  String get historyCommentLabel => '评论';

  @override
  String get historyTimestampLabel => '时间';

  @override
  String get historyPaymentHashLabel => '支付哈希';

  @override
  String get historyInvoiceLabel => '发票';

  @override
  String get historyClose => '关闭';

  @override
  String get historyJustNow => '刚刚';

  @override
  String historyMinutesAgo(int minutes) {
    return '$minutes 分钟前';
  }

  @override
  String historyHoursAgo(int hours) {
    return '$hours 小时前';
  }

  @override
  String historyDaysAgo(int days) {
    return '$days 天前';
  }

  @override
  String get lockedLabel => '已锁定';

  @override
  String get lockUnlock => '解锁';

  @override
  String get lockTryAgain => '重试';

  @override
  String get lnurlTitleAuthenticate => '认证';

  @override
  String get lnurlTitlePay => '发送（LNURL）';

  @override
  String get lnurlTitleWithdraw => '接收（LNURL）';

  @override
  String get lnurlTitleGeneric => 'LNURL';

  @override
  String get lnurlResolvedExplain => '已解析的网址 — 将它粘贴到浏览器中，查看服务器在钱包之外是否会响应：';

  @override
  String get lnurlCopyUrl => '复制网址';

  @override
  String get lnurlUrlCopied => '网址已复制';

  @override
  String lnurlAuthRegisterAt(String host) {
    return '在 $host 注册';
  }

  @override
  String lnurlAuthLinkAt(String host) {
    return '在 $host 关联账户';
  }

  @override
  String lnurlAuthAuthenticateAt(String host) {
    return '在 $host 进行认证';
  }

  @override
  String lnurlAuthLoginAt(String host) {
    return '登录到 $host';
  }

  @override
  String get lnurlAuthExplain =>
      '将从你的钱包种子派生出用于此站点的唯一签名密钥。站点只能看到你的公钥 — 你的钱包和余额保持私密。';

  @override
  String get lnurlAuthConfirm => '确认';

  @override
  String lnurlAuthSuccess(String host) {
    return '已在 $host 完成认证';
  }

  @override
  String lnurlAmountRange(int min, int max) {
    return '范围：$min – $max sats';
  }

  @override
  String lnurlAmountOutOfRange(int min, int max) {
    return '金额必须在 $min 到 $max sats 之间';
  }

  @override
  String get lnurlAmountPositive => '请输入一个正数金额';

  @override
  String get lnurlGetAndPay => '发送';

  @override
  String get lnurlWithdraw => '提取';

  @override
  String get lnurlWithdrawDefaultMemo => 'LNURL-withdraw';

  @override
  String lnurlWithdrawing(int amount) {
    return '正在提取 $amount sats…';
  }

  @override
  String get lnurlCommentLabel => '备注（可选）';

  @override
  String lnurlCommentHelp(int max) {
    return '最多 $max 个字符';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSubtitle => '选择应用语言';

  @override
  String get languageSystemDefault => '系统默认';

  @override
  String get settingsDisplayCurrency => '显示货币';

  @override
  String get settingsDisplayCurrencySubtitle => '用于余额下方的法币金额';

  @override
  String get settingsLockOnLaunch => '启动时锁定应用';

  @override
  String get settingsLockSubtitleEnabled => '打开 EmberSpark 需要生物识别或设备 PIN/图案。';

  @override
  String get settingsLockSubtitleUnavailable => '此设备未设置屏幕锁定。请在系统设置中设置一个以启用此选项。';

  @override
  String get settingsLockConfirmReason => '确认以启用应用锁定';

  @override
  String get settingsLockNeedSetup => '请先在手机上设置屏幕锁定或生物识别。';

  @override
  String get settingsTrustTls => '允许未验证的 HTTPS';

  @override
  String get settingsTrustTlsSubtitle =>
      '信任自签名和链不完整的证书。某些业余 Lightning 服务器和 .onion 服务需要此项。仅对你信任的服务器启用。';

  @override
  String get settingsAbout => '关于';

  @override
  String get aboutTitle => '关于';

  @override
  String get aboutTagline => '面向 LNbits 的轻量级 Lightning 钱包';

  @override
  String get aboutCopyright => '© 2026 Trepnick Solutions';

  @override
  String get aboutVersionLabel => '版本';

  @override
  String get aboutCheckAgain => '再次检查';

  @override
  String get aboutCheckingForUpdates => '正在检查更新…';

  @override
  String get aboutUpToDate => '已是最新';

  @override
  String aboutUpdateAvailable(String version) {
    return '有可用更新：v$version';
  }

  @override
  String get aboutOpenRelease => '打开版本';

  @override
  String get aboutCheckFailed => '无法检查更新';

  @override
  String get aboutUpdatesViaStore => '更新由 Google Play 管理';

  @override
  String get aboutSupportDevelopment => '支持开发';

  @override
  String get aboutSupportBody =>
      'EmberSpark 是在业余时间开发和维护的。如果它让你更轻松地管理 sats，欢迎向下方地址发送一些 on-chain BTC。每一点都让项目得以延续。谢谢！在 GitHub 上报告 bug 或提出功能请求同样受欢迎。';

  @override
  String get aboutDonateMethods => '通过 Lightning / On-Chain 捐赠';

  @override
  String get aboutContributeOnGithub => '在 GitHub 上贡献';

  @override
  String get aboutCopyAddress => '复制地址';

  @override
  String get aboutAddressCopied => '地址已复制';

  @override
  String get aboutLicensesTitle => '开源许可证';

  @override
  String get aboutLicensesSubtitle => 'Flutter SDK 和第三方软件包';

  @override
  String get errorTlsCertificate =>
      '无法验证服务器的 TLS 证书。\n如果你信任此服务器，请在设置中启用“允许未验证的 HTTPS”。';

  @override
  String get errorTlsHandshake =>
      '无法与服务器建立安全连接。\n服务器可能使用了过时的 TLS 版本，或其证书无效。\n如果你信任该服务器，请在设置中尝试“允许未验证的 HTTPS”。';

  @override
  String get errorHostLookup => '无法解析 LNbits 主机名。\n请检查网址和你的网络连接。';

  @override
  String get errorConnectionRefused => 'LNbits 服务器拒绝了连接。\n请检查网址以及服务器是否在运行。';

  @override
  String get errorConnectionDropped => '与 LNbits 服务器的连接已断开。请重试。';

  @override
  String get errorNetworkUnreachable => '无网络连接。请检查 Wi-Fi / 移动数据。';

  @override
  String get errorSocket => '无法连接到 LNbits 服务器。请检查你的网络。';

  @override
  String get errorTimeout => '服务器未及时响应。请重试。';

  @override
  String get error401 => '认证失败。请检查你的管理员 / invoice API 密钥。';

  @override
  String get error403 => '服务器拒绝访问。代金券可能已被兑换，或你的 IP 被封禁。';

  @override
  String get error404 => '未找到端点。请检查 LNbits 网址是否正确。';

  @override
  String get error500 => 'LNbits 服务器错误。请检查 LNbits 日志。';

  @override
  String get error502 => '无法通过代理访问 LNbits。';

  @override
  String get error503 => 'LNbits 暂时不可用。';

  @override
  String get error520 =>
      'LNbits 未配置 Lightning 后端（VoidWallet）。请在 LNbits → Server → Funding 中连接一个 Lightning 节点。';

  @override
  String get errorInsufficientFunds => '你的钱包中 sats 不足以完成此支付。';

  @override
  String get errorSelfPayment => '这张发票来自本钱包，无法向自己付款。';

  @override
  String get errorNotLnurl => '此链接不是有效的 LNURL 服务';

  @override
  String get errorReadOnlyWallet => '这是一个只读钱包，只能接收，不能发送。';

  @override
  String get walletReadOnly => '只读';

  @override
  String get errorLnurlInsecureCallback =>
      'LNbits 服务器返回了不安全的（http://）回调网址。这通常意味着 LNbits 位于反向代理之后，且不知道其公开的 HTTPS 地址。在 LNbits 主机上，于 .env 中设置 LNBITS_BASE_URL=https://your-host 并重启。或者，将代理配置为传递 X-Forwarded-Proto: https。';

  @override
  String errorServerGeneric(String code) {
    return '服务器错误（$code）。';
  }

  @override
  String get lnurlAuthErrorKeyInUse => '此认证密钥已在此站点使用中。请稍候重试，或重新加载登录二维码。';

  @override
  String get lnurlAuthErrorInvalidSignature => '站点拒绝了认证签名。请重试。';

  @override
  String get lnurlAuthErrorLinkingKeyMismatch =>
      '站点无法识别此认证密钥。这通常意味着你之前使用了不同的钱包种子进行认证。';

  @override
  String lnurlAuthErrorGeneric(String reason) {
    return 'LNURL-auth 失败：$reason';
  }

  @override
  String get bolt12TitlePayOffer => '支付 BOLT12 offer';

  @override
  String get bolt12TitlePayInvoice => '支付 BOLT12 发票';

  @override
  String get bolt12AmountLabel => '金额（sats）';

  @override
  String get bolt12MemoLabel => '付款人备注（可选）';

  @override
  String get bolt12RawStringLabel => 'BOLT12 字符串';

  @override
  String get bolt12NotSupported =>
      '此 LNbits 服务器不支持 BOLT12。你的 Lightning 节点可能不理解 BOLT12，或未安装 LNbits BOLT12 扩展。';

  @override
  String get myContactTitle => '我的联系方式';

  @override
  String get myContactLnAddressSection => 'Lightning Address';

  @override
  String get myContactBolt12Section => 'BOLT12 offer';

  @override
  String get myContactAddLnAddress => '添加你的 Lightning address';

  @override
  String get myContactAddBolt12 => '添加你的 BOLT12 offer';

  @override
  String get myContactLnAddressHint =>
      'user@domain。如果域名是 LNbits 服务器，EmberSpark 会在那里设置它；否则按原样保存。';

  @override
  String get myContactBolt12Hint => 'lno1… — 粘贴你的 Lightning 节点生成的 offer。';

  @override
  String get myContactInvalidLnAddress => '不是有效的 Lightning address。';

  @override
  String get myContactInvalidBolt12 => '不是有效的 BOLT12 offer。';

  @override
  String get myContactCopied => '已复制';

  @override
  String get myContactShareSubject => '我的 Lightning 联系方式';

  @override
  String get myContactRemoveConfirm => '移除此条目吗？';

  @override
  String get myContactAutoGenerate => '自动生成';

  @override
  String get myContactLnurlpSection => 'LNURL-pay 链接';

  @override
  String get myContactAddLnurlp => '添加你的 LNURL-pay 链接';

  @override
  String get myContactLnurlpHint => 'lnurl1… — 粘贴你的链接或从 LNbits 服务器自动生成一个。';

  @override
  String get myContactInvalidLnurlp => '不是有效的 LNURL-pay 链接。';

  @override
  String get myContactGenerating => '正在生成…';

  @override
  String get myContactLnurlpExtensionMissing => 'LNbits 未安装 LNURL-pay 扩展。';

  @override
  String get myContactLnAddressServerUpdated => 'Lightning Address 已在服务器上更新。';

  @override
  String get myContactBolt12ExtensionMissing =>
      'LNbits 未安装 BOLT12 扩展，或你的 Lightning 节点不支持 BOLT12。';

  @override
  String get myContactAvatarPriority =>
      '你的个人头像由这些标识之一生成。点按星标选择使用哪一个。否则将依次使用 Lightning address、BOLT12、LNURL。';

  @override
  String get myContactSetDefault => '设为默认身份';

  @override
  String get myContactUnsetDefault => '取消默认身份';

  @override
  String get myContactTabLnAddress => 'LN Address';

  @override
  String get myContactTabLnurlp => 'LNURL';

  @override
  String get myContactTabBolt12 => 'BOLT12';

  @override
  String get myContactLnAddressUse => '便于与亲友分享。';

  @override
  String get myContactLnurlpUse => '识别度较低的 bech32 字符串，但仍通过同一服务器路由。';

  @override
  String get myContactBolt12Use => '隐私最佳：支付直接通过 Lightning 进行，中间没有域名运营方。';

  @override
  String get walletsMenu => '钱包';

  @override
  String get walletsTitle => '钱包';

  @override
  String get walletsEmpty => '还没有钱包 — 添加第一个。';

  @override
  String get walletsAdd => '添加钱包';

  @override
  String get walletsActive => '当前';

  @override
  String get walletsEdit => '编辑钱包';

  @override
  String get walletsRemove => '移除钱包';

  @override
  String get walletsRemoveConfirm =>
      '从此设备移除这个钱包吗？它的“我的联系方式”条目将被清除。服务器上的钱包不受影响。';

  @override
  String get walletsDuplicate => '此钱包已添加。';

  @override
  String get walletsActiveLabelTooltip => '点按以切换钱包';

  @override
  String get loginWalletNameLabel => '钱包名称（可选）';

  @override
  String get loginWalletNameHint => '默认为服务器主机名';
}
