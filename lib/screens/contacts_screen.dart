import 'package:flutter/material.dart';
import '../services/contact_service.dart';
import 'qr_scan_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact>? contacts;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await getContacts();
    if (!mounted) return;
    setState(() => contacts = list);
  }

  Future<void> _add() async {
    final result = await showDialog<Contact>(
      context: context,
      builder: (_) => const _ContactFormDialog(),
    );
    if (result == null) return;
    await addContact(result);
    await _load();
  }

  Future<void> _confirmDelete(int index, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await deleteContact(index);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final list = contacts;
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
      body: list == null
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
              ? const Center(
                  child: Text(
                    'No contacts yet — tap + to add one',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
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
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(i, c.name),
                      ),
                    );
                  },
                ),
    );
  }
}

/// Letter-on-coloured-circle avatar derived from the contact's name.
Widget contactAvatar(String name) {
  final letter = name.isEmpty ? '?' : name.characters.first.toUpperCase();
  final hash = name.codeUnits.fold<int>(0, (h, c) => h * 31 + c);
  final hue = (hash.abs() % 360).toDouble();
  final color = HSLColor.fromAHSL(1.0, hue, 0.5, 0.4).toColor();
  return CircleAvatar(
    backgroundColor: color,
    child: Text(
      letter,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );
}

class _ContactFormDialog extends StatefulWidget {
  const _ContactFormDialog();

  @override
  State<_ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends State<_ContactFormDialog> {
  final nameCtrl = TextEditingController();
  final destCtrl = TextEditingController();
  String? error;

  @override
  void dispose() {
    nameCtrl.dispose();
    destCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = nameCtrl.text.trim();
    final dest = destCtrl.text.trim();
    if (name.isEmpty || dest.isEmpty) {
      setState(() => error = 'Name and destination are required');
      return;
    }
    Navigator.pop(context, Contact(name: name, destination: dest));
  }

  Future<void> _scan() async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScanScreen(title: 'Scan destination'),
      ),
    );
    if (code != null && mounted) {
      destCtrl.text = code.trim();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New contact'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: destCtrl,
              decoration: InputDecoration(
                labelText: 'Lightning address, LNURL, or BOLT11',
                suffixIcon: IconButton(
                  tooltip: 'Scan QR',
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scan,
                ),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(
                error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
