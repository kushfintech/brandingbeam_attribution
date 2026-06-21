import 'package:flutter_test/flutter_test.dart';
import 'package:socialsync_attribution/socialsync_attribution.dart';
import 'package:socialsync_attribution/socialsync_attribution_platform_interface.dart';
import 'package:socialsync_attribution/socialsync_attribution_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSocialsyncAttributionPlatform
    with MockPlatformInterfaceMixin
    implements SocialsyncAttributionPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Map<String, dynamic>> getInstallContext() =>
      Future.value(<String, dynamic>{'platform': 'ios'});
}

void main() {
  final SocialsyncAttributionPlatform initialPlatform = SocialsyncAttributionPlatform.instance;

  test('$MethodChannelSocialsyncAttribution is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSocialsyncAttribution>());
  });

  test('getPlatformVersion', () async {
    SocialsyncAttribution socialsyncAttributionPlugin = SocialsyncAttribution();
    MockSocialsyncAttributionPlatform fakePlatform = MockSocialsyncAttributionPlatform();
    SocialsyncAttributionPlatform.instance = fakePlatform;

    expect(await socialsyncAttributionPlugin.getPlatformVersion(), '42');
  });
}
