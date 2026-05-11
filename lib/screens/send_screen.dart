import 'package:flutter/material.dart';
import '../services/bolt11.dart';
import '../services/friendly_error.dart';
import '../services/lnbits_service.dart';
import '../services/price_service.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key, this.initialInvoice});

  final String? initialInvoice;

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final bolt11Ctrl = TextEditingController();
  String? error;
  String? success;
  bool busy = false;
  Bolt11Decoded? decoded;

  @override
  void initState() {
    super.initState();
    bolt11Ctrl.addListener(_onChanged);
    if (widget.initialInvoice != null) {
      bolt11Ctrl.text = widget.initialInvoice!;
    } else {
      _onChanged();
    }
  }

  @override
  void dispose() {
    bolt11Ctrl.removeListener(_onChanged);
    bolt11Ctrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    final next = decodeBolt11(bolt11Ctrl.text);
    if (next?.paymentHash != decoded?.paymentHash ||
        next?.amountMsat != decoded?.amountMsat ||
        next?.description != decoded?.description) {
      setState(() => decoded = next);
    }
  }

  Future<void> _pay() async {
    final bolt11 = bolt11Ctrl.text.trim();
    if (bolt11.isEmpty) {
      setState(() => error = 'Paste an invoice first');
      return;
    }
    setState(() {
      busy = true;
      error = null;
      success = null;
    });
    try {
      final svc = await LNbitsService.fromStorage();
      await svc.payInvoice(bolt11);
      if (!mounted) return;
      setState(() => success = 'Payment sent');
    } catch (e) {
      if (!mounted) return;
      setState(() => error = friendlyError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: bolt11Ctrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'BOLT11 invoice',
                  border: OutlineInputBorder(),
                ),
              ),
              if (decoded != null) ...[
                const SizedBox(height: 16),
                _DecodedCard(decoded: decoded!),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: busy ? null : _pay,
                child: busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Pay'),
              ),
              if (error != null) ...[
                const SizedBox(height: 16),
                Text(error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              if (success != null) ...[
                const SizedBox(height: 16),
                Text(
                  success!,
                  style: const TextStyle(color: Colors.greenAccent),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DecodedCard extends StatelessWidget {
  const _DecodedCard({required this.decoded});

  final Bolt11Decoded decoded;

  @override
  Widget build(BuildContext context) {
    final amountText = decoded.amountSats == 0
        ? 'Any amount'
        : '${formatThousands(decoded.amountSats)} sats';
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              amountText,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (decoded.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                decoded.description,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
