import 'package:flutter_zxing/flutter_zxing.dart';

/// Decodes the first QR code in the image file at [path] (e.g. a screenshot
/// picked from the gallery). Returns null when none is found or the file can't
/// be read. Uses zxing-cpp, so no proprietary Google code is involved.
Future<String?> decodeQrFromImage(String path) async {
  try {
    final code = await zx.readBarcodeImagePathString(
      path,
      DecodeParams(
        format: Format.qrCode,
        tryHarder: true,
        tryInverted: true,
        // Dense LNURL/BOLT11 codes need more pixels than the 768 px default.
        maxSize: 2048,
      ),
    );
    final text = code.text;
    return code.isValid && text != null && text.isNotEmpty ? text : null;
  } catch (_) {
    return null;
  }
}
