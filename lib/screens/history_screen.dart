import 'package:flutter/material.dart';
import '../services/friendly_error.dart';
import '../services/lnbits_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Payment>? payments;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final svc = await LNbitsService.fromStorage();
      final list = await svc.listPayments();
      if (!mounted) return;
      setState(() => payments = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = friendlyError(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loading ? null : _load,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
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
    final list = payments ?? const [];
    if (list.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          Center(
            child: Text(
              'No transactions yet',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => _PaymentTile(payment: list[i]),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    final incoming = payment.incoming;
    final color = payment.pending
        ? Colors.amber
        : incoming
            ? Colors.greenAccent
            : Colors.redAccent;
    final sign = incoming ? '+' : '−';
    final abs = payment.amountSats.abs();
    final feePart = !incoming && payment.feeSats > 0
        ? ' (fee ${payment.feeSats})'
        : '';
    return ListTile(
      leading: Icon(
        incoming ? Icons.arrow_downward : Icons.arrow_upward,
        color: color,
      ),
      title: Text(
        payment.memo.isEmpty ? 'Lightning payment' : payment.memo,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${_formatTime(payment.time)}'
        '${payment.pending ? ' · pending' : ''}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        '$sign$abs sats$feePart',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

String _formatTime(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  final y = t.year.toString().padLeft(4, '0');
  final m = t.month.toString().padLeft(2, '0');
  final d = t.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
