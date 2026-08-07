import 'package:package_info_plus/package_info_plus.dart';

final class AppVersion {
  AppVersion._();

  static PackageInfo? _packageInfo;

  static Future<void> initialize() async {
    _packageInfo ??= await PackageInfo.fromPlatform();
  }

  static String get appName =>
      _packageInfo?.appName ?? '';

  static String get packageName =>
      _packageInfo?.packageName ?? '';

  static String get version =>
      _packageInfo?.version ?? '';

  static String get buildNumber =>
      _packageInfo?.buildNumber ?? '';

  static String get fullVersion =>
      '$version+$buildNumber';
}