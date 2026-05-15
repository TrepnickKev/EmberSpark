import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../services/friendly_error.dart';
import '../services/lnbits_service.dart';
import '../services/lnurl.dart';
import '../services/lnurl_auth.dart';
import 'send_screen.dart';

/// Resolves a scanned LNURL or Lightning address and runs the appropriate
/// pay or withdraw flow.
class LnurlActionScreen extends StatefulWidget {
  const LnurlActionScreen({super.key, required this.code});

  final String code;

  @override
  State<LnurlActionScreen> createState() => _LnurlActionScreenState();
}

class _LnurlActionScreenState extends State<LnurlActionScreen> {
  final amountCtrl = TextEditingController();
  LnurlInfo? info;
  String? error;
  String? resolvedUrl;
  bool busy = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _resolve() async {
    try {
      final url = widget.code.contains('@')
          ? lightningAddressToUrl(widget.code)
          : decodeLnurl(widget.code);
      resolvedUrl = url;

      // LNURL-auth is detected from the URL's query params (no fetch yet).
      final auth = tryParseLnurlAuth(url);
      if (auth != null) {
        if (!mounted) return;
        setState(() {
          info = auth;
          busy = false;
        });
        return;
      }

      final i = await fetchLnurl(url);
      if (!mounted) return;
      setState(() {
        info = i;
        busy = false;
        if (i is LnurlWithdrawInfo) {
          amountCtrl.text = (i.maxWithdrawableMsat ~/ 1000).toString();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = friendlyError(AppLocalizations.of(context)!, e);
        busy = false;
      });
    }
  }

  Future<void> _submitAuth(LnurlAuthInfo i) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await performLnurlAuth(i);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.lnurlAuthSuccess(i.host))),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = friendlyError(AppLocalizations.of(context)!, e);
        busy = false;
      });
    }
  }

  Future<void> _submitPay(LnurlPayInfo i) async {
    final l10n = AppLocalizations.of(context)!;
    final sats = int.tryParse(amountCtrl.text.trim());
    if (sats == null || sats <= 0) {
      setState(() => error = l10n.lnurlAmountPositive);
      return;
    }
    final msat = sats * 1000;
    if (msat < i.minSendableMsat || msat > i.maxSendableMsat) {
      setState(
        () => error = l10n.lnurlAmountOutOfRange(
          i.minSendableMsat ~/ 1000,
          i.maxSendableMsat ~/ 1000,
        ),
      );
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final bolt11 = await requestPayInvoice(i, msat);
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SendScreen(initialInvoice: bolt11)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = friendlyError(AppLocalizations.of(context)!, e);
        busy = false;
      });
    }
  }

  Future<void> _submitWithdraw(LnurlWithdrawInfo i) async {
    final l10n = AppLocalizations.of(context)!;
    final sats = int.tryParse(amountCtrl.text.trim());
    if (sats == null || sats <= 0) {
      setState(() => error = l10n.lnurlAmountPositive);
      return;
    }
    final msat = sats * 1000;
    if (msat < i.minWithdrawableMsat || msat > i.maxWithdrawableMsat) {
      setState(
        () => error = l10n.lnurlAmountOutOfRange(
          i.minWithdrawableMsat ~/ 1000,
          i.maxWithdrawableMsat ~/ 1000,
        ),
      );
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final svc = await LNbitsService.fromStorage();
      final bolt11 = await svc.createInvoice(
        amountSats: sats,
        memo: i.description.isEmpty
            ? l10n.lnurlWithdrawDefaultMemo
            : i.description,
      );
      await submitWithdrawInvoice(i, bolt11);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.lnurlWithdrawing(sats))),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = friendlyError(AppLocalizations.of(context)!, e);
        busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final i = info;
    final title = switch (i) {
      LnurlWithdrawInfo() => l10n.lnurlTitleWithdraw,
      LnurlPayInfo() => l10n.lnurlTitlePay,
      LnurlAuthInfo() => l10n.lnurlTitleAuthenticate,
      null => l10n.lnurlTitleGeneric,
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: busy && i == null
            ? const Center(child: CircularProgressIndicator())
            : i == null
                ? _buildError(l10n)
                : _buildForm(l10n, i),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          error ?? l10n.commonUnknownError,
          style: const TextStyle(color: Colors.redAccent),
        ),
        if (resolvedUrl != null) ...[
          const SizedBox(height: 24),
          Text(
            l10n.lnurlResolvedExplain,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          SelectableText(
            resolvedUrl!,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.copy),
              label: Text(l10n.lnurlCopyUrl),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: resolvedUrl!));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.lnurlUrlCopied)),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildForm(AppLocalizations l10n, LnurlInfo i) {
    return switch (i) {
      LnurlAuthInfo() => _buildAuthForm(l10n, i),
      LnurlPayInfo() || LnurlWithdrawInfo() => _buildAmountForm(l10n, i),
    };
  }

  Widget _buildAuthForm(AppLocalizations l10n, LnurlAuthInfo i) {
    final header = switch (i.action) {
      'register' => l10n.lnurlAuthRegisterAt(i.host),
      'link' => l10n.lnurlAuthLinkAt(i.host),
      'auth' => l10n.lnurlAuthAuthenticateAt(i.host),
      _ => l10n.lnurlAuthLoginAt(i.host),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          header,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.lnurlAuthExplain,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: busy ? null : () => _submitAuth(i),
          child: busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.lnurlAuthConfirm),
        ),
        if (error != null) ...[
          const SizedBox(height: 16),
          Text(error!, style: const TextStyle(color: Colors.redAccent)),
        ],
      ],
    );
  }

  Widget _buildAmountForm(AppLocalizations l10n, LnurlInfo i) {
    final desc = switch (i) {
      LnurlPayInfo(:final description) => description,
      LnurlWithdrawInfo(:final description) => description,
      LnurlAuthInfo() => '',
    };
    final (minSats, maxSats) = switch (i) {
      LnurlPayInfo(:final minSendableMsat, :final maxSendableMsat) => (
          minSendableMsat ~/ 1000,
          maxSendableMsat ~/ 1000,
        ),
      LnurlWithdrawInfo(
        :final minWithdrawableMsat,
        :final maxWithdrawableMsat,
      ) =>
        (minWithdrawableMsat ~/ 1000, maxWithdrawableMsat ~/ 1000),
      LnurlAuthInfo() => (0, 0),
    };
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (desc.isNotEmpty) ...[
            Text(desc),
            const SizedBox(height: 12),
          ],
          Text(
            l10n.lnurlAmountRange(minSats, maxSats),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(labelText: l10n.commonAmount),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: busy
                ? null
                : () => switch (i) {
                    LnurlPayInfo() => _submitPay(i),
                    LnurlWithdrawInfo() => _submitWithdraw(i),
                    LnurlAuthInfo() => _submitAuth(i),
                  },
            child: busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    i is LnurlPayInfo ? l10n.lnurlGetAndPay : l10n.lnurlWithdraw,
                  ),
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            Text(error!, style: const TextStyle(color: Colors.redAccent)),
          ],
        ],
      ),
    );
  }
}
