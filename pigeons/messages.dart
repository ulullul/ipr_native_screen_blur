// dart run pigeon --input pigeons/messages.dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    kotlinOut: 'android/src/main/kotlin/com/ipr/screen_blur/ipr_screen_blur/Messages.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.ipr.screen_blur.ipr_screen_blur',
    ),
    swiftOut: 'ios/ipr_screen_blur/Sources/ipr_screen_blur/Messages.g.swift',
    dartPackageName: 'ipr_screen_blur',
  ),
)
@HostApi()
abstract class SecureScreenHostApi {
  void setSecureMode(bool enabled);

  bool isScreenCaptured();
}

sealed class ScreenEvent {}

// iOS only
class ScreenshotEvent extends ScreenEvent {}

class CaptureStateEvent extends ScreenEvent {
  CaptureStateEvent(this.captured);

  bool captured;
}

@EventChannelApi()
abstract class SecureScreenEventApi {
  ScreenEvent streamScreenEvents();
}
