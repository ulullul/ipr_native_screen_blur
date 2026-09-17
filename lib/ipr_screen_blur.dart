
import 'ipr_screen_blur_platform_interface.dart';

class IprScreenBlur {
  Future<String?> getPlatformVersion() {
    return IprScreenBlurPlatform.instance.getPlatformVersion();
  }
}
