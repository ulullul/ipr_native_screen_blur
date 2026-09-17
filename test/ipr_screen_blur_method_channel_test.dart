import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ipr_screen_blur/ipr_screen_blur_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelIprScreenBlur platform = MethodChannelIprScreenBlur();
  const MethodChannel channel = MethodChannel('ipr_screen_blur');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
