import 'package:flutter_test/flutter_test.dart';
import 'package:ipr_screen_blur/ipr_screen_blur.dart';
import 'package:ipr_screen_blur/ipr_screen_blur_platform_interface.dart';
import 'package:ipr_screen_blur/ipr_screen_blur_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockIprScreenBlurPlatform
    with MockPlatformInterfaceMixin
    implements IprScreenBlurPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final IprScreenBlurPlatform initialPlatform = IprScreenBlurPlatform.instance;

  test('$MethodChannelIprScreenBlur is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelIprScreenBlur>());
  });

  test('getPlatformVersion', () async {
    IprScreenBlur iprScreenBlurPlugin = IprScreenBlur();
    MockIprScreenBlurPlatform fakePlatform = MockIprScreenBlurPlatform();
    IprScreenBlurPlatform.instance = fakePlatform;

    expect(await iprScreenBlurPlugin.getPlatformVersion(), '42');
  });
}
