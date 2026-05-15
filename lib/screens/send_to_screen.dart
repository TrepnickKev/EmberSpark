import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/contact_service.dart';
import '../services/lightning_router.dart';
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

  Future<void> _scan() async {
    final l10n = AppLocalizations.of(context)!;
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => QrScanScreen(title: l10n.sendToScanTitle),
      ),
    );
    if (code == null || !mounted) return;
    await routeLightningCode(Navigator.of(context), code);
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
                      suffixIcon: IconButton(
                        tooltip: l10n.commonScanQr,
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: _scan,
                      ),
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
                              leading: contactAvatar(c.name),
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
