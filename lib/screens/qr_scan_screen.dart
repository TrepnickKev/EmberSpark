import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../l10n/app_localizations.dart';
import '../services/nfc_coordinator.dart';
import '../widgets/stacked_action_button.dart';
import 'bolt_card_charge_prompt.dart';

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

  // A tapped Bolt Card can only be charged, not paid to: inform, then charge.
  late final NfcTapHandler _nfcHandler;

  @override
  void initState() {
    super.initState();
    _nfcHandler = (tag) => promptBoltCardChargeOnly(context, tag);
    NfcCoordinator.instance.pushHandler(_nfcHandler);
  }

  @override
  void dispose() {
    NfcCoordinator.instance.removeHandler(_nfcHandler);
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled || !mounted) return;
    final code = capture.barcodes.isEmpty
        ? null
        : capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;
    _finish(code);
  }

  /// Pops the scanner exactly once with [result]. Guards against the camera
  /// stream (or an NFC/paste callback) firing a second pop after the route has
  /// already been dismissed — e.g. by the system back button. That extra pop
  /// would remove the screen underneath and black out the app.
  void _finish(String? result) {
    if (_handled || !mounted) return;
    _handled = true;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop(result);
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
    _finish(text);
  }

  // The app-wide ambient reader already captures NFC taps (and shows the
  // Bolt Card charge-only prompt via the registered handler), so this button
  // is just a hint to hold the tag near the phone.
  void _readNfc() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.nfcHoldTag)));
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
      _finish(code);
    } finally {
      await analyser.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      // A back gesture pops this route; mark it handled so an in-flight camera
      // detection can't fire a second pop and black out the app.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _handled = true;
      },
      child: Scaffold(
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
                      icon: Icons.nfc,
                      label: l10n.commonNfc,
                      onPressed: _readNfc,
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
      ),
    );
  }
}
