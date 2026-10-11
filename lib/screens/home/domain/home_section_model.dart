import 'package:flutter/material.dart';

enum HomeCategoryType {
  nearby,
  food,
  cafes,
  healthcare,
  education,
  shopping,
  hotels,
  more,
}

class HomeCategory {
  const HomeCategory({
    required this.type,
    required this.label,
    required this.icon,
  });

  final HomeCategoryType type;
  final String label;
  final IconData icon;
}

/// A place in the MetaZone world directory.
///
/// The original fields remain required for backwards compatibility with the
/// existing Home repository. Rich business/location metadata is optional so
/// demo entries continue to compile, while verified Zone records can provide
/// exact coordinates and contact information.
class NearbyPlace {
  const NearbyPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.isOpen,
    required this.zoneStatus,
    this.latitude,
    this.longitude,
    this.coordinatesVerified = false,
    this.address,
    this.description,
    this.phone,
    this.email,
    this.websiteUrl,
    this.whatsAppNumber,
    this.openingHours,
    this.socialLinks = const <String, String>{},
    this.services = const <String>[],
    this.galleryImageUrls = const <String>[],
    this.isVerified = false,
    this.ratingVerified = false,
    this.openingStatusVerified = false,
    this.dataSourceLabel,
    this.locationSourceUrl,
    this.lastVerifiedAt,
  });

  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String distance;
  final bool isOpen;
  final String zoneStatus;

  /// UI helpers retained for the existing Home cards.
  bool get hasRating => rating > 0;

  bool get hasReviews => reviewCount > 0;

  /// WGS84 coordinates from a reviewable public map source.
  /// `coordinatesVerified` means the source record and coordinate values were checked;
  /// it does not mean a MetaZone team member physically verified the venue.
  final double? latitude;
  final double? longitude;
  final bool coordinatesVerified;

  final String? address;
  final String? description;
  final String? phone;
  final String? email;
  final String? websiteUrl;
  final String? whatsAppNumber;
  final String? openingHours;
  final Map<String, String> socialLinks;
  final List<String> services;
  final List<String> galleryImageUrls;

  /// These flags stop demo values being presented as verified facts.
  final bool isVerified;
  final bool ratingVerified;
  final bool openingStatusVerified;
  final String? dataSourceLabel;

  /// Public reference used to review the source of the mapped coordinates.
  /// This is provenance, not proof that the venue is currently open or
  /// that the location has been physically surveyed by MetaZone.
  final String? locationSourceUrl;

  /// Last time the full Zone/business profile was verified by MetaZone.
  /// Keep null while only the coordinate source has been reviewed.
  final DateTime? lastVerifiedAt;

  bool get hasExactCoordinates =>
      coordinatesVerified &&
          latitude != null &&
          longitude != null &&
          latitude!.isFinite &&
          longitude!.isFinite &&
          latitude! >= -90 &&
          latitude! <= 90 &&
          longitude! >= -180 &&
          longitude! <= 180;

  /// Returns the same Zone record with a newly calculated distance label.
  /// This keeps the canonical place ID and all business metadata unchanged.
  NearbyPlace withDistance(String value) => NearbyPlace(
    id: id,
    name: name,
    category: category,
    imageUrl: imageUrl,
    rating: rating,
    reviewCount: reviewCount,
    distance: value,
    isOpen: isOpen,
    zoneStatus: zoneStatus,
    latitude: latitude,
    longitude: longitude,
    coordinatesVerified: coordinatesVerified,
    address: address,
    description: description,
    phone: phone,
    email: email,
    websiteUrl: websiteUrl,
    whatsAppNumber: whatsAppNumber,
    openingHours: openingHours,
    socialLinks: socialLinks,
    services: services,
    galleryImageUrls: galleryImageUrls,
    isVerified: isVerified,
    ratingVerified: ratingVerified,
    openingStatusVerified: openingStatusVerified,
    dataSourceLabel: dataSourceLabel,
    locationSourceUrl: locationSourceUrl,
    lastVerifiedAt: lastVerifiedAt,
  );
}

enum HappeningType { event, offer, activity }

class Happening {
  const Happening({
    required this.id,
    required this.type,
    required this.title,
    required this.placeName,
    required this.distance,
    required this.imageUrl,
    this.meta,
  });

  final String id;
  final HappeningType type;
  final String title;
  final String placeName;
  final String distance;
  final String imageUrl;
  final String? meta;

  bool get hasMeta => meta != null && meta!.trim().isNotEmpty;
}

class GoalAction {
  const GoalAction({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
