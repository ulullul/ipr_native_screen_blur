import 'src/secure_screen_event.dart';
import 'src/secure_screen_platform.dart';

export 'src/secure_screen_event.dart';

/// Screen protection for screens that show sensitive data.
class SecureScreen {
  /// Turns screenshot/recording blocking and the app switcher overlay on or
  /// off.
  ///
  /// On Android this sets `FLAG_SECURE`. On iOS it uses an undocumented
  /// secure-layer technique and a native privacy overlay.
  Future<void> setSecureMode(bool enabled) {
    return SecureScreenPlatform.instance.setSecureMode(enabled);
  }

  /// Whether the screen is being recorded, mirrored or shown over AirPlay
  /// right now. Always `false` on Android.
  Future<bool> isScreenCaptured() {
    return SecureScreenPlatform.instance.isScreenCaptured();
  }

  /// Screenshot and capture-state events. A broadcast stream shared by all
  /// [SecureScreen] instances.
  Stream<SecureScreenEvent> get events => SecureScreenPlatform.instance.events;
}
