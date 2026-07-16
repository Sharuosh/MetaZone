
import 'metazone_unity_platform_interface.dart';

class MetazoneUnity {
  Future<String?> getPlatformVersion() {
    return MetazoneUnityPlatform.instance.getPlatformVersion();
  }
}
