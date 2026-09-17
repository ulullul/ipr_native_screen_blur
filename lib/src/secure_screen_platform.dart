import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_secure_screen.dart';
import 'secure_screen_event.dart';

/// The transport-independent interface that the public API talks to.
abstract class SecureScreenPlatform extends PlatformInterface {
  SecureScreenPlatform() : super(token: _token);

  static final Object _token = Object();

  static SecureScreenPlatform _instance = MethodChannelSecureScreen();

  /// The default instance of [SecureScreenPlatform] to use.
  ///
  /// Defaults to [MethodChannelSecureScreen].
  static SecureScreenPlatform get instance => _instance;

  static set instance(SecureScreenPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> setSecureMode(bool enabled) {
    throw UnimplementedError('setSecureMode() has not been implemented.');
  }

  Future<bool> isScreenCaptured() {
    throw UnimplementedError('isScreenCaptured() has not been implemented.');
  }

  Stream<SecureScreenEvent> get events {
    throw UnimplementedError('events has not been implemented.');
  }
}
