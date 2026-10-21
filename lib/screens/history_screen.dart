import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../services/friendly_error.dart';
import '../services/payment_cache.dart';
import '../services/payment_search.dart';
import '../services/wallet_account_service.dart';
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
  // Historical BTC price per currency+day (btcHistKey), so each row shows its
  // value at the transaction's date. Filled after the list first renders.
  Map<String, double> _histRates = {};
  // When the shown list comes from the offline cache: when it was saved.
  // Null once a live load succeeded.
  DateTime? _cachedAt;

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
    final wallet = await getCurrentWallet();
    final cur = await getSelectedCurrency();
    if (!mounted) return;
    setState(() => fiatCurrency = cur);
    // Fiat rates load alongside the list. getBtcRates never throws and falls
    // back to the last persisted rates when offline.
    final ratesDone = getBtcRates().then((rates) {
      if (mounted) setState(() => fiatRate = rates?[cur]);
    });
    // Show the offline copy right away when nothing is on screen yet, so the
    // history also opens in flight mode or when the server is down.
    if (payments == null && wallet != null) {
      final cached = await loadCachedPayments(wallet.id);
      if (mounted && cached != null) {
        setState(() {
          payments = cached.payments;
          _cachedAt = cached.savedAt;
        });
        unawaited(_warmHistRates(cur, cached.payments));
      }
    }
    try {
      final WalletBackend svc = await loadWalletBackend();
      final list = await svc.listPayments();
      if (!mounted) return;
      setState(() {
        payments = list;
        _cachedAt = null;
      });
      if (wallet != null) await saveCachedPayments(wallet.id, list);
      // Warm historical prices so rows show the value at each transaction's
      // date; the list already rendered (current-rate fallback).
      await _warmHistRates(cur, list);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = friendlyError(AppLocalizations.of(context)!, e));
    } finally {
      await ratesDone;
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _warmHistRates(String cur, List<Payment> list) async {
    final hist = await getBtcRatesAt(cur, list.map((p) => p.time));
    if (mounted && hist.isNotEmpty) {
      setState(() => _histRates = {..._histRates, ...hist});
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
    // Offline with a cached list: a calm note on top instead of an error.
    final cachedAt = _cachedAt;
    final offline = cachedAt != null && error != null;
    final head = offline ? 1 : 0;
    return ListView.separated(
      itemCount: list.length + head,
      separatorBuilder: (_, i) => offline && i == 0
          ? const SizedBox.shrink()
          : const Divider(height: 1),
      itemBuilder: (_, i) {
        if (offline && i == 0) return _offlineBanner(l10n, cachedAt);
        final p = list[i - head];
        return _PaymentTile(
          payment: p,
          fiatCurrency: fiatCurrency,
          fiatRate: fiatRate,
          histRate: _histRates[btcHistKey(fiatCurrency, p.time)],
        );
      },
    );
  }

  Widget _offlineBanner(AppLocalizations l10n, DateTime savedAt) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.historyOfflineCached(_formatTime(context, l10n, savedAt)),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.payment,
    required this.fiatCurrency,
    required this.fiatRate,
    required this.histRate,
  });

  final Payment payment;
  final String fiatCurrency;
  final double? fiatRate;

  /// BTC price at the transaction's date; the row's fiat uses this (falling
  /// back to the current [fiatRate] while it loads or if the fetch failed).
  final double? histRate;

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
    // Value at the transaction's date; current rate only as a fallback.
    final rate = histRate ?? fiatRate;
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
        histRate,
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
  double? histRate,
) {
  final ml = MaterialLocalizations.of(context);
  final use24h = MediaQuery.of(context).alwaysUse24HourFormat;
  final dateLine = ml.formatFullDate(p.time);
  final timeLine = ml.formatTimeOfDay(
    TimeOfDay.fromDateTime(p.time),
    alwaysUse24HourFormat: use24h,
  );
  final absSats = p.amountSats.abs();
  final valueNow = fiatRate == null
      ? null
      : formatFiatApprox((absSats / 100000000) * fiatRate, fiatCurrency);
  final valueThen = histRate == null
      ? null
      : formatFiatApprox((absSats / 100000000) * histRate, fiatCurrency);
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
              '${formatThousands(absSats)} ${l10n.homeSatsUnit}',
            ),
            if (valueNow != null)
              _detailRow(l10n.historyValueNow, valueNow),
            if (valueThen != null)
              _detailRow(l10n.historyValueThen, valueThen),
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
