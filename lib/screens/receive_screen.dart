import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../l10n/app_localizations.dart';
import '../services/friendly_error.dart';
import '../services/lnbits_service.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final amountCtrl = TextEditingController();
  final memoCtrl = TextEditingController();
  String? invoice;
  String? error;
  bool busy = false;

  @override
  void dispose() {
    amountCtrl.dispose();
    memoCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = int.tryParse(amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => error = l10n.receiveAmountError);
      return;
    }
    setState(() {
      busy = true;
      error = null;
      invoice = null;
    });
    try {
      final svc = await LNbitsService.fromStorage();
      final bolt11 = await svc.createInvoice(
        amountSats: amount,
        memo: memoCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => invoice = bolt11);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = friendlyError(AppLocalizations.of(context)!, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _copy() async {
    if (invoice == null) return;
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: invoice!));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.receiveInvoiceCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.receiveTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.receiveAmount),
              ),
              TextField(
                controller: memoCtrl,
                decoration: InputDecoration(labelText: l10n.receiveMemo),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: busy ? null : _create,
                child: busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.receiveCreateInvoice),
              ),
              if (error != null) ...[
                const SizedBox(height: 16),
                Text(error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              if (invoice != null) ...[
                const SizedBox(height: 24),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: QrImageView(
                    data: invoice!,
                    size: 240,
                    backgroundColor: Colors.white,
                    embeddedImage: const AssetImage('images/Logo_icon.png'),
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(48, 48),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _copy,
                  icon: const Icon(Icons.copy),
                  label: Text(l10n.commonCopy),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  invoice!,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
