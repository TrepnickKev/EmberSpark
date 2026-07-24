import 'dart:async';

import 'package:flutter/widgets.dart';

import 'lightning_router.dart';
import 'nfc_service.dart';

/// A tap handler registered by a screen. Returns true if it consumed the tap
/// (so the coordinator does not fall through to default routing).
typedef NfcTapHandler = Future<bool> Function(NfcAmbientTag tag);

/// App-wide NFC capture. While EmberSpark is foregrounded a single ambient
/// reader session stays alive so tapped cards are handled in-app instead of
/// triggering Android's tag-dispatch chooser (the Wallet-of-Satoshi behaviour).
///
/// A tapped card is offered first to the top registered [NfcTapHandler] (e.g.
/// the Receive screen charging a Bolt Card), then — if unhandled — routed via
/// [routeLightningCode]. Explicit, user-initiated sessions (Send read, Bolt
/// Card programming, contact-share write) must run inside [runExclusive] so the
/// ambient reader yields (Android allows only one reader mode at a time).
class NfcCoordinator {
  NfcCoordinator._();

  static final NfcCoordinator instance = NfcCoordinator._();

  NavigatorState? Function()? _navigator;
  NfcSession? _ambient;
  bool _foreground = false;
  bool _starting = false;
  bool _handling = false;
  int _suspend = 0;
  DateTime? _lastTapAt;
  final List<NfcTapHandler> _handlers = [];

  /// Wires the navigator lookup used for default tap routing. Called once at
  /// app start.
  void configure({required NavigatorState? Function() navigator}) {
    _navigator = navigator;
  }

  void pushHandler(NfcTapHandler handler) => _handlers.add(handler);
  void removeHandler(NfcTapHandler handler) => _handlers.remove(handler);

  /// App entered the foreground: (re)start the ambient reader.
  Future<void> onForeground() async {
    _foreground = true;
    await _ensureAmbient();
  }

  /// App left the foreground: stop the ambient reader so background tag
  /// dispatch (tap-to-launch) keeps working.
  Future<void> onBackground() async {
    _foreground = false;
    await _stopAmbient();
  }

  /// Runs [body] with the ambient reader suspended for [body]'s whole lifetime,
  /// restoring it afterwards. [body] must not return until its dedicated NFC
  /// session has fully stopped (e.g. wrap the entire read-and-show-dialog flow).
  Future<T> runExclusive<T>(Future<T> Function() body) async {
    await suspend();
    try {
      return await body();
    } finally {
      await resume();
    }
  }

  /// Manually suspends the ambient reader. Pair every call with [resume].
  /// Use when a screen owns NFC for its whole lifetime (e.g. Bolt Card
  /// programming, which drives raw DESFire reader mode).
  Future<void> suspend() async {
    _suspend++;
    await _stopAmbient();
  }

  Future<void> resume() async {
    if (_suspend > 0) _suspend--;
    await _ensureAmbient();
  }

  Future<void> _ensureAmbient() async {
    if (!_foreground || _suspend > 0 || _ambient != null || _starting) return;
    _starting = true;
    try {
      _ambient = await startAmbientReader(onTag: _handleTap);
    } catch (_) {
      // NFC off/absent — no ambient capture, no crash.
      _ambient = null;
    } finally {
      _starting = false;
    }
  }

  Future<void> _stopAmbient() async {
    final session = _ambient;
    _ambient = null;
    if (session != null) await session.stop();
  }

  Future<void> _handleTap(NfcAmbientTag tag) async {
    // Ignore a tap while one is already being handled, and debounce a card
    // that lingers on the reader. Crucially we do NOT stop the ambient reader
    // here: turning reader mode off while the card is still present makes
    // Android re-dispatch the tag and pop up the app-chooser mid-charge.
    if (_handling) return;
    final now = DateTime.now();
    if (_lastTapAt != null &&
        now.difference(_lastTapAt!) < const Duration(seconds: 2)) {
      return;
    }
    _handling = true;
    _lastTapAt = now;
    try {
      for (final handler in _handlers.reversed.toList()) {
        if (await handler(tag)) return;
      }
      final payload = tag.payload;
      final nav = _navigator?.call();
      if (payload != null && nav != null) {
        // Fire-and-forget: routeLightningCode awaits the pushed route's whole
        // lifetime, which we must not block the reader on.
        unawaited(routeLightningCode(nav, payload));
      }
    } finally {
      _handling = false;
    }
  }
}
