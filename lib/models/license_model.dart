// lib/models/license_model.dart

class LicenseModel {
  final String type;      // personal / commercial / exclusive
  final String details;   // النص الكامل للترخيص
  final int allowedDevices;
  final bool watermark;   // علامة مائية لو المنتج غير مشتَرى بالكامل
  final DateTime? expiration;
  final String version;

  LicenseModel({
    required this.type,
    required this.details,
    required this.allowedDevices,
    required this.watermark,
    required this.version,
    this.expiration,
  });

  factory LicenseModel.fromJson(Map<String, dynamic> json) {
    return LicenseModel(
      type: json['type'],
      details: json['details'],
      allowedDevices: json['allowedDevices'],
      watermark: json['watermark'],
      version: json['version'],
      expiration: json['expiration'] == null
          ? null
          : DateTime.parse(json['expiration']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'details': details,
      'allowedDevices': allowedDevices,
      'watermark': watermark,
      'version': version,
      'expiration': expiration?.toIso8601String(),
    };
  }
}
