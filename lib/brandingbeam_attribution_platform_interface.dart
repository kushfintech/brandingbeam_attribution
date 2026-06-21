import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'brandingbeam_attribution_method_channel.dart';

abstract class BrandingbeamAttributionPlatform extends PlatformInterface {
  /// Constructs a BrandingbeamAttributionPlatform.
  BrandingbeamAttributionPlatform() : super(token: _token);

  static final Object _token = Object();

  static BrandingbeamAttributionPlatform _instance =
      MethodChannelBrandingbeamAttribution();

  /// The default instance of [BrandingbeamAttributionPlatform] to use.
  ///
  /// Defaults to [MethodChannelBrandingbeamAttribution].
  static BrandingbeamAttributionPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BrandingbeamAttributionPlatform] when
  /// they register themselves.
  static set instance(BrandingbeamAttributionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Native device signals plus, on Android, the Play Install Referrer string and,
  /// on iOS, the identifierForVendor. Keys: platform, deviceModel, osVersion,
  /// installReferrer, idfv.
  Future<Map<String, dynamic>> getInstallContext() {
    throw UnimplementedError('getInstallContext() has not been implemented.');
  }
}
