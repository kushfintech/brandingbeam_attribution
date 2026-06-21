import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialsync_attribution/socialsync_attribution_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelSocialsyncAttribution platform = MethodChannelSocialsyncAttribution();
  const MethodChannel channel = MethodChannel('socialsync_attribution');

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
