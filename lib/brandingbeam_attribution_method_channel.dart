import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'brandingbeam_attribution_platform_interface.dart';

/// An implementation of [BrandingbeamAttributionPlatform] that uses method channels.
class MethodChannelBrandingbeamAttribution extends BrandingbeamAttributionPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('brandingbeam_attribution');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<Map<String, dynamic>> getInstallContext() async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>(
      'getInstallContext',
    );
    return result ?? <String, dynamic>{};
  }
}
