import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Whether the device is in flight mode (airplane mode). Updated live from the
/// Android setting and its change broadcast (see MainActivity.kt). Other
/// platforms have no such signal, so it simply stays `false` there.
final flightMode = ValueNotifier<bool>(false);

const _flightModeChannel = EventChannel('emberspark/flight_mode');

/// Starts watching the flight-mode setting. Call once at app start.
void startFlightModeWatch() {
  if (kIsWeb || !Platform.isAndroid) return;
  _flightModeChannel.receiveBroadcastStream().listen(
    (event) => flightMode.value = event == true,
    // A missing/failed channel just means "unknown": keep the normal behaviour.
    onError: (_) {},
  );
}
