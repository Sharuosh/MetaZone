import 'package:flutter_test/flutter_test.dart';
import 'package:metazone_unity/metazone_unity.dart';
import 'package:metazone_unity/metazone_unity_platform_interface.dart';
import 'package:metazone_unity/metazone_unity_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMetazoneUnityPlatform
    with MockPlatformInterfaceMixin
    implements MetazoneUnityPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MetazoneUnityPlatform initialPlatform = MetazoneUnityPlatform.instance;

  test('$MethodChannelMetazoneUnity is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMetazoneUnity>());
  });

  test('getPlatformVersion', () async {
    MetazoneUnity metazoneUnityPlugin = MetazoneUnity();
    MockMetazoneUnityPlatform fakePlatform = MockMetazoneUnityPlatform();
    MetazoneUnityPlatform.instance = fakePlatform;

    expect(await metazoneUnityPlugin.getPlatformVersion(), '42');
  });
}
