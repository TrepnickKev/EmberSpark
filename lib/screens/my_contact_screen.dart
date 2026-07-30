import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../services/friendly_error.dart';
import '../services/lnbits_service.dart';
import '../services/my_contact_service.dart';
import '../services/nfc_service.dart';
import '../services/nfc_coordinator.dart';
import '../widgets/stacked_action_button.dart';
import 'contacts_screen.dart' show contactAvatar;
import 'qr_scan_screen.dart';

/// Stores and presents the user's *own* static Lightning destinations
/// (Lightning address, LNURL-pay link, BOLT12 offer) for sharing with
/// others. Three sections — each with QR / Copy / Share / NFC and an
/// add/edit/remove dialog. The LNURL-pay and BOLT12 sections can also be
/// auto-generated via the LNbits `lnurlp` / `bolt12` extensions.
class MyContactScreen extends StatefulWidget {
  const MyContactScreen({super.key, this.initialKind});

  /// When set, the screen opens on this identity's tab (used by the home
  /// avatar tap to jump straight to the pinned default identity).
  final MyContactKind? initialKind;

  @override
  State<MyContactScreen> createState() => _MyContactScreenState();
}

class _MyContactScreenState extends State<MyContactScreen>
    with SingleTickerProviderStateMixin {
  String? _lnAddress;
  String? _lnurlp;
  String? _bolt12;
  MyContactKind? _defaultKind;
  bool _loading = true;

  // Whether the server's lnurlp / bolt12 extensions are installed. null = not
  // yet checked (or unknown because the probe couldn't reach the server);
  // true = installed; false = missing (404). Drives the persistent
  // "extension not installed" notice in the LNURL-pay / BOLT12 tabs.
  bool? _lnurlpAvailable;
  bool? _bolt12Available;

  // Per-section spinner flag while a server-side generation call is in
  // flight. Keyed by MyContactKind so we can disable the right Auto-generate
  // button without blocking the others.
  final Map<MyContactKind, bool> _generating = {
    MyContactKind.lnurlp: false,
    MyContactKind.bolt12: false,
  };

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      initialIndex: widget.initialKind?.tabIndex ?? 0,
      vsync: this,
    );
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      getMyLightningAddress(),
      getMyLnurlpLink(),
      getMyBolt12Offer(),
    ]);
    final defaultKind = await getMyDefaultContactKind();
    if (!mounted) return;
    setState(() {
      _lnAddress = results[0];
      _lnurlp = results[1];
      _bolt12 = results[2];
      _defaultKind = defaultKind;
      _loading = false;
    });
    // Detect missing extensions in the background so the screen stays instant.
    _probeExtensions();
  }

  /// Checks (without blocking the UI) whether the lnurlp / bolt12 extensions
  /// are installed, so a missing one shows a persistent notice instead of only
  /// failing when the user taps Auto-generate. Only probes a kind that has no
  /// stored value yet (otherwise the Auto-generate area isn't shown anyway).
  Future<void> _probeExtensions() async {
    final needLnurlp = _lnurlp == null;
    final needBolt12 = _bolt12 == null;
    if (!needLnurlp && !needBolt12) return;

    final LNbitsService svc;
    try {
      svc = await LNbitsService.fromStorage();
    } catch (_) {
      return; // couldn't build the client; leave both unknown
    }

    if (needLnurlp) {
      try {
        await svc.listLnurlpLinks();
        if (mounted) setState(() => _lnurlpAvailable = true);
      } on LnurlpExtensionDisabled {
        if (mounted) setState(() => _lnurlpAvailable = false);
      } catch (_) {
        // Network/other error: leave unknown so the button stays optimistic.
      }
    }
    if (needBolt12) {
      try {
        await svc.listBolt12Offers();
        if (mounted) setState(() => _bolt12Available = true);
      } on Bolt12NotSupported {
        if (mounted) setState(() => _bolt12Available = false);
      } catch (_) {
        // Leave unknown.
      }
    }
  }

  /// Installed-extension flag for [kind] (null for kinds without an extension).
  bool? _extAvailable(MyContactKind kind) => switch (kind) {
    MyContactKind.lnurlp => _lnurlpAvailable,
    MyContactKind.bolt12 => _bolt12Available,
    MyContactKind.lnAddress => null,
  };

  String? _valueOf(MyContactKind kind) => switch (kind) {
    MyContactKind.lnAddress => _lnAddress,
    MyContactKind.lnurlp => _lnurlp,
    MyContactKind.bolt12 => _bolt12,
  };

  Future<void> _setValue(MyContactKind kind, String? value) async {
    switch (kind) {
      case MyContactKind.lnAddress:
        await setMyLightningAddress(value);
      case MyContactKind.lnurlp:
        await setMyLnurlpLink(value);
      case MyContactKind.bolt12:
        await setMyBolt12Offer(value);
    }
  }

  Future<void> _edit(MyContactKind kind) async {
    final current = _valueOf(kind);
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => _EditDialog(kind: kind, initialValue: current),
    );
    if (result == null) return; // cancelled
    if (result.isEmpty) {
      // Empty sentinel from the dialog: user submitted with an empty field
      // while editing an existing value — treat as "remove".
      await _setValue(kind, null);
      await _clearDefaultIfMatches(kind);
    } else if (kind == MyContactKind.lnAddress) {
      // A Lightning Address pointing at this wallet's own server is pushed to
      // the lnurlp extension so the server actually serves it; external
      // addresses are stored locally unchanged.
      final synced = await _syncLnAddressToServer(result);
      if (synced == null) return; // server update failed; keep the old value
      await _setValue(kind, synced);
    } else {
      await _setValue(kind, result);
    }
    if (mounted) await _load();
  }

  /// When the edited Lightning Address's host matches this wallet's server,
  /// pushes the username to the lnurlp extension so the server serves that
  /// address. Returns the address to store locally, or null if a server update
  /// was attempted but failed (the caller then keeps the previous value).
  /// Addresses on a different host are returned unchanged for local storage.
  Future<String?> _syncLnAddressToServer(String address) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final clean = address.trim().replaceFirst(
          RegExp(r'^(lightning|lnurl):', caseSensitive: false),
          '',
        );
    final parts = clean.split('@');
    if (parts.length != 2) return clean;
    final username = parts[0];
    final host = parts[1].toLowerCase();
    final LNbitsService svc;
    try {
      svc = await LNbitsService.fromStorage();
    } catch (_) {
      return clean; // no client; store locally
    }
    final serverHost = Uri.parse(svc.baseUrl).host.toLowerCase();
    if (host != serverHost) return clean; // external address; local only
    try {
      await svc.setLnurlpUsername(username);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.myContactLnAddressServerUpdated)),
      );
      return '$username@$serverHost';
    } on LnurlpExtensionDisabled {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.myContactLnurlpExtensionMissing)),
      );
      return null;
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(friendlyError(l10n, e))));
      return null;
    }
  }

  /// Drops the stored default when the identity it points at is removed, so
  /// it never dangles at an empty value (and the star UI stays accurate).
  Future<void> _clearDefaultIfMatches(MyContactKind kind) async {
    if (await getMyDefaultContactKind() == kind) {
      await setMyDefaultContactKind(null);
    }
  }

  Future<void> _toggleDefault(MyContactKind kind) async {
    // Tapping the active default clears it (back to priority order);
    // otherwise this kind becomes the single default.
    await setMyDefaultContactKind(_defaultKind == kind ? null : kind);
    if (mounted) await _load();
  }

  Future<void> _remove(MyContactKind kind) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.myContactRemoveConfirm),
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
    await _setValue(kind, null);
    await _clearDefaultIfMatches(kind);
    if (mounted) _load();
  }

  Future<void> _generate(MyContactKind kind) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _generating[kind] = true);
    try {
      final svc = await LNbitsService.fromStorage();
      final value = kind == MyContactKind.lnurlp
          ? await svc.getOrCreateLnurlpLink()
          : await svc.getOrCreateBolt12Offer();
      await _setValue(kind, value);
      if (!mounted) return;
      await _load();
    } on LnurlpExtensionDisabled {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.myContactLnurlpExtensionMissing)),
      );
    } on Bolt12NotSupported {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.myContactBolt12ExtensionMissing)),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(friendlyError(l10n, e))));
    } finally {
      if (mounted) setState(() => _generating[kind] = false);
    }
  }

  Future<void> _copy(String value) async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.myContactCopied)));
  }

  Future<void> _share(String value) async {
    final l10n = AppLocalizations.of(context)!;
    await SharePlus.instance.share(
      ShareParams(text: value, subject: l10n.myContactShareSubject),
    );
  }

  Future<void> _writeNfc(String value) =>
      NfcCoordinator.instance.runExclusive(() => _writeNfcOnce(value));

  // Suspend the app-wide ambient reader for the whole dedicated write.
  Future<void> _writeNfcOnce(String value) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    NfcSession? session;
    try {
      session = await writeNdefUri(
        'lightning:$value',
        onSuccess: () {
          if (!mounted) return;
          Navigator.of(context, rootNavigator: true).pop();
          messenger.showSnackBar(SnackBar(content: Text(l10n.nfcWriteSuccess)));
        },
        onError: (_) {
          if (!mounted) return;
          Navigator.of(context, rootNavigator: true).pop();
          messenger.showSnackBar(SnackBar(content: Text(l10n.nfcWriteFailed)));
        },
      );
    } on NfcUnavailable {
      messenger.showSnackBar(SnackBar(content: Text(l10n.nfcUnavailable)));
      return;
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.nfcWriteFailed)));
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myContactTitle)),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.myContactAvatarPriority,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: l10n.myContactTabLnAddress),
                      Tab(text: l10n.myContactTabLnurlp),
                      Tab(text: l10n.myContactTabBolt12),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _section(
                              l10n: l10n,
                              kind: MyContactKind.lnAddress,
                              title: l10n.myContactLnAddressSection,
                              useHint: l10n.myContactLnAddressUse,
                              hint: l10n.myContactLnAddressHint,
                              addLabel: l10n.myContactAddLnAddress,
                              value: _lnAddress,
                              canAutoGenerate: false,
                            ),
                          ],
                        ),
                        ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _section(
                              l10n: l10n,
                              kind: MyContactKind.lnurlp,
                              title: l10n.myContactLnurlpSection,
                              useHint: l10n.myContactLnurlpUse,
                              hint: l10n.myContactLnurlpHint,
                              addLabel: l10n.myContactAddLnurlp,
                              value: _lnurlp,
                              canAutoGenerate: true,
                            ),
                          ],
                        ),
                        ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _section(
                              l10n: l10n,
                              kind: MyContactKind.bolt12,
                              title: l10n.myContactBolt12Section,
                              useHint: l10n.myContactBolt12Use,
                              hint: l10n.myContactBolt12Hint,
                              addLabel: l10n.myContactAddBolt12,
                              value: _bolt12,
                              canAutoGenerate: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Persistent inline "extension not installed" notice, styled like the grey
  /// info row at the top of the screen. Reuses the existing per-kind messages.
  Widget _extensionMissingNotice(AppLocalizations l10n, MyContactKind kind) {
    final message = kind == MyContactKind.bolt12
        ? l10n.myContactBolt12ExtensionMissing
        : l10n.myContactLnurlpExtensionMissing;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.extension_off, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required AppLocalizations l10n,
    required MyContactKind kind,
    required String title,
    required String useHint,
    required String hint,
    required String addLabel,
    required String? value,
    required bool canAutoGenerate,
  }) {
    final isGenerating = _generating[kind] == true;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: bitcoinOrange,
                    ),
                  ),
                ),
                if (value != null) ...[
                  IconButton(
                    tooltip: _defaultKind == kind
                        ? l10n.myContactUnsetDefault
                        : l10n.myContactSetDefault,
                    icon: Icon(
                      _defaultKind == kind ? Icons.star : Icons.star_border,
                      size: 20,
                      color: _defaultKind == kind ? bitcoinOrange : null,
                    ),
                    onPressed: isGenerating ? null : () => _toggleDefault(kind),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: isGenerating ? null : () => _edit(kind),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: isGenerating ? null : () => _remove(kind),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              useHint,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (value == null) ...[
              const SizedBox(height: 6),
              Text(
                hint,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              if (canAutoGenerate && _extAvailable(kind) == false) ...[
                // Extension not installed: surface it up front and drop the
                // Auto-generate button. Manual Add still works (paste a link).
                _extensionMissingNotice(l10n, kind),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(addLabel),
                  onPressed: () => _edit(kind),
                ),
              ] else if (canAutoGenerate)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(addLabel),
                        onPressed: isGenerating ? null : () => _edit(kind),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: isGenerating
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.bolt, size: 18),
                        label: Text(
                          isGenerating
                              ? l10n.myContactGenerating
                              : l10n.myContactAutoGenerate,
                        ),
                        onPressed: isGenerating ? null : () => _generate(kind),
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(addLabel),
                  onPressed: () => _edit(kind),
                ),
            ] else ...[
              const SizedBox(height: 12),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: QrImageView(
                    data: 'lightning:$value',
                    size: 240,
                    backgroundColor: Colors.white,
                    embeddedImage: const AssetImage('images/Logo_icon.png'),
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(48, 48),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                value,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StackedActionButton(
                    icon: Icons.copy,
                    label: l10n.commonCopy,
                    onPressed: () => _copy(value),
                  ),
                  StackedActionButton(
                    icon: Icons.ios_share,
                    label: l10n.commonShare,
                    onPressed: () => _share(value),
                  ),
                  StackedActionButton(
                    icon: Icons.nfc,
                    label: l10n.commonNfc,
                    onPressed: () => _writeNfc(value),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EditDialog extends StatefulWidget {
  const _EditDialog({required this.kind, this.initialValue});
  final MyContactKind kind;
  final String? initialValue;

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late final TextEditingController ctrl;
  String? error;

  @override
  void initState() {
    super.initState();
    ctrl = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  bool _isValid(String value) => switch (widget.kind) {
    MyContactKind.lnAddress => isMyLightningAddress(value),
    MyContactKind.lnurlp => isMyLnurlpLink(value),
    MyContactKind.bolt12 => isMyBolt12Offer(value),
  };

  String _invalidMessage(AppLocalizations l10n) => switch (widget.kind) {
    MyContactKind.lnAddress => l10n.myContactInvalidLnAddress,
    MyContactKind.lnurlp => l10n.myContactInvalidLnurlp,
    MyContactKind.bolt12 => l10n.myContactInvalidBolt12,
  };

  Future<void> _scan() async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
    if (code != null && mounted) {
      setState(() {
        ctrl.text = code.trim();
        error = null;
      });
    }
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    final value = ctrl.text.trim();
    if (value.isEmpty) {
      // Treat empty as "remove" — but only when editing an existing value.
      if (widget.initialValue != null) {
        Navigator.pop(context, '');
        return;
      }
      Navigator.pop(context, null);
      return;
    }
    if (!_isValid(value)) {
      setState(() => error = _invalidMessage(l10n));
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = switch (widget.kind) {
      MyContactKind.lnAddress => l10n.myContactLnAddressSection,
      MyContactKind.lnurlp => l10n.myContactLnurlpSection,
      MyContactKind.bolt12 => l10n.myContactBolt12Section,
    };
    final hint = switch (widget.kind) {
      MyContactKind.lnAddress => l10n.myContactLnAddressHint,
      MyContactKind.lnurlp => l10n.myContactLnurlpHint,
      MyContactKind.bolt12 => l10n.myContactBolt12Hint,
    };
    final hintText = switch (widget.kind) {
      MyContactKind.lnAddress => 'user@host.tld',
      MyContactKind.lnurlp => 'lnurl1…',
      MyContactKind.bolt12 => 'lno1…',
    };
    final isSingleLine = widget.kind == MyContactKind.lnAddress;
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
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hint,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ctrl,
                    autocorrect: false,
                    enableSuggestions: false,
                    maxLines: isSingleLine ? 1 : 4,
                    decoration: InputDecoration(
                      hintText: hintText,
                      suffixIcon: IconButton(
                        tooltip: l10n.commonScanQr,
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: _scan,
                      ),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
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
                        onPressed: () => Navigator.pop(context, null),
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
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: ctrl,
              builder: (_, value, __) => contactAvatar(value.text, size: 88),
            ),
          ),
        ],
      ),
    );
  }
}
