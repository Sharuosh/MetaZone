import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'metazone_unity_method_channel.dart';

abstract class MetazoneUnityPlatform extends PlatformInterface {
  /// Constructs a MetazoneUnityPlatform.
  MetazoneUnityPlatform() : super(token: _token);

  static final Object _token = Object();

  static MetazoneUnityPlatform _instance = MethodChannelMetazoneUnity();

  /// The default instance of [MetazoneUnityPlatform] to use.
  ///
  /// Defaults to [MethodChannelMetazoneUnity].
  static MetazoneUnityPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MetazoneUnityPlatform] when
  /// they register themselves.
  static set instance(MetazoneUnityPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
