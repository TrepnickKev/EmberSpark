import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        error = friendlyError(e);
        busy = false;
      });
    }
  }

  Future<void> _submitAuth(LnurlAuthInfo i) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await performLnurlAuth(i);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authenticated with ${i.host}')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = friendlyError(e);
        busy = false;
      });
    }
  }

  Future<void> _submitPay(LnurlPayInfo i) async {
    final sats = int.tryParse(amountCtrl.text.trim());
    if (sats == null || sats <= 0) {
      setState(() => error = 'Enter a positive amount');
      return;
    }
    final msat = sats * 1000;
    if (msat < i.minSendableMsat || msat > i.maxSendableMsat) {
      setState(
        () => error =
            'Amount must be between ${i.minSendableMsat ~/ 1000} and ${i.maxSendableMsat ~/ 1000} sats',
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
        error = friendlyError(e);
        busy = false;
      });
    }
  }

  Future<void> _submitWithdraw(LnurlWithdrawInfo i) async {
    final sats = int.tryParse(amountCtrl.text.trim());
    if (sats == null || sats <= 0) {
      setState(() => error = 'Enter a positive amount');
      return;
    }
    final msat = sats * 1000;
    if (msat < i.minWithdrawableMsat || msat > i.maxWithdrawableMsat) {
      setState(
        () => error =
            'Amount must be between ${i.minWithdrawableMsat ~/ 1000} and ${i.maxWithdrawableMsat ~/ 1000} sats',
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
        memo: i.description.isEmpty ? 'LNURL-withdraw' : i.description,
      );
      await submitWithdrawInvoice(i, bolt11);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Withdrawing $sats sats…')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = friendlyError(e);
        busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final i = info;
    final title = switch (i) {
      LnurlWithdrawInfo() => 'Receive (LNURL)',
      LnurlPayInfo() => 'Send (LNURL)',
      LnurlAuthInfo() => 'Authenticate',
      null => 'LNURL',
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: busy && i == null
            ? const Center(child: CircularProgressIndicator())
            : i == null
                ? _buildError()
                : _buildForm(i),
      ),
    );
  }

  Widget _buildError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          error ?? 'Unknown error',
          style: const TextStyle(color: Colors.redAccent),
        ),
        if (resolvedUrl != null) ...[
          const SizedBox(height: 24),
          const Text(
            'Resolved URL — paste this in a browser to see if the server '
            'will respond outside the wallet:',
            style: TextStyle(fontSize: 12, color: Colors.grey),
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
              label: const Text('Copy URL'),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: resolvedUrl!));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL copied')),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildForm(LnurlInfo i) {
    return switch (i) {
      LnurlAuthInfo() => _buildAuthForm(i),
      LnurlPayInfo() || LnurlWithdrawInfo() => _buildAmountForm(i),
    };
  }

  Widget _buildAuthForm(LnurlAuthInfo i) {
    final verb = switch (i.action) {
      'register' => 'Register at',
      'link' => 'Link account at',
      'auth' => 'Authenticate at',
      _ => 'Log in to',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$verb ${i.host}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        const Text(
          'A unique signing key for this site will be derived from your '
          'wallet seed. The site sees only your public key — your wallet '
          'and balance stay private.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
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
              : const Text('Confirm'),
        ),
        if (error != null) ...[
          const SizedBox(height: 16),
          Text(error!, style: const TextStyle(color: Colors.redAccent)),
        ],
      ],
    );
  }

  Widget _buildAmountForm(LnurlInfo i) {
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
            'Range: $minSats – $maxSats sats',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount (sats)'),
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
                : Text(i is LnurlPayInfo ? 'Get invoice & pay' : 'Withdraw'),
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
