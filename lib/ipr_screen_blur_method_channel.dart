import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ipr_screen_blur_platform_interface.dart';

/// An implementation of [IprScreenBlurPlatform] that uses method channels.
class MethodChannelIprScreenBlur extends IprScreenBlurPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ipr_screen_blur');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
