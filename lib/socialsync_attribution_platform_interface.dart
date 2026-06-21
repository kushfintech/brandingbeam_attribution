import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'socialsync_attribution_method_channel.dart';

abstract class SocialsyncAttributionPlatform extends PlatformInterface {
  /// Constructs a SocialsyncAttributionPlatform.
  SocialsyncAttributionPlatform() : super(token: _token);

  static final Object _token = Object();

  static SocialsyncAttributionPlatform _instance =
      MethodChannelSocialsyncAttribution();

  /// The default instance of [SocialsyncAttributionPlatform] to use.
  ///
  /// Defaults to [MethodChannelSocialsyncAttribution].
  static SocialsyncAttributionPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SocialsyncAttributionPlatform] when
  /// they register themselves.
  static set instance(SocialsyncAttributionPlatform instance) {
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
