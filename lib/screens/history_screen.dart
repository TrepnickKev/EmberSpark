import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../services/friendly_error.dart';
import '../services/payment_search.dart';
import '../services/wallet_backend.dart';
import '../services/price_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Payment>? payments;
  String? error;
  bool loading = true;
  String fiatCurrency = 'USD';
  double? fiatRate;

  bool _searching = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _startSearch() => setState(() => _searching = true);

  void _stopSearch() => setState(() {
        _searching = false;
        _searchCtrl.clear();
        _query = '';
      });

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final WalletBackend svc = await loadWalletBackend();
      final results = await Future.wait([
        svc.listPayments(),
        getSelectedCurrency(),
        getBtcRates(),
      ]);
      if (!mounted) return;
      final list = results[0] as List<Payment>;
      final cur = results[1] as String;
      final rates = results[2] as Map<String, double>?;
      setState(() {
        payments = list;
        fiatCurrency = cur;
        fiatRate = rates?[cur];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => error = friendlyError(AppLocalizations.of(context)!, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.historySearchHint,
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _query = v),
              )
            : Text(l10n.historyTitle),
        actions: _searching
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _stopSearch,
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: l10n.historySearchHint,
                  onPressed: _startSearch,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: loading ? null : _load,
                ),
              ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(l10n),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (loading && payments == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && payments == null) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error!,
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }
    final all = payments ?? const [];
    if (all.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Text(
              l10n.historyEmpty,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      );
    }
    final list = _query.trim().isEmpty
        ? all
        : all.where((p) => paymentMatchesQuery(p, _query)).toList();
    if (list.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Text(
              l10n.historyNoResults,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => _PaymentTile(
        payment: list[i],
        fiatCurrency: fiatCurrency,
        fiatRate: fiatRate,
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.payment,
    required this.fiatCurrency,
    required this.fiatRate,
  });

  final Payment payment;
  final String fiatCurrency;
  final double? fiatRate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final incoming = payment.incoming;
    final color = payment.pending
        ? Colors.amber
        : incoming
            ? Colors.greenAccent
            : Colors.redAccent;
    final sign = incoming ? '+' : '−';
    final abs = payment.amountSats.abs();
    final feePart = !incoming && payment.feeSats > 0
        ? ' (${l10n.historyFee(payment.feeSats.toString())})'
        : '';
    final satsText = '$sign$abs ${l10n.homeSatsUnit}$feePart';
    final rate = fiatRate;
    final fiatText = rate == null
        ? null
        : '$sign${formatFiat((abs / 100000000) * rate, fiatCurrency)}';
    final memo = payment.memo;
    final comment = payment.comment;
    final titleText = comment.isEmpty
        ? (memo.isEmpty ? l10n.historyPaymentDefault : memo)
        : (memo.isEmpty ? comment : '$memo: $comment');
    return ListTile(
      onTap: () => _showPaymentDetails(
        context,
        l10n,
        payment,
        fiatCurrency,
        fiatRate,
      ),
      leading: Icon(
        incoming ? Icons.arrow_downward : Icons.arrow_upward,
        color: color,
      ),
      title: Text(
        titleText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${_formatTime(context, l10n, payment.time)}'
        '${payment.pending ? ' · ${l10n.historyPending}' : ''}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: ValueListenableBuilder<AmountDisplayMode>(
        valueListenable: amountDisplayMode,
        builder: (context, mode, _) {
          final showFiat =
              mode == AmountDisplayMode.fiat && fiatText != null;
          return InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: fiatText == null ? null : () => toggleAmountDisplayMode(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                showFiat ? fiatText : satsText,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}

String _formatTime(BuildContext context, AppLocalizations l10n, DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inSeconds < 60) return l10n.historyJustNow;
  if (diff.inMinutes < 60) return l10n.historyMinutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l10n.historyHoursAgo(diff.inHours);
  if (diff.inDays < 7) return l10n.historyDaysAgo(diff.inDays);
  return MaterialLocalizations.of(context).formatCompactDate(t);
}

Future<void> _showPaymentDetails(
  BuildContext context,
  AppLocalizations l10n,
  Payment p,
  String fiatCurrency,
  double? fiatRate,
) {
  final ml = MaterialLocalizations.of(context);
  final use24h = MediaQuery.of(context).alwaysUse24HourFormat;
  final dateLine = ml.formatFullDate(p.time);
  final timeLine = ml.formatTimeOfDay(
    TimeOfDay.fromDateTime(p.time),
    alwaysUse24HourFormat: use24h,
  );
  final absSats = p.amountSats.abs();
  final amountFiat = fiatRate == null
      ? null
      : formatFiat((absSats / 100000000) * fiatRate, fiatCurrency);
  final feeFiat = (fiatRate == null || p.feeSats == 0)
      ? null
      : formatFiat((p.feeSats / 100000000) * fiatRate, fiatCurrency);
  final showInvoice =
      p.pending && p.incoming && p.bolt11.isNotEmpty;
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.historyDetailsTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _detailRow(l10n.historyTimestampLabel, '$dateLine · $timeLine'),
            _detailRow(
              p.incoming
                  ? l10n.historyDirectionReceived
                  : l10n.historyDirectionSent,
              p.pending
                  ? l10n.historyStatusPendingLabel
                  : l10n.historyStatusPaid,
            ),
            _detailRow(
              l10n.historyAmountLabel,
              '${formatThousands(absSats)} ${l10n.homeSatsUnit}'
              '${amountFiat == null ? '' : '  ·  $amountFiat'}',
            ),
            if (p.feeSats > 0)
              _detailRow(
                l10n.historyFeeLabel,
                '${formatThousands(p.feeSats)} ${l10n.homeSatsUnit}'
                '${feeFiat == null ? '' : '  ·  $feeFiat'}',
              ),
            if (p.memo.isNotEmpty)
              _detailRow(l10n.historyMemoLabel, p.memo),
            if (p.comment.isNotEmpty)
              _detailRow(l10n.historyCommentLabel, p.comment),
            if (p.paymentHash.isNotEmpty)
              _detailRow(
                l10n.historyPaymentHashLabel,
                p.paymentHash,
                monospace: true,
              ),
            if (showInvoice) ...[
              const SizedBox(height: 12),
              Text(
                l10n.historyInvoiceLabel,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: QrImageView(
                      data: p.bolt11,
                      size: 220,
                      backgroundColor: Colors.white,
                      embeddedImage:
                          const AssetImage('images/Logo_icon.png'),
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(40, 40),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.copy),
                    label: Text(l10n.commonCopy),
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: p.bolt11),
                      );
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.ios_share),
                    label: Text(l10n.commonShare),
                    onPressed: () => SharePlus.instance.share(
                      ShareParams(text: p.bolt11),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.historyClose),
              ),
            ),
          ],
        ),
        ),
      ),
    ),
  );
}

Widget _detailRow(String label, String value, {bool monospace = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
        const SizedBox(height: 2),
        SelectableText(
          value,
          style: TextStyle(
            fontSize: 14,
            fontFamily: monospace ? 'monospace' : null,
          ),
        ),
      ],
    ),
  );
}
