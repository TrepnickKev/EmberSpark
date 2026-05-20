import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/wallet_account_service.dart';
import '../widgets/stacked_action_button.dart' show bitcoinOrange;
import 'login_screen.dart';

/// Lists every saved wallet on the device and lets the user switch
/// between them, rename, remove, or add a new one. The active wallet is
/// marked with a check; tapping any row makes it active and pops back.
class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  List<WalletAccount> wallets = const [];
  String? currentId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    if (!loading) setState(() => loading = true);
    final w = await listWallets();
    final id = await getCurrentWalletId();
    if (!mounted) return;
    setState(() {
      wallets = w;
      currentId = id;
      loading = false;
    });
  }

  Future<void> _switchTo(WalletAccount w) async {
    await setCurrentWalletId(w.id);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _addWallet() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen(addFlow: true)),
    );
    if (!mounted) return;
    await _reload();
  }

  Future<void> _rename(WalletAccount w) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: w.label);
    final newLabel = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.walletsRenameDialogTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.walletsLabelLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    if (newLabel == null || newLabel.isEmpty || newLabel == w.label) return;
    await updateWalletLabel(w.id, newLabel);
    if (!mounted) return;
    await _reload();
  }

  Future<void> _remove(WalletAccount w) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.walletsRemove),
        content: Text(l10n.walletsRemoveConfirm),
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
    if (confirmed != true) return;
    await removeWallet(w.id);
    if (!mounted) return;
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.walletsTitle),
        actions: [
          IconButton(
            tooltip: l10n.walletsAdd,
            icon: const Icon(Icons.add),
            onPressed: _addWallet,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : wallets.isEmpty
              ? _buildEmpty(l10n)
              : _buildList(l10n),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.walletsEmpty,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: Text(l10n.walletsAdd),
            onPressed: _addWallet,
          ),
        ],
      ),
    );
  }

  Widget _buildList(AppLocalizations l10n) {
    return ListView.separated(
      itemCount: wallets.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final w = wallets[i];
        final active = w.id == currentId;
        return ListTile(
          leading: Icon(
            active ? Icons.check_circle : Icons.circle_outlined,
            color: active ? bitcoinOrange : Theme.of(context).disabledColor,
          ),
          title: Text(w.label),
          subtitle: Text(
            _hostOf(w.url),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'rename') _rename(w);
              if (v == 'remove') _remove(w);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'rename',
                child: Text(l10n.walletsRename),
              ),
              PopupMenuItem(
                value: 'remove',
                child: Text(l10n.walletsRemove),
              ),
            ],
          ),
          onTap: active ? null : () => _switchTo(w),
        );
      },
    );
  }
}

String _hostOf(String url) {
  try {
    final h = Uri.parse(url).host;
    if (h.isNotEmpty) return h;
  } catch (_) {}
  return url;
}
