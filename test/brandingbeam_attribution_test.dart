import 'package:flutter_test/flutter_test.dart';
import 'package:brandingbeam_attribution/brandingbeam_attribution.dart';
import 'package:brandingbeam_attribution/brandingbeam_attribution_platform_interface.dart';
import 'package:brandingbeam_attribution/brandingbeam_attribution_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBrandingbeamAttributionPlatform
    with MockPlatformInterfaceMixin
    implements BrandingbeamAttributionPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Map<String, dynamic>> getInstallContext() =>
      Future.value(<String, dynamic>{'platform': 'ios'});
}

void main() {
  final BrandingbeamAttributionPlatform initialPlatform = BrandingbeamAttributionPlatform.instance;

  test('$MethodChannelBrandingbeamAttribution is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBrandingbeamAttribution>());
  });

  test('getPlatformVersion', () async {
    BrandingbeamAttribution brandingbeamAttributionPlugin = BrandingbeamAttribution();
    MockBrandingbeamAttributionPlatform fakePlatform = MockBrandingbeamAttributionPlatform();
    BrandingbeamAttributionPlatform.instance = fakePlatform;

    expect(await brandingbeamAttributionPlugin.getPlatformVersion(), '42');
  });
}
