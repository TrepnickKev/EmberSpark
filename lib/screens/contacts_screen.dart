import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';
import '../l10n/app_localizations.dart';
import '../services/avatar_seed.dart';
import '../services/contact_service.dart';
import '../services/lightning_router.dart';
import '../widgets/stacked_action_button.dart' show bitcoinOrange;
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

  Future<void> _edit(int index, Contact c) async {
    final result = await showDialog<Contact>(
      context: context,
      builder: (_) => _ContactFormDialog(initial: c),
    );
    if (result == null) return;
    await updateContact(index, result);
    await _load();
  }

  Future<void> _confirmDelete(int index, String name) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.contactsDeleteTitle(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonDelete),
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
    final l10n = AppLocalizations.of(context)!;
    final list = contacts;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contactsTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        backgroundColor: bitcoinOrange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: list == null
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
              ? Center(
                  child: Text(
                    l10n.contactsEmpty,
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: l10n.commonEdit,
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _edit(i, c),
                          ),
                          IconButton(
                            tooltip: l10n.commonDelete,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _confirmDelete(i, c.name),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

/// Small outlined badge showing the destination type (BOLT12 / LNURL) so
/// contacts list rows hint at how a payment will resolve. Returns an empty
/// widget for BOLT11 / unknown destinations (no badge needed).
Widget contactTypeBadge(String destination) {
  final cleaned = destination
      .toLowerCase()
      .replaceFirst(RegExp(r'^(lightning|lnurl):', caseSensitive: false), '');
  String? label;
  if (cleaned.startsWith('lno1') || cleaned.startsWith('lni1')) {
    label = 'BOLT12';
  } else if (cleaned.startsWith('lnurl') ||
      (cleaned.contains('@') && cleaned.contains('.'))) {
    label = 'LNURL';
  }
  if (label == null) return const SizedBox.shrink();
  return Container(
    margin: const EdgeInsets.only(left: 8),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      border: Border.all(color: bitcoinOrange, width: 1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        color: bitcoinOrange,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

/// Deterministic avatar seeded from the contact's normalised Lightning
/// destination. Matches the contact's own Home bubble when the same
/// destination is their primary identity, giving "same person, same
/// avatar everywhere" recognisability.
Widget contactAvatar(String destination) {
  final seed = normalizeDestination(destination);
  return SizedBox(
    width: 40,
    height: 40,
    child: RandomAvatar(
      seed.isEmpty ? '?' : seed,
      height: 40,
      width: 40,
    ),
  );
}

class _ContactFormDialog extends StatefulWidget {
  const _ContactFormDialog({this.initial});

  /// When non-null, the dialog opens pre-filled with this contact's
  /// values and the title swaps to "Edit contact".
  final Contact? initial;

  @override
  State<_ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends State<_ContactFormDialog> {
  late final TextEditingController nameCtrl;
  late final TextEditingController destCtrl;
  String? error;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
    destCtrl = TextEditingController(text: widget.initial?.destination ?? '');
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    destCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    final name = nameCtrl.text.trim();
    final dest = destCtrl.text.trim();
    if (name.isEmpty || dest.isEmpty) {
      setState(() => error = l10n.contactsRequired);
      return;
    }
    if (!isLikelyLightningDestination(dest)) {
      setState(() => error = l10n.contactsInvalidDestination);
      return;
    }
    Navigator.pop(context, Contact(name: name, destination: dest));
  }

  Future<void> _scan() async {
    final l10n = AppLocalizations.of(context)!;
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => QrScanScreen(title: l10n.contactsScanTitle),
      ),
    );
    if (code != null && mounted) {
      destCtrl.text = code.trim();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.initial == null ? l10n.contactsNew : l10n.contactsEdit),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: l10n.contactsName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: destCtrl,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: l10n.contactsDestinationLabel,
                suffixIcon: IconButton(
                  tooltip: l10n.commonScanQr,
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
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
