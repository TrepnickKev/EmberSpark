import 'package:flutter/foundation.dart';

/// Bumped to "1, 2, 3..." each time a payment succeeds. The home-screen
/// avatar listens for changes and plays a brief coin-flip checkmark
/// animation. Lives outside any widget tree so any pay screen can fire
/// it without prop-drilling.
final paymentSuccessTrigger = ValueNotifier<int>(0);

void signalPaymentSuccess() {
  paymentSuccessTrigger.value = paymentSuccessTrigger.value + 1;
}
