import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:share_plus/share_plus.dart';
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
  final searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchCtrl.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final list = await getContacts();
    if (!mounted) return;
    setState(() => contacts = list);
  }

  List<Contact> _filteredContacts(List<Contact> all) {
    final q = searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.destination.toLowerCase().contains(q))
        .toList();
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

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final list = contacts ?? const [];
    if (list.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.contactsExportEmpty)),
      );
      return;
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/EmberSpark-contacts.json');
    await file.writeAsString(exportContactsJson(list));
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: l10n.contactsShareSubject,
      ),
    );
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final path = await FlutterFileDialog.pickFile(
      params: const OpenFileDialogParams(
        fileExtensionsFilter: ['json'],
        mimeTypesFilter: ['application/json'],
      ),
    );
    if (path == null) return; // cancelled
    try {
      final raw = await File(path).readAsString();
      final added = await importContacts(parseContactsJson(raw));
      await _load();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.contactsImported(added))),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.contactsImportFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final list = contacts;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.contactsTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => v == 'import' ? _import() : _export(),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'import', child: Text(l10n.contactsImport)),
              PopupMenuItem(value: 'export', child: Text(l10n.contactsExport)),
            ],
          ),
        ],
      ),
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
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: TextField(
                        controller: searchCtrl,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          labelText: l10n.contactsSearchHint,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchCtrl.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => searchCtrl.clear(),
                                ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Builder(builder: (_) {
                        final visible = _filteredContacts(list);
                        if (visible.isEmpty) {
                          return Center(
                            child: Text(
                              l10n.contactsNoMatches,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: visible.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (_, vi) {
                            final c = visible[vi];
                            final i = list.indexOf(c);
                            return ListTile(
                              onTap: () => _edit(i, c),
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
                        );
                      }),
                    ),
                  ],
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
Widget contactAvatar(String destination, {double size = 40}) {
  final seed = normalizeDestination(destination);
  if (seed.isEmpty) {
    return SizedBox(
      width: size,
      height: size,
      child: CircleAvatar(
        backgroundColor: Colors.grey.shade800,
        child: Icon(
          Icons.person_outline,
          color: Colors.grey.shade400,
          size: size * 0.6,
        ),
      ),
    );
  }
  return SizedBox(
    width: size,
    height: size,
    child: RandomAvatar(
      seed,
      height: size,
      width: size,
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
    destCtrl.addListener(() => setState(() {}));
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
    return Dialog(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      widget.initial == null
                          ? l10n.contactsNew
                          : l10n.contactsEdit,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.commonCancel),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _save,
                        child: Text(l10n.commonSave),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -44,
            child: contactAvatar(destCtrl.text, size: 88),
          ),
        ],
      ),
    );
  }
}
