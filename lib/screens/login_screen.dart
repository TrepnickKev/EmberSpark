import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/lnbits_service.dart';
import 'home_screen.dart';
import 'qr_scan_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final urlController = TextEditingController();
  final adminKeyController = TextEditingController();
  String? error;

  @override
  void dispose() {
    urlController.dispose();
    adminKeyController.dispose();
    super.dispose();
  }

  Future<void> _scanInto(TextEditingController target, String title) async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => QrScanScreen(title: title)),
    );
    if (code != null && mounted) {
      target.text = code.trim();
    }
  }

  Future<void> _save() async {
    final admin = adminKeyController.text.trim();
    if (admin.isEmpty) {
      setState(() => error = 'Admin key is required');
      return;
    }
    final String url;
    try {
      url = LNbitsService.normalizeBaseUrl(urlController.text);
    } on FormatException catch (e) {
      setState(() => error = e.message);
      return;
    }
    const storage = FlutterSecureStorage();
    await storage.write(key: 'url', value: url);
    await storage.write(key: 'admin_key', value: admin);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Widget _scanButton(TextEditingController target, String title) {
    return IconButton(
      tooltip: 'Scan QR',
      icon: const Icon(Icons.qr_code_scanner),
      onPressed: () => _scanInto(target, title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: urlController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: 'LNbits URL',
                  hintText: 'https://your.node',
                  suffixIcon: _scanButton(urlController, 'Scan LNbits URL'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: adminKeyController,
                decoration: InputDecoration(
                  labelText: 'Admin API key',
                  helperText: 'Full-access key — used for all operations',
                  suffixIcon: _scanButton(adminKeyController, 'Scan admin key'),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 16),
              const Text(
                'Find the QR code in LNbits → wallet → "API info" → Admin key.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
