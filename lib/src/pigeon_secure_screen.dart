import 'messages.g.dart';
import 'secure_screen_event.dart';
import 'secure_screen_platform.dart';

class PigeonSecureScreen extends SecureScreenPlatform {
  final SecureScreenHostApi _hostApi = SecureScreenHostApi();

  @override
  Future<void> setSecureMode(bool enabled) => _hostApi.setSecureMode(enabled);

  @override
  Future<bool> isScreenCaptured() => _hostApi.isScreenCaptured();

  @override
  late final Stream<SecureScreenEvent> events = streamScreenEvents().map(
    _toPublicEvent,
  );

  static SecureScreenEvent _toPublicEvent(ScreenEvent event) => switch (event) {
    ScreenshotEvent() => const ScreenshotTaken(),
    CaptureStateEvent(:final captured) => CaptureStateChanged(
      captured: captured,
    ),
  };
}
