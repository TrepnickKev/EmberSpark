import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/boltcards_service.dart';
import '../services/friendly_error.dart';
import '../services/lnurl.dart';
import '../services/nfc_service.dart';
import '../services/ntag424.dart';
import '../widgets/stacked_action_button.dart' show bitcoinOrange;

/// Add, program, verify, and wipe Bolt Cards against the connected LNbits
/// server's `boltcards` extension. Programming and wiping write directly to the
/// physical NTAG424 chip over NFC (see [Ntag424]); no external app is needed.
class BoltCardScreen extends StatefulWidget {
  const BoltCardScreen({super.key});

  @override
  State<BoltCardScreen> createState() => _BoltCardScreenState();
}

class _BoltCardScreenState extends State<BoltCardScreen> {
  BoltcardsService? _service;
  List<BoltCard> _cards = [];
  bool _loading = true;
  bool _extensionMissing = false;
  String? _error;

  // True while the "hold your card" dialog is on screen, so NFC callbacks only
  // dismiss it (and never accidentally pop the screen itself).
  bool _nfcDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final svc = _service ??= await BoltcardsService.fromStorage();
      final cards = await svc.listCards();
      if (!mounted) return;
      setState(() {
        _cards = cards;
        _extensionMissing = false;
        _loading = false;
      });
    } on BoltcardsExtensionDisabled {
      if (!mounted) return;
      setState(() {
        _extensionMissing = true;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = friendlyError(AppLocalizations.of(context)!, e);
        _loading = false;
      });
    }
  }

  // ---- NFC dialog plumbing -------------------------------------------------

  Future<void> _showHoldDialog(String message) async {
    final l10n = AppLocalizations.of(context)!;
    _nfcDialogOpen = true;
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
            Expanded(child: Text(message)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(),
            child: Text(l10n.commonCancel),
          ),
        ],
      ),
    );
    _nfcDialogOpen = false;
  }

  void _closeDialog() {
    if (_nfcDialogOpen && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      _nfcDialogOpen = false;
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Shows a failure with the underlying technical detail (the failing card
  /// command + status word) as selectable text, so issues can be diagnosed and
  /// reported rather than hidden behind a generic message.
  Future<void> _showErrorDetail(String title, Object err) {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SelectableText(
          err.toString(),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }

  // ---- Card operations -----------------------------------------------------

  Future<void> _addCard() async {
    final l10n = AppLocalizations.of(context)!;
    final svc = _service;
    if (svc == null) return;
    final form = await _showCardForm(l10n);
    if (form == null) return;

    // Read the chip's real UID first so the server record stores it. LNbits
    // rejects any scan whose decrypted UID doesn't match the stored one, so a
    // placeholder UID would make every tap fail with "Card UID mis-match".
    final uidHex = await _readUid();
    if (uidHex == null) return;

    BoltCard card;
    try {
      card = await svc.createCard(
        name: form.name,
        uid: uidHex,
        txLimitSats: form.txLimit,
        dailyLimitSats: form.dailyLimit,
      );
    } on BoltcardsExtensionDisabled {
      _snack(l10n.boltCardExtensionMissing);
      return;
    } catch (e) {
      _snack(friendlyError(l10n, e));
      return;
    }
    await _load();
    await _program(card);
  }

  /// Taps the card only to read its UID (no authentication), returned as
  /// uppercase hex. Used before creating the server record.
  Future<String?> _readUid() async {
    final l10n = AppLocalizations.of(context)!;
    Uint8List? uid;
    Object? err;
    NfcSession? session;
    try {
      session = await runIsoDepSession(
        action: (_) async {},
        onComplete: (u) {
          uid = u;
          _closeDialog();
        },
        onError: (e) {
          err = e;
          _closeDialog();
        },
      );
    } on NfcUnavailable {
      _snack(l10n.nfcUnavailable);
      return null;
    } catch (e) {
      _snack(friendlyError(l10n, e));
      return null;
    }
    if (!mounted) {
      await session.stop();
      return null;
    }
    if (uid == null && err == null) {
      await _showHoldDialog(l10n.boltCardHoldToVerify);
    }
    await session.stop();
    return uid != null ? _hex(uid!) : null;
  }

  Future<void> _program(BoltCard card) async {
    final l10n = AppLocalizations.of(context)!;
    final svc = _service;
    if (svc == null) return;

    final lnurlw = _lnurlwTemplate(svc, card.externalId);
    final keys = BoltCardKeys.fromHex(card.k0, card.k1, card.k2);

    Object? err;
    Uint8List? uid;
    NfcSession? session;
    try {
      session = await runIsoDepSession(
        action: (iso) => Ntag424(iso.transceive)
            .programBoltcard(lnurlwTemplate: lnurlw, keys: keys),
        onComplete: (u) {
          uid = u;
          _closeDialog();
        },
        onError: (e) {
          err = e;
          _closeDialog();
        },
      );
    } on NfcUnavailable {
      _snack(l10n.nfcUnavailable);
      return;
    } catch (e) {
      _snack(friendlyError(l10n, e));
      return;
    }
    if (!mounted) {
      await session.stop();
      return;
    }
    if (uid == null && err == null) {
      await _showHoldDialog(l10n.boltCardHoldToProgram);
    }
    await session.stop();

    if (err != null) {
      if (err is CardNotBlank) {
        _snack(l10n.boltCardNotBlank);
      } else {
        await _showErrorDetail(l10n.boltCardProgramFailed, err!);
      }
      return;
    }
    if (uid == null) return; // cancelled

    try {
      final uidHex = _hex(uid!);
      if (uidHex.toUpperCase() != card.uid.toUpperCase()) {
        await svc.updateCard(card, uid: uidHex);
      }
      _snack(l10n.boltCardProgrammed);
    } catch (e) {
      _snack(friendlyError(l10n, e));
    }
    await _load();
  }

  Future<void> _verify(BoltCard card) async {
    final l10n = AppLocalizations.of(context)!;
    final svc = _service;
    if (svc == null) return;

    String? uri;
    Object? err;
    NfcSession? session;
    try {
      session = await readNdefText(
        onRead: (s) {
          uri = s;
          _closeDialog();
        },
        onError: (e) {
          err = e;
          _closeDialog();
        },
      );
    } on NfcUnavailable {
      _snack(l10n.nfcUnavailable);
      return;
    } catch (e) {
      _snack(friendlyError(l10n, e));
      return;
    }
    if (!mounted) {
      await session.stop();
      return;
    }
    if (uri == null && err == null) {
      await _showHoldDialog(l10n.boltCardHoldToVerify);
    }
    await session.stop();

    if (uri == null) {
      if (err is NfcTagNotNdef) {
        _snack(l10n.boltCardVerifyNotProgrammed);
      } else if (err != null) {
        _snack(l10n.boltCardVerifyFailed);
      }
      return;
    }

    try {
      final decoded = decodeLnurl(uri!);
      final host = Uri.parse(decoded).host.toLowerCase();
      final myHost = Uri.parse(svc.baseUrl).host.toLowerCase();
      if (host != myHost) {
        _snack(l10n.boltCardVerifyWrongServer);
        return;
      }
      // Resolving the withdraw request confirms the card is live on the server.
      await fetchLnurl(decoded);
      _snack(l10n.boltCardVerified);
    } catch (e) {
      // Show the server's actual reason (e.g. "LNURL error: Card UID mis-match")
      // rather than a generic failure.
      await _showErrorDetail(l10n.boltCardVerifyFailed, e);
    }
    await _load();
  }

  Future<void> _wipe(BoltCard card) async {
    final l10n = AppLocalizations.of(context)!;
    final svc = _service;
    if (svc == null) return;
    final ok = await _confirm(l10n, l10n.boltCardWipeConfirm, l10n.boltCardWipe);
    if (ok != true) return;

    final keys = BoltCardKeys.fromHex(card.k0, card.k1, card.k2);
    Object? err;
    bool done = false;
    NfcSession? session;
    try {
      session = await runIsoDepSession(
        action: (iso) => Ntag424(iso.transceive).wipe(keys),
        onComplete: (_) {
          done = true;
          _closeDialog();
        },
        onError: (e) {
          err = e;
          _closeDialog();
        },
      );
    } on NfcUnavailable {
      _snack(l10n.nfcUnavailable);
      return;
    } catch (e) {
      _snack(friendlyError(l10n, e));
      return;
    }
    if (!mounted) {
      await session.stop();
      return;
    }
    if (!done && err == null) {
      await _showHoldDialog(l10n.boltCardHoldToWipe);
    }
    await session.stop();

    if (err != null) {
      await _showErrorDetail(l10n.boltCardWipeFailed, err!);
      return;
    }
    if (done) _snack(l10n.boltCardWiped);
  }

  Future<void> _toggleEnabled(BoltCard card) async {
    final l10n = AppLocalizations.of(context)!;
    final svc = _service;
    if (svc == null) return;
    try {
      await svc.setEnabled(card.id, !card.enabled);
      await _load();
    } catch (e) {
      _snack(friendlyError(l10n, e));
    }
  }

  Future<void> _edit(BoltCard card) async {
    final l10n = AppLocalizations.of(context)!;
    final svc = _service;
    if (svc == null) return;
    final form = await _showCardForm(l10n, existing: card);
    if (form == null) return;
    try {
      await svc.updateCard(
        card,
        name: form.name,
        txLimitSats: form.txLimit,
        dailyLimitSats: form.dailyLimit,
      );
      await _load();
    } catch (e) {
      _snack(friendlyError(l10n, e));
    }
  }

  Future<void> _delete(BoltCard card) async {
    final l10n = AppLocalizations.of(context)!;
    final svc = _service;
    if (svc == null) return;
    final ok =
        await _confirm(l10n, l10n.boltCardDeleteConfirm, l10n.boltCardDelete);
    if (ok != true) return;
    try {
      await svc.deleteCard(card.id);
      await _load();
    } catch (e) {
      _snack(friendlyError(l10n, e));
    }
  }

  // ---- helpers -------------------------------------------------------------

  String _lnurlwTemplate(BoltcardsService svc, String externalId) {
    final base = svc.scanBaseUrl(externalId); // https://host/.../scan/extId
    final hostPath = base.replaceFirst(RegExp(r'^https?://'), '');
    return 'lnurlw://$hostPath?p=${'0' * 32}&c=${'0' * 16}';
  }

  static String _hex(Uint8List b) =>
      b.map((x) => x.toRadixString(16).padLeft(2, '0')).join().toUpperCase();

  Future<bool?> _confirm(AppLocalizations l10n, String message, String action) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
  }

  Future<_CardForm?> _showCardForm(
    AppLocalizations l10n, {
    BoltCard? existing,
  }) {
    final nameCtl = TextEditingController(text: existing?.name ?? '');
    final txCtl = TextEditingController(
        text: (existing?.txLimitSats ?? 100000).toString());
    final dailyCtl = TextEditingController(
        text: (existing?.dailyLimitSats ?? 500000).toString());

    return showDialog<_CardForm>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? l10n.boltCardAdd : l10n.boltCardEdit),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtl,
              decoration: InputDecoration(labelText: l10n.boltCardName),
            ),
            TextField(
              controller: txCtl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.boltCardTxLimit),
            ),
            TextField(
              controller: dailyCtl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.boltCardDailyLimit),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              final name = nameCtl.text.trim();
              final tx = int.tryParse(txCtl.text.trim()) ?? 0;
              final daily = int.tryParse(dailyCtl.text.trim()) ?? 0;
              if (name.isEmpty) return;
              Navigator.pop(
                context,
                _CardForm(name: name, txLimit: tx, dailyLimit: daily),
              );
            },
            child: Text(existing == null ? l10n.boltCardCreate : l10n.boltCardSave),
          ),
        ],
      ),
    );
  }

  // ---- UI ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.boltCardTitle)),
      floatingActionButton: (_extensionMissing || _loading)
          ? null
          : FloatingActionButton.extended(
              onPressed: _addCard,
              backgroundColor: bitcoinOrange,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text(l10n.boltCardAdd),
            ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_extensionMissing) {
      return _centeredNotice(Icons.extension_off, l10n.boltCardExtensionMissing);
    }
    if (_error != null) {
      return _centeredNotice(Icons.error_outline, _error!);
    }
    if (_cards.isEmpty) {
      return _centeredNotice(Icons.credit_card, l10n.boltCardNone);
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: _cards.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) => _cardTile(l10n, _cards[i]),
      ),
    );
  }

  Widget _centeredNotice(IconData icon, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _cardTile(AppLocalizations l10n, BoltCard card) {
    return ListTile(
      onTap: () => _edit(card),
      leading: Icon(
        Icons.credit_card,
        color: card.enabled ? null : Theme.of(context).disabledColor,
      ),
      title: Text(card.name.isEmpty ? card.externalId : card.name),
      subtitle: Text(
        '${card.enabled ? l10n.boltCardEnabled : l10n.boltCardDisabled}'
        ' · ${l10n.boltCardCounter(card.counter)}\n'
        '${l10n.boltCardLimits(card.txLimitSats, card.dailyLimitSats)}',
      ),
      isThreeLine: true,
      trailing: PopupMenuButton<String>(
        onSelected: (v) {
          switch (v) {
            case 'program':
              _program(card);
            case 'verify':
              _verify(card);
            case 'toggle':
              _toggleEnabled(card);
            case 'edit':
              _edit(card);
            case 'wipe':
              _wipe(card);
            case 'delete':
              _delete(card);
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'program', child: Text(l10n.boltCardProgram)),
          PopupMenuItem(value: 'verify', child: Text(l10n.boltCardVerify)),
          PopupMenuItem(
            value: 'toggle',
            child: Text(
                card.enabled ? l10n.boltCardDisable : l10n.boltCardEnable),
          ),
          PopupMenuItem(value: 'edit', child: Text(l10n.boltCardEdit)),
          PopupMenuItem(value: 'wipe', child: Text(l10n.boltCardWipe)),
          PopupMenuItem(value: 'delete', child: Text(l10n.boltCardDelete)),
        ],
      ),
    );
  }
}

class _CardForm {
  final String name;
  final int txLimit;
  final int dailyLimit;
  const _CardForm({
    required this.name,
    required this.txLimit,
    required this.dailyLimit,
  });
}
