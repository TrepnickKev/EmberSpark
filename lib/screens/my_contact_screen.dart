import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../services/friendly_error.dart';
import '../services/lnbits_service.dart';
import '../services/my_contact_service.dart';
import '../services/nfc_service.dart';
import '../widgets/stacked_action_button.dart';

/// Stores and presents the user's *own* static Lightning destinations
/// (Lightning address, LNURL-pay link, BOLT12 offer) for sharing with
/// others. Three sections — each with QR / Copy / Share / NFC and an
/// add/edit/remove dialog. The LNURL-pay and BOLT12 sections can also be
/// auto-generated via the LNbits `lnurlp` / `bolt12` extensions.
class MyContactScreen extends StatefulWidget {
  const MyContactScreen({super.key});

  @override
  State<MyContactScreen> createState() => _MyContactScreenState();
}

enum _Kind { lnAddress, lnurlp, bolt12 }

class _MyContactScreenState extends State<MyContactScreen> {
  String? _lnAddress;
  String? _lnurlp;
  String? _bolt12;
  bool _loading = true;

  // Per-section spinner flag while a server-side generation call is in
  // flight. Keyed by _Kind so we can disable the right Auto-generate
  // button without blocking the others.
  final Map<_Kind, bool> _generating = {
    _Kind.lnurlp: false,
    _Kind.bolt12: false,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      getMyLightningAddress(),
      getMyLnurlpLink(),
      getMyBolt12Offer(),
    ]);
    if (!mounted) return;
    setState(() {
      _lnAddress = results[0];
      _lnurlp = results[1];
      _bolt12 = results[2];
      _loading = false;
    });
  }

  String? _valueOf(_Kind kind) => switch (kind) {
        _Kind.lnAddress => _lnAddress,
        _Kind.lnurlp => _lnurlp,
        _Kind.bolt12 => _bolt12,
      };

  Future<void> _setValue(_Kind kind, String? value) async {
    switch (kind) {
      case _Kind.lnAddress:
        await setMyLightningAddress(value);
      case _Kind.lnurlp:
        await setMyLnurlpLink(value);
      case _Kind.bolt12:
        await setMyBolt12Offer(value);
    }
  }

  Future<void> _edit(_Kind kind) async {
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
    } else {
      await _setValue(kind, result);
    }
    if (mounted) await _load();
  }

  Future<void> _remove(_Kind kind) async {
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
    if (mounted) _load();
  }

  Future<void> _generate(_Kind kind) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _generating[kind] = true);
    try {
      final svc = await LNbitsService.fromStorage();
      final value = kind == _Kind.lnurlp
          ? await svc.createLnurlpLink()
          : await svc.createBolt12Offer();
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
      messenger.showSnackBar(
        SnackBar(content: Text(friendlyError(l10n, e))),
      );
    } finally {
      if (mounted) setState(() => _generating[kind] = false);
    }
  }

  Future<void> _copy(String value) async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.myContactCopied)),
    );
  }

  Future<void> _share(String value) async {
    final l10n = AppLocalizations.of(context)!;
    await SharePlus.instance.share(
      ShareParams(text: value, subject: l10n.myContactShareSubject),
    );
  }

  Future<void> _writeNfc(String value) async {
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
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
                _section(
                  l10n: l10n,
                  kind: _Kind.lnAddress,
                  title: l10n.myContactLnAddressSection,
                  hint: l10n.myContactLnAddressHint,
                  addLabel: l10n.myContactAddLnAddress,
                  value: _lnAddress,
                  canAutoGenerate: false,
                ),
                const SizedBox(height: 16),
                _section(
                  l10n: l10n,
                  kind: _Kind.lnurlp,
                  title: l10n.myContactLnurlpSection,
                  hint: l10n.myContactLnurlpHint,
                  addLabel: l10n.myContactAddLnurlp,
                  value: _lnurlp,
                  canAutoGenerate: true,
                ),
                const SizedBox(height: 16),
                _section(
                  l10n: l10n,
                  kind: _Kind.bolt12,
                  title: l10n.myContactBolt12Section,
                  hint: l10n.myContactBolt12Hint,
                  addLabel: l10n.myContactAddBolt12,
                  value: _bolt12,
                  canAutoGenerate: true,
                ),
              ],
            ),
    );
  }

  Widget _section({
    required AppLocalizations l10n,
    required _Kind kind,
    required String title,
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
            if (value == null) ...[
              const SizedBox(height: 6),
              Text(
                hint,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              if (canAutoGenerate)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
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
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
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
  final _Kind kind;
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
        _Kind.lnAddress => isMyLightningAddress(value),
        _Kind.lnurlp => isMyLnurlpLink(value),
        _Kind.bolt12 => isMyBolt12Offer(value),
      };

  String _invalidMessage(AppLocalizations l10n) => switch (widget.kind) {
        _Kind.lnAddress => l10n.myContactInvalidLnAddress,
        _Kind.lnurlp => l10n.myContactInvalidLnurlp,
        _Kind.bolt12 => l10n.myContactInvalidBolt12,
      };

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
      _Kind.lnAddress => l10n.myContactLnAddressSection,
      _Kind.lnurlp => l10n.myContactLnurlpSection,
      _Kind.bolt12 => l10n.myContactBolt12Section,
    };
    final hint = switch (widget.kind) {
      _Kind.lnAddress => l10n.myContactLnAddressHint,
      _Kind.lnurlp => l10n.myContactLnurlpHint,
      _Kind.bolt12 => l10n.myContactBolt12Hint,
    };
    final hintText = switch (widget.kind) {
      _Kind.lnAddress => 'user@host.tld',
      _Kind.lnurlp => 'lnurl1…',
      _Kind.bolt12 => 'lno1…',
    };
    final isSingleLine = widget.kind == _Kind.lnAddress;
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              decoration: InputDecoration(hintText: hintText),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error!, style: const TextStyle(color: Colors.redAccent)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(onPressed: _save, child: Text(l10n.commonSave)),
      ],
    );
  }
}
