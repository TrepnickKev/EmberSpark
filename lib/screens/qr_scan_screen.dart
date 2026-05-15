import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../l10n/app_localizations.dart';
import '../widgets/stacked_action_button.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key, this.title});

  /// Custom title; if null, falls back to the localized "Scan QR".
  final String? title;

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handled = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final code = capture.barcodes.isEmpty
        ? null
        : capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;
    _handled = true;
    Navigator.pop(context, code);
  }

  Future<void> _paste() async {
    if (_handled) return;
    final l10n = AppLocalizations.of(context)!;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (!mounted) return;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.clipboardEmpty)),
      );
      return;
    }
    _handled = true;
    Navigator.pop(context, text);
  }

  Future<void> _pickImage() async {
    if (_handled) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final analyser = MobileScannerController();
    try {
      final result = await analyser.analyzeImage(picked.path);
      final code = (result?.barcodes.isNotEmpty ?? false)
          ? result!.barcodes.first.rawValue
          : null;
      if (code == null || code.isEmpty) {
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(l10n.imageNoQr)));
        return;
      }
      if (!mounted) return;
      _handled = true;
      Navigator.pop(context, code);
    } finally {
      await analyser.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? l10n.commonScanQr),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(controller: controller, onDetect: _onDetect),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                color: Colors.black.withValues(alpha: 0.55),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StackedActionButton(
                      icon: Icons.content_paste,
                      label: l10n.commonPaste,
                      onPressed: _paste,
                    ),
                    StackedActionButton(
                      icon: Icons.image_outlined,
                      label: l10n.commonImage,
                      onPressed: _pickImage,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
