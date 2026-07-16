import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'metazone_unity_platform_interface.dart';

/// An implementation of [MetazoneUnityPlatform] that uses method channels.
class MethodChannelMetazoneUnity extends MetazoneUnityPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('metazone_unity');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
