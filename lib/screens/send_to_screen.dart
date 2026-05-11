import 'package:flutter/material.dart';
import '../services/contact_service.dart';
import '../services/lightning_router.dart';
import 'contacts_screen.dart' show contactAvatar;
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
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScanScreen(title: 'Scan to send'),
      ),
    );
    if (code == null || !mounted) return;
    await routeLightningCode(Navigator.of(context), code);
  }

  @override
  Widget build(BuildContext context) {
    final list = contacts;
    return Scaffold(
      appBar: AppBar(title: const Text('Send to…')),
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
                    decoration: InputDecoration(
                      labelText: 'Address or payment data',
                      hintText: 'BOLT11, LNURL, or user@host',
                      suffixIcon: IconButton(
                        tooltip: 'Scan QR',
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: _scan,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _continue,
                  child: const Text('Continue'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Contacts',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const Divider(height: 16),
            Expanded(
              child: list == null
                  ? const Center(child: CircularProgressIndicator())
                  : list.isEmpty
                      ? const Center(
                          child: Text(
                            'No contacts yet',
                            style: TextStyle(color: Colors.grey),
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
                              title: Text(c.name),
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
