import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../l10n/app_localizations.dart';
import '../services/contact_service.dart';
import '../services/lightning_router.dart';
import '../services/nfc_service.dart';
import '../widgets/stacked_action_button.dart';
import 'contacts_screen.dart' show contactAvatar, contactTypeBadge;
import 'qr_scan_screen.dart';

class SendToScreen extends StatefulWidget {
  const SendToScreen({super.key});

  @override
  State<SendToScreen> createState() => _SendToScreenState();
}

class _SendToScreenState extends State<SendToScreen> {
  final inputCtrl = TextEditingController();
  List<Contact>? contacts;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final list = await getContacts();
    if (!mounted) return;
    setState(() => contacts = list);
  }

  Future<void> _continue() async {
    final code = inputCtrl.text.trim();
    if (code.isEmpty) return;
    await routeLightningCode(Navigator.of(context), code);
  }

  Future<void> _useContact(Contact c) async {
    await routeLightningCode(Navigator.of(context), c.destination);
  }

  Future<void> _handleIncomingCode(String code) async {
    final clean = code.trim();
    if (clean.isEmpty || !mounted) return;
    await routeLightningCode(Navigator.of(context), clean);
  }

  Future<void> _paste() async {
    final l10n = AppLocalizations.of(context)!;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (!mounted) return;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.clipboardEmpty)),
      );
      return;
    }
    await _handleIncomingCode(text);
  }

  Future<void> _readNfc() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    NfcSession? session;
    try {
      session = await readNdefText(
        onRead: (payload) async {
          if (!mounted) return;
          Navigator.of(context, rootNavigator: true).pop();
          await _handleIncomingCode(payload);
        },
        onError: (_) {
          if (!mounted) return;
          Navigator.of(context, rootNavigator: true).pop();
          messenger.showSnackBar(SnackBar(content: Text(l10n.nfcReadFailed)));
        },
      );
    } on NfcUnavailable {
      messenger.showSnackBar(SnackBar(content: Text(l10n.nfcUnavailable)));
      return;
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.nfcReadFailed)));
      return;
    }
    if (!mounted) {
      await session.stop();
      return;
    }
    await _showNfcDialog(session);
  }

  Future<void> _showNfcDialog(NfcSession session) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(l10n.nfcHoldTag)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: Text(l10n.commonCancel),
          ),
        ],
      ),
    );
    await session.stop();
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final controller = MobileScannerController();
    try {
      final result = await controller.analyzeImage(picked.path);
      final code = (result?.barcodes.isNotEmpty ?? false)
          ? result!.barcodes.first.rawValue
          : null;
      if (code == null || code.isEmpty) {
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(l10n.imageNoQr)));
        return;
      }
      if (!mounted) return;
      await _handleIncomingCode(code);
    } finally {
      await controller.dispose();
    }
  }

  Future<void> _scan() async {
    final l10n = AppLocalizations.of(context)!;
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => QrScanScreen(title: l10n.sendToScanTitle),
      ),
    );
    if (code == null || !mounted) return;
    await _handleIncomingCode(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final list = contacts;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sendToTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                  onPressed: _scan,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: inputCtrl,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      labelText: l10n.sendToInputLabel,
                      hintText: l10n.sendToInputHint,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _continue,
                  child: Text(l10n.commonContinue),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.sendToContacts,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const Divider(height: 16),
            Expanded(
              child: list == null
                  ? const Center(child: CircularProgressIndicator())
                  : list.isEmpty
                      ? Center(
                          child: Text(
                            l10n.sendToNoContacts,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final c = list[i];
                            return ListTile(
                              leading: contactAvatar(c.destination),
                              title: Row(
                                children: [
                                  Flexible(child: Text(c.name)),
                                  contactTypeBadge(c.destination),
                                ],
                              ),
                              subtitle: Text(
                                c.destination,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                              onTap: () => _useContact(c),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
