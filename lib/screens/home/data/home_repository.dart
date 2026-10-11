import 'package:flutter/material.dart';

import '../domain/home_model.dart';
import '../domain/home_section_model.dart';

/// Home data source for the first MetaZone directory pilot.
///
/// Pilot coverage: New Damietta, Damietta Governorate, Egypt.
/// Coordinates below are sourced from OpenStreetMap-derived records (linked in
/// the companion setup note). Ratings, review counts, opening hours, contact
/// details, distances, and MetaZone business verification are intentionally
/// left unconfirmed instead of showing invented values.
///
/// This is still a local seed repository, not a live nearby-places service.
/// A production repository can later replace [_pilotPlaces] with Firestore or
/// another curated data source without changing HomeData's contract.
class HomeRepository {
  Future<HomeData> loadHome({String? locationName}) async {
    // Keep the short async boundary used by the existing Home loading state.
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final String requestedLocation = locationName?.trim() ?? '';
    final String resolvedLocation = requestedLocation.isNotEmpty
        ? requestedLocation
        : 'New Damietta, Damietta';
    final bool usePilotDirectory =
        requestedLocation.isEmpty || _isNewDamiettaArea(requestedLocation);

    // Never show New Damietta pins under a different selected city. The pilot
    // is deliberately limited until more locally reviewed records are added.
    final List<NearbyPlace> places =
    usePilotDirectory ? _pilotPlaces : const <NearbyPlace>[];
    final List<NearbyPlace> featuredPlaces = usePilotDirectory
        ? <NearbyPlace>[
      _findPlace(places, 'chocolate_house'),
      _findPlace(places, 'ahmed_balboul_cafe'),
      _findPlace(places, 'hyper_el_madina'),
    ]
        : <NearbyPlace>[];

    return HomeData(
      locationName: resolvedLocation,
      categories: const <HomeCategory>[
        HomeCategory(
          type: HomeCategoryType.nearby,
          label: 'Nearby',
          icon: Icons.near_me_rounded,
        ),
        HomeCategory(
          type: HomeCategoryType.food,
          label: 'Food',
          icon: Icons.restaurant_rounded,
        ),
        HomeCategory(
          type: HomeCategoryType.cafes,
          label: 'Cafes',
          icon: Icons.local_cafe_rounded,
        ),
        HomeCategory(
          type: HomeCategoryType.healthcare,
          label: 'Health',
          icon: Icons.local_hospital_rounded,
        ),
        HomeCategory(
          type: HomeCategoryType.education,
          label: 'Education',
          icon: Icons.school_rounded,
        ),
        HomeCategory(
          type: HomeCategoryType.shopping,
          label: 'Shopping',
          icon: Icons.shopping_bag_rounded,
        ),
        HomeCategory(
          type: HomeCategoryType.hotels,
          label: 'Hotels',
          icon: Icons.hotel_rounded,
        ),
        HomeCategory(
          type: HomeCategoryType.more,
          label: 'More',
          icon: Icons.more_horiz_rounded,
        ),
      ],
      nearbyPlaces: usePilotDirectory
          ? <NearbyPlace>[
        _findPlace(places, 'new_damietta_hospital'),
        _findPlace(places, 'kafrawy_language_school'),
        _findPlace(places, 'abo_shaker_2'),
      ]
          : <NearbyPlace>[],
      // Do not advertise fictional real-time events, offers, or opening times.
      happenings: const <Happening>[],
      goals: const <GoalAction>[
        GoalAction(
          title: 'Find healthcare',
          subtitle: 'Hospitals, clinics & labs',
          icon: Icons.medical_services_rounded,
        ),
        GoalAction(
          title: 'Find food',
          subtitle: 'Restaurants & cafes',
          icon: Icons.restaurant_menu_rounded,
        ),
        GoalAction(
          title: 'Find a pharmacy',
          subtitle: 'Nearby pharmacies',
          icon: Icons.local_pharmacy_rounded,
        ),
        GoalAction(
          title: 'Find an event',
          subtitle: 'Events will appear when verified listings are available',
          icon: Icons.event_rounded,
        ),
      ],
      // These are featured directory listings, not ranked or personalized
      // recommendations. No synthetic rating or popularity score is assigned.
      recommendations: featuredPlaces,
    );
  }

  /// Returns the complete curated local directory used by the map.
  /// Home sections can feature a smaller subset; the map should use this full
  /// list so places are not omitted merely because they are not featured on Home.
  Future<List<NearbyPlace>> loadDirectory({String? area}) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final String requestedArea = area?.trim() ?? '';
    if (requestedArea.isNotEmpty && !_isNewDamiettaArea(requestedArea)) {
      // This seed directory only covers New Damietta. Do not silently claim it
      // is a directory for Damietta city or another governorate.
      return const <NearbyPlace>[];
    }
    return List<NearbyPlace>.unmodifiable(_pilotPlaces);
  }

  static bool _isNewDamiettaArea(String value) {
    final String normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي');
    return normalized.contains('new damietta') ||
        normalized.contains('دمياط الجديدة');
  }

  static NearbyPlace _findPlace(List<NearbyPlace> places, String id) {
    return places.firstWhere((NearbyPlace place) => place.id == id);
  }

  static final List<NearbyPlace> _pilotPlaces = <NearbyPlace>[
    NearbyPlace(
      id: 'new_damietta_hospital',
      name: 'مستشفى دمياط الجديدة',
      category: 'Hospital',
      // No verified venue photo has been added yet.
      // Genuine venue photos will be added only after they are sourced.
      imageUrl: '',
      rating: 0,
      reviewCount: 0,
      distance: 'Enable location',
      isOpen: false,
      zoneStatus: 'Directory listing',
      latitude: 31.44023,
      longitude: 31.69207,
      coordinatesVerified: true,
      address: 'New Damietta, Damietta Governorate, Egypt',
      description:
      'Pilot directory entry. Location coordinates are sourced from an '
          'OpenStreetMap-derived public map record. MetaZone has not verified '
          'the venue profile, opening hours, ratings, or contact details.',
      services: const <String>[],
      isVerified: false,
      ratingVerified: false,
      openingStatusVerified: false,
      dataSourceLabel: 'OpenStreetMap contributors',
      locationSourceUrl: 'https://www.openstreetmap.org/node/5984828885',
      // Profile status has not been verified by MetaZone; source link only.
      lastVerifiedAt: null,
    ),
    NearbyPlace(
      id: 'kafrawy_language_school',
      name: 'Kafrawy Language School',
      category: 'Education',
      // Genuine venue photos will be added only after they are sourced.
      imageUrl: '',
      rating: 0,
      reviewCount: 0,
      distance: 'Enable location',
      isOpen: false,
      zoneStatus: 'Directory listing',
      latitude: 31.44365,
      longitude: 31.68551,
      coordinatesVerified: true,
      address: 'New Damietta, Damietta Governorate, Egypt',
      description:
      'Pilot directory entry. Location coordinates are sourced from an '
          'OpenStreetMap-derived public map record. MetaZone has not verified '
          'the venue profile, opening hours, ratings, or contact details.',
      isVerified: false,
      ratingVerified: false,
      openingStatusVerified: false,
      dataSourceLabel: 'OpenStreetMap contributors',
      locationSourceUrl: 'https://www.openstreetmap.org/way/687930772',
      // Profile status has not been verified by MetaZone; source link only.
      lastVerifiedAt: null,
    ),
    NearbyPlace(
      id: 'abo_shaker_2',
      name: 'Abo Shaker 2',
      category: 'Fast Food',
      // Genuine venue photos will be added only after they are sourced.
      imageUrl: '',
      rating: 0,
      reviewCount: 0,
      distance: 'Enable location',
      isOpen: false,
      zoneStatus: 'Directory listing',
      latitude: 31.44694,
      longitude: 31.68050,
      coordinatesVerified: true,
      address: 'New Damietta, Damietta Governorate, Egypt',
      description:
      'Pilot directory entry. Public map data classifies this location as '
          'a fast-food restaurant. MetaZone has not verified its current menu, '
          'hours, ratings, or contact details.',
      isVerified: false,
      ratingVerified: false,
      openingStatusVerified: false,
      dataSourceLabel: 'OpenStreetMap contributors',
      locationSourceUrl: 'https://www.openstreetmap.org/node/10009636874',
      // Profile status has not been verified by MetaZone; source link only.
      lastVerifiedAt: null,
    ),
    NearbyPlace(
      id: 'chocolate_house',
      name: 'Chocolate House',
      category: 'Chocolate Shop',
      // Genuine venue photos will be added only after they are sourced.
      imageUrl: '',
      rating: 0,
      reviewCount: 0,
      distance: 'Enable location',
      isOpen: false,
      zoneStatus: 'Directory listing',
      latitude: 31.43809,
      longitude: 31.68044,
      coordinatesVerified: true,
      address: 'New Damietta, Damietta Governorate, Egypt',
      description:
      'Pilot directory entry. Location coordinates are sourced from an '
          'OpenStreetMap-derived public map record. No verified venue photo is '
          'available; MetaZone has not verified the venue profile or contacts.',
      isVerified: false,
      ratingVerified: false,
      openingStatusVerified: false,
      dataSourceLabel: 'OpenStreetMap contributors',
      locationSourceUrl: 'https://www.openstreetmap.org/node/9169794873',
      // Profile status has not been verified by MetaZone; source link only.
      lastVerifiedAt: null,
    ),
    NearbyPlace(
      id: 'ahmed_balboul_cafe',
      name: 'Ahmed Balboul Cafe',
      category: 'Cafe',
      // Genuine venue photos will be added only after they are sourced.
      imageUrl: '',
      rating: 0,
      reviewCount: 0,
      distance: 'Enable location',
      isOpen: false,
      zoneStatus: 'Directory listing',
      latitude: 31.43742,
      longitude: 31.67952,
      coordinatesVerified: true,
      address: 'New Damietta, Damietta Governorate, Egypt',
      description:
      'Pilot directory entry. Public map data identifies this location '
          'as a cafe. MetaZone has not verified its photos, hours, ratings, '
          'or contact details.',
      isVerified: false,
      ratingVerified: false,
      openingStatusVerified: false,
      dataSourceLabel: 'OpenStreetMap contributors',
      locationSourceUrl: 'https://www.openstreetmap.org/node/9074821515',
      // Profile status has not been verified by MetaZone; source link only.
      lastVerifiedAt: null,
    ),
    NearbyPlace(
      id: 'hyper_el_madina',
      name: 'هايبر المدينة',
      category: 'Supermarket',
      // Genuine venue photos will be added only after they are sourced.
      imageUrl: '',
      rating: 0,
      reviewCount: 0,
      distance: 'Enable location',
      isOpen: false,
      zoneStatus: 'Directory listing',
      latitude: 31.43194,
      longitude: 31.68501,
      coordinatesVerified: true,
      address: 'New Damietta, Damietta Governorate, Egypt',
      description:
      'Pilot directory entry. Location coordinates are sourced from an '
          'OpenStreetMap-derived public map record. MetaZone has not verified '
          'opening hours, ratings, or contact details.',
      isVerified: false,
      ratingVerified: false,
      openingStatusVerified: false,
      dataSourceLabel: 'OpenStreetMap contributors',
      locationSourceUrl: 'https://www.openstreetmap.org/node/6989546513',
      // Profile status has not been verified by MetaZone; source link only.
      lastVerifiedAt: null,
    ),
    NearbyPlace(
      id: 'masjid_al_huda_al_nabawi_new_damietta',
      name: 'مسجد الهدي النبوي',
      category: 'Mosque',
      imageUrl: '',
      rating: 0,
      reviewCount: 0,
      distance: 'Enable location',
      isOpen: false,
      zoneStatus: 'Directory listing',
      latitude: 31.44474,
      longitude: 31.68558,
      coordinatesVerified: true,
      address: 'New Damietta, Damietta Governorate, Egypt',
      description:
      'Public map record classifies this location as a mosque. MetaZone '
          'has not verified prayer times, facilities, or current venue details.',
      services: const <String>[],
      isVerified: false,
      ratingVerified: false,
      openingStatusVerified: false,
      dataSourceLabel: 'OpenStreetMap contributors',
      locationSourceUrl: 'https://www.openstreetmap.org/way/687930773',
      lastVerifiedAt: null,
    ),
    NearbyPlace(
      id: 'new_damietta_police_station',
      name: 'قسم شرطة دمياط الجديدة',
      category: 'Public Service',
      imageUrl: '',
      rating: 0,
      reviewCount: 0,
      distance: 'Enable location',
      isOpen: false,
      zoneStatus: 'Directory listing',
      latitude: 31.44094,
      longitude: 31.68305,
      coordinatesVerified: true,
      address: 'New Damietta, Damietta Governorate, Egypt',
      description:
      'Public map record identifies this location as a police station. '
          'MetaZone has not verified service hours or current contact details.',
      services: const <String>[],
      isVerified: false,
      ratingVerified: false,
      openingStatusVerified: false,
      dataSourceLabel: 'OpenStreetMap contributors',
      locationSourceUrl: 'https://www.openstreetmap.org/node/8909143050',
      lastVerifiedAt: null,
    ),
  ];
}
