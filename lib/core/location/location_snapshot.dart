class LocationSnapshot {
  final double latitude;
  final double longitude;
  final String? governorateName;
  final String? cityName;
  final String? countryCode;
  final String? formattedAddress;

  const LocationSnapshot({
    required this.latitude,
    required this.longitude,
    this.governorateName,
    this.cityName,
    this.countryCode,
    this.formattedAddress,
  });

  String get displayLocationName {
    final governorate = governorateName?.trim();

    if (governorate != null && governorate.isNotEmpty) {
      return governorate;
    }

    final city = cityName?.trim();

    if (city != null && city.isNotEmpty) {
      return city;
    }

    return 'Around you';
  }

  bool get hasGovernorate {
    return governorateName != null &&
        governorateName!.trim().isNotEmpty;
  }

  bool get hasCity {
    return cityName != null &&
        cityName!.trim().isNotEmpty;
  }

  LocationSnapshot copyWith({
    double? latitude,
    double? longitude,
    String? governorateName,
    String? cityName,
    String? countryCode,
    String? formattedAddress,
  }) {
    return LocationSnapshot(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      governorateName:
      governorateName ?? this.governorateName,
      cityName: cityName ?? this.cityName,
      countryCode:
      countryCode ?? this.countryCode,
      formattedAddress:
      formattedAddress ?? this.formattedAddress,
    );
  }
}