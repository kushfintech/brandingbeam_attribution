import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'socialsync_attribution_platform_interface.dart';

/// An implementation of [SocialsyncAttributionPlatform] that uses method channels.
class MethodChannelSocialsyncAttribution extends SocialsyncAttributionPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('socialsync_attribution');

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
