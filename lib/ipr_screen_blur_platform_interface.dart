import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ipr_screen_blur_method_channel.dart';

abstract class IprScreenBlurPlatform extends PlatformInterface {
  /// Constructs a IprScreenBlurPlatform.
  IprScreenBlurPlatform() : super(token: _token);

  static final Object _token = Object();

  static IprScreenBlurPlatform _instance = MethodChannelIprScreenBlur();

  /// The default instance of [IprScreenBlurPlatform] to use.
  ///
  /// Defaults to [MethodChannelIprScreenBlur].
  static IprScreenBlurPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IprScreenBlurPlatform] when
  /// they register themselves.
  static set instance(IprScreenBlurPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
