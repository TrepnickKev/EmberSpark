import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/friendly_error.dart';
import '../services/lnbits_service.dart';

/// Pay either a BOLT12 offer (`lno1…`) or a BOLT12 invoice (`lni1…`).
/// For offers we ask LNbits' BOLT12 community extension to fetchinvoice
/// (taking an amount + optional payer note) and then pay the returned
/// invoice via the regular payments endpoint. For invoices we try the
/// regular payments endpoint directly — CLN-backed LNbits accepts BOLT12
/// invoices in the `bolt11` field; other backends fall through with a
/// localized "not supported" message.
class Bolt12ActionScreen extends StatefulWidget {
  const Bolt12ActionScreen({super.key, required this.code});

  final String code;

  bool get isOffer => code.toLowerCase().startsWith('lno1');

  @override
  State<Bolt12ActionScreen> createState() => _Bolt12ActionScreenState();
}

class _Bolt12ActionScreenState extends State<Bolt12ActionScreen> {
  final amountCtrl = TextEditingController();
  final memoCtrl = TextEditingController();
  String? error;
  String? success;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    amountCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    memoCtrl.dispose();
    super.dispose();
  }

  bool get _amountValid {
    final n = int.tryParse(amountCtrl.text.trim());
    return n != null && n > 0;
  }

  Future<void> _pay() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      busy = true;
      error = null;
      success = null;
    });
    try {
      final svc = await LNbitsService.fromStorage();
      if (widget.isOffer) {
        final amountSats = int.parse(amountCtrl.text.trim());
        final memo = memoCtrl.text.trim();
        final invoice = await svc.fetchBolt12Invoice(
          offer: widget.code,
          amountSats: amountSats,
          memo: memo.isEmpty ? null : memo,
        );
        await svc.payInvoice(invoice);
      } else {
        // lni1… — CLN-backed LNbits accepts BOLT12 invoices in the bolt11
        // field. Other backends throw, surfaced via _classifyError.
        await svc.payInvoice(widget.code);
      }
      if (!mounted) return;
      setState(() => success = l10n.sendPaymentSent);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = _classifyError(l10n, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String _classifyError(AppLocalizations l10n, Object e) {
    if (e is Bolt12NotSupported) return l10n.bolt12NotSupported;
    final s = e.toString();
    // CLN returns 400 / 500 on unrecognized BOLT12 strings — surface the
    // friendly "not supported" message rather than the raw server text.
    if (s.contains('bolt12') ||
        s.contains('BOLT12') ||
        s.contains('unable to decode') ||
        s.contains('invalid bolt11')) {
      return l10n.bolt12NotSupported;
    }
    return friendlyError(l10n, e);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOffer = widget.isOffer;
    final canPay =
        !busy && (isOffer ? _amountValid : true) && success == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isOffer ? l10n.bolt12TitlePayOffer : l10n.bolt12TitlePayInvoice,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.bolt12RawStringLabel,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              SelectableText(
                widget.code,
                maxLines: 3,
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 24),
              if (isOffer) ...[
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l10n.bolt12AmountLabel,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: memoCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.bolt12MemoLabel,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              ElevatedButton(
                onPressed: canPay ? _pay : null,
                child: busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.sendPay),
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
