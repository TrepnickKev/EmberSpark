import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart' show FlashMode;
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../services/nfc_coordinator.dart';
import '../services/qr_image_decoder.dart';
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
  CameraController? _camera;
  bool _torchOn = false;
  CameraLensDirection _lens = CameraLensDirection.back;
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
    super.dispose();
  }

  void _onDetect(Code result) {
    if (_handled || !mounted) return;
    final code = result.text;
    if (code == null || code.isEmpty) return;
    _finish(code);
  }

  // The reader owns its CameraController and replaces it on a lens switch, so
  // keep the latest one for the torch button.
  void _onControllerCreated(CameraController? controller, Exception? _) {
    _camera = controller;
    _torchOn = false;
  }

  Future<void> _toggleTorch() async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) return;
    try {
      await camera.setFlashMode(_torchOn ? FlashMode.off : FlashMode.torch);
      _torchOn = !_torchOn;
    } catch (_) {
      // No flash on this camera (e.g. the front one).
    }
  }

  void _switchCamera() {
    setState(() {
      _lens = _lens == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;
    });
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
    final code = await decodeQrFromImage(picked.path);
    if (!mounted) return;
    if (code == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.imageNoQr)));
      return;
    }
    _finish(code);
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
            onPressed: _toggleTorch,
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: ReaderWidget(
              onScan: _onDetect,
              onControllerCreated: _onControllerCreated,
              codeFormat: Format.qrCode,
              lensDirection: _lens,
              tryHarder: true,
              tryInverted: true,
              // The app bar and bottom bar hold the controls.
              showFlashlight: false,
              showToggleCamera: false,
              showGallery: false,
              cropPercent: 0.8,
              // Retry quickly while nothing is found; the first hit pops.
              scanDelay: const Duration(milliseconds: 100),
            ),
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
