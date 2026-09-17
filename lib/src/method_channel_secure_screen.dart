import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'secure_screen_event.dart';
import 'secure_screen_platform.dart';

class MethodChannelSecureScreen extends SecureScreenPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('ipr_screen_blur/methods');

  @visibleForTesting
  final eventChannel = const EventChannel('ipr_screen_blur/events');

  @override
  Future<void> setSecureMode(bool enabled) {
    return methodChannel.invokeMethod<void>('setSecureMode', {
      'enabled': enabled,
    });
  }

  @override
  Future<bool> isScreenCaptured() async {
    final captured = await methodChannel.invokeMethod<bool>('isScreenCaptured');
    return captured ?? false;
  }

  @override
  late final Stream<SecureScreenEvent> events = eventChannel
      .receiveBroadcastStream()
      .map(_decodeEvent)
      .where((event) => event != null)
      .cast<SecureScreenEvent>();

  static SecureScreenEvent? _decodeEvent(dynamic payload) {
    if (payload is! Map) return null;
    return switch (payload['type']) {
      'screenshotTaken' => const ScreenshotTaken(),
      'captureStateChanged' => CaptureStateChanged(
        captured: payload['captured'] == true,
      ),
      _ => null,
    };
  }
}
