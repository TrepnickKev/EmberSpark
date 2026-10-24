import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../services/avatar_seed.dart';
import '../services/bolt11.dart';
import '../services/contact_service.dart' show Contact;
import '../services/friendly_error.dart';
import '../services/payment_feedback.dart';
import '../services/wallet_backend.dart';
import '../services/nfc_coordinator.dart';
import '../services/qr_image_decoder.dart';
import '../services/price_service.dart';
import '../widgets/payment_route_header.dart';
import '../widgets/stacked_action_button.dart';
import 'bolt12_action_screen.dart';
import 'bolt_card_charge_prompt.dart';
import 'lnurl_action_screen.dart';
import 'qr_scan_screen.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key, this.initialInvoice, this.fromContact});

  final String? initialInvoice;
  final Contact? fromContact;

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final bolt11Ctrl = TextEditingController();
  String? error;
  String? success;
  bool busy = false;
  Bolt11Decoded? decoded;
  ({String seed, String name})? senderInfo;

  // A tapped Bolt Card can only be charged, not paid to: inform, then charge.
  late final NfcTapHandler _nfcHandler;

  @override
  void initState() {
    super.initState();
    bolt11Ctrl.addListener(_onChanged);
    _nfcHandler = (tag) => promptBoltCardChargeOnly(context, tag);
    NfcCoordinator.instance.pushHandler(_nfcHandler);
    if (widget.initialInvoice != null) {
      bolt11Ctrl.text = widget.initialInvoice!;
    } else {
      _onChanged();
    }
    if (widget.fromContact != null) {
      _loadSenderInfo();
    }
  }

  Future<void> _loadSenderInfo() async {
    final info = await getOwnAvatarInfo();
    if (mounted && info.seed.isNotEmpty) {
      setState(() => senderInfo = info);
    }
  }

  @override
  void dispose() {
    NfcCoordinator.instance.removeHandler(_nfcHandler);
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

  /// Decides what to do with a scanned/pasted/tapped Lightning code.
  /// BOLT11 → fill the field in place. LNURL / Lightning address → replace
  /// the current Send screen with [LnurlActionScreen]. Anything else → just
  /// dump it in the field and let the user retry.
  Future<void> _handleIncomingCode(String code) async {
    final clean = code.trim().replaceFirst(
      RegExp(r'^(lightning|lnurl):', caseSensitive: false),
      '',
    );
    if (clean.isEmpty) return;
    final lower = clean.toLowerCase();
    if (lower.startsWith('lnbc')) {
      bolt11Ctrl.text = clean;
      return;
    }
    if (lower.startsWith('lno1') || lower.startsWith('lni1')) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Bolt12ActionScreen(code: clean)),
      );
      return;
    }
    if (lower.startsWith('lnurl') ||
        (clean.contains('@') && clean.contains('.'))) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LnurlActionScreen(code: clean)),
      );
      return;
    }
    bolt11Ctrl.text = clean;
  }

  Future<void> _paste() async {
    final l10n = AppLocalizations.of(context)!;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.clipboardEmpty)));
      return;
    }
    await _handleIncomingCode(text);
  }

  // The app-wide ambient reader already captures NFC taps (and shows the
  // Bolt Card charge-only prompt via the registered handler), so this button
  // is just a hint to hold the tag near the phone.
  void _readNfc() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.nfcHoldTag)));
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final code = await decodeQrFromImage(picked.path);
    if (!mounted) return;
    if (code == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.imageNoQr)));
      return;
    }
    await _handleIncomingCode(code);
  }

  Future<void> _scanQr() async {
    final l10n = AppLocalizations.of(context)!;
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => QrScanScreen(title: l10n.commonScanQr)),
    );
    if (code == null || code.isEmpty) return;
    if (!mounted) return;
    await _handleIncomingCode(code);
  }

  Future<void> _pay() async {
    final l10n = AppLocalizations.of(context)!;
    final bolt11 = bolt11Ctrl.text.trim();
    if (bolt11.isEmpty) {
      setState(() => error = l10n.sendPasteFirst);
      return;
    }
    setState(() {
      busy = true;
      error = null;
      success = null;
    });
    try {
      final WalletBackend svc = await loadWalletBackend();
      await svc.payInvoice(bolt11);
      if (!mounted) return;
      signalPaymentSuccess();
      Navigator.popUntil(context, (r) => r.isFirst);
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() => error = friendlyError(AppLocalizations.of(context)!, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sendTitle)),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.fromContact != null && senderInfo != null)
                  PaymentRouteHeader(
                    senderSeed: senderInfo!.seed,
                    senderName: senderInfo!.name,
                    recipientSeed: normalizeDestination(
                      widget.fromContact!.destination,
                    ),
                    recipientName: widget.fromContact!.name,
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StackedActionButton(
                      icon: Icons.content_paste,
                      label: l10n.commonPaste,
                      onPressed: _paste,
                    ),
                    StackedActionButton(
                      icon: Icons.nfc,
                      label: l10n.commonNfc,
                      onPressed: _readNfc,
                    ),
                    StackedActionButton(
                      icon: Icons.image_outlined,
                      label: l10n.commonImage,
                      onPressed: _pickImage,
                    ),
                    StackedActionButton(
                      icon: Icons.qr_code_scanner,
                      label: l10n.commonScan,
                      onPressed: _scanQr,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bolt11Ctrl,
                  maxLines: 4,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l10n.sendBolt11Label,
                    border: const OutlineInputBorder(),
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
      ),
    );
  }
}

class _DecodedCard extends StatelessWidget {
  const _DecodedCard({required this.decoded});

  final Bolt11Decoded decoded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final amountText = decoded.amountSats == 0
        ? l10n.sendAnyAmount
        : l10n.sendAmountWithSats(formatThousands(decoded.amountSats));
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              amountText,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
