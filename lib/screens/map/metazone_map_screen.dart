import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:meta_zone/core/theme/theme.dart';
import 'package:meta_zone/screens/home/domain/home_section_model.dart';

/// MetaZone's in-app map surface.
///
/// MapLibre renders the map. Zone identity and the exact pin coordinates come
/// from MetaZone's own NearbyPlace records, not from Google Places. The map
/// style URL is configurable at build time; the default uses OpenFreeMap's public Liberty style (no API key required).
class MetaZoneMapScreen extends StatefulWidget {
  const MetaZoneMapScreen({
    this.place,
    this.places = const <NearbyPlace>[],
    this.locationName = 'Egypt',
    this.onPlaceSelected,
    super.key,
  });

  final NearbyPlace? place;
  final List<NearbyPlace> places;
  final String locationName;
  final ValueChanged<NearbyPlace>? onPlaceSelected;

  static const String defaultStyleUrl = String.fromEnvironment(
    'METAZONE_MAP_STYLE_URL',
    defaultValue: 'https://tiles.openfreemap.org/styles/liberty',
  );

  @override
  State<MetaZoneMapScreen> createState() => _MetaZoneMapScreenState();
}

class _MetaZoneMapScreenState extends State<MetaZoneMapScreen> {
  static const List<String> _mapCategoryFilters = <String>[
    'All', 'Food', 'Cafes', 'Health', 'Education', 'Shopping', 'Hotels',
    'Worship', 'Public services', 'Transport', 'Leisure', 'Finance', 'Fuel',
  ];
  MapLibreMapController? _mapController;
  bool _styleLoaded = false;
  bool _locating = false;
  bool _routing = false;
  LatLng? _userPosition;
  String? _routeSummary;
  String _placeQuery = '';
  String _categoryFilter = 'All';
  int _annotationRevision = 0;
  bool? _lastRenderedPlaceLabelsVisible;
  Timer? _annotationRefreshTimer;

  static const String _placeSearchUrl = String.fromEnvironment(
    'METAZONE_PLACE_SEARCH_URL',
    defaultValue: 'https://photon.komoot.io/api/',
  );

  static const String _placeReverseUrl = String.fromEnvironment(
    'METAZONE_PLACE_REVERSE_URL',
    defaultValue: 'https://photon.komoot.io/reverse/',
  );

  static const String _routingBaseUrl = String.fromEnvironment(
    'METAZONE_ROUTING_BASE_URL',
    defaultValue: 'https://router.project-osrm.org',
  );

  NearbyPlace? get _selectedPlace => widget.place;

  bool get _hasExactDestination =>
      _selectedPlace?.hasExactCoordinates == true;

  /// Search near a coarse version of the visible map center, so panning to
  /// another city changes relevance without sending precise device coordinates
  /// to the public search service. Two decimal places are approximately a
  /// kilometer-scale bias, not an exact user location.
  LatLng get _searchCenter {
    final LatLng raw = _mapController?.cameraPosition?.target ?? _initialTarget;
    return LatLng(
      double.parse(raw.latitude.toStringAsFixed(2)),
      double.parse(raw.longitude.toStringAsFixed(2)),
    );
  }

  double get _searchZoom =>
      (_mapController?.cameraPosition?.zoom ?? _initialZoom)
          .clamp(5.0, 18.0)
          .toDouble();

  bool get _shouldShowPlaceLabels =>
      _searchZoom >= 14.2 && _filteredPlaces.length <= 24;

  List<NearbyPlace> _openMapSearchPlaces = const <NearbyPlace>[];
  final Map<String, List<NearbyPlace>> _openMapSearchCache =
  <String, List<NearbyPlace>>{};
  bool _searchingOpenMap = false;
  String? _openMapSearchStatus;
  int _openMapSearchRevision = 0;
  DateTime? _lastOpenMapSearchAt;

  List<NearbyPlace> get _combinedPlaces {
    final List<NearbyPlace> combined = <NearbyPlace>[...widget.places];
    for (final NearbyPlace result in _openMapSearchPlaces) {
      final bool duplicate = combined.any((NearbyPlace existing) {
        if (existing.id == result.id) return true;
        if (_normalize(existing.name) == _normalize(result.name)) {
          if (!existing.hasExactCoordinates || !result.hasExactCoordinates) {
            return true;
          }
          final double separation = Geolocator.distanceBetween(
            existing.latitude!,
            existing.longitude!,
            result.latitude!,
            result.longitude!,
          );
          return separation < 80;
        }
        return false;
      });
      if (!duplicate) combined.add(result);
    }
    return combined;
  }

  List<NearbyPlace> get _filteredPlaces {
    final String query = _normalize(_placeQuery);
    final List<NearbyPlace> unique = <NearbyPlace>[];
    final Set<String> seenIds = <String>{};

    for (final NearbyPlace place in _combinedPlaces) {
      if (!seenIds.add(place.id)) continue;
      if (query.isNotEmpty) {
        final String searchText = _normalize(<String>[
          place.name,
          place.category,
          place.address ?? '',
          place.description ?? '',
          ...place.services,
        ].join(' '));
        final bool isCurrentExternalSearchHit =
        _openMapSearchPlaces.any((NearbyPlace result) => result.id == place.id);
        if (!searchText.contains(query) && !isCurrentExternalSearchHit) continue;
      }
      if (!_matchesCategory(place, _categoryFilter)) continue;
      unique.add(place);
    }

    final LatLng? userPosition = _userPosition;
    if (userPosition != null) {
      unique.sort((NearbyPlace a, NearbyPlace b) {
        final bool aHasCoordinates = a.hasExactCoordinates;
        final bool bHasCoordinates = b.hasExactCoordinates;
        if (aHasCoordinates != bHasCoordinates) {
          return aHasCoordinates ? -1 : 1;
        }
        if (!aHasCoordinates || !bHasCoordinates) return a.name.compareTo(b.name);
        final double aMeters = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          a.latitude!,
          a.longitude!,
        );
        final double bMeters = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          b.latitude!,
          b.longitude!,
        );
        return aMeters.compareTo(bMeters);
      });
    }
    return unique;
  }

  bool _matchesCategory(NearbyPlace place, String filter) {
    if (filter == 'All') return true;
    final String category = _normalize(place.category);
    switch (filter) {
      case 'Food':
        return category.contains('food') ||
            category.contains('restaurant') ||
            category.contains('fast') ||
            category.contains('chocolate') ||
            category.contains('bakery');
      case 'Cafes':
        return category.contains('cafe') || category.contains('coffee');
      case 'Health':
        return category.contains('hospital') ||
            category.contains('clinic') ||
            category.contains('health') ||
            category.contains('pharmacy') ||
            category.contains('medical');
      case 'Education':
        return category.contains('school') ||
            category.contains('education') ||
            category.contains('university') ||
            category.contains('college');
      case 'Shopping':
        return category.contains('shop') ||
            category.contains('market') ||
            category.contains('store') ||
            category.contains('supermarket');
      case 'Hotels':
        return category.contains('hotel') ||
            category.contains('hostel') ||
            category.contains('motel') ||
            category.contains('guest house') ||
            category.contains('accommodation');
      case 'Worship':
        return category.contains('mosque') ||
            category.contains('church') ||
            category.contains('worship') ||
            category.contains('religious');
      case 'Public services':
        return category.contains('public service') ||
            category.contains('police') ||
            category.contains('government') ||
            category.contains('post office');
      case 'Transport':
        return category.contains('transport') ||
            category.contains('station') ||
            category.contains('bus') ||
            category.contains('railway') ||
            category.contains('parking') ||
            category.contains('charging');
      case 'Leisure':
        return category.contains('leisure') ||
            category.contains('park') ||
            category.contains('museum') ||
            category.contains('cinema') ||
            category.contains('sports') ||
            category.contains('playground') ||
            category.contains('attraction');
      case 'Finance':
        return category.contains('bank') ||
            category.contains('atm') ||
            category.contains('finance');
      case 'Fuel':
        return category.contains('fuel') ||
            category.contains('gas station');
      default:
        return true;
    }
  }

  void _handleSearchChanged(String value) {
    // Remote search is explicit (submit button/keyboard), never autocomplete.
    // Typing a new query invalidates an in-flight request and clears prior hits.
    _openMapSearchRevision++;
    setState(() {
      _placeQuery = value;
      _categoryFilter = 'All';
      _openMapSearchPlaces = const <NearbyPlace>[];
      _openMapSearchStatus = null;
      _searchingOpenMap = false;
      _routeSummary = null;
    });
    unawaited(_clearRouteLine());
    _scheduleAnnotationRefresh();
  }

  void _scheduleAnnotationRefresh() {
    _annotationRefreshTimer?.cancel();
    _annotationRefreshTimer = Timer(const Duration(milliseconds: 180), () {
      if (mounted) unawaited(_addKnownPlaceCircles());
    });
  }

  Future<void> _searchOpenStreetMap(
      String rawQuery, {
        String? displayQuery,
        List<String>? osmTags,
      }) async {
    final String query = rawQuery.trim();
    if (query.length < 2) {
      _showMessage('اكتب اسم مكان أو نوعه من حرفين على الأقل.');
      return;
    }
    if (_searchingOpenMap) return;

    final LatLng bias = _searchCenter;
    final double zoomBias = _searchZoom;
    // Scope cache entries by the map area. Searching "pharmacy" in Cairo
    // must not reuse results cached from New Damietta.
    final String cacheSearchKey = osmTags == null
        ? 'q:${_normalize(query)}'
        : 'tags:${osmTags.join(',')}';
    final String cacheKey = osmTags == null
        ? '$cacheSearchKey|${bias.latitude.toStringAsFixed(2)}|'
        '${bias.longitude.toStringAsFixed(2)}|${zoomBias.round()}'
        : '$cacheSearchKey|${bias.latitude.toStringAsFixed(2)}|'
        '${bias.longitude.toStringAsFixed(2)}';
    final List<NearbyPlace>? cached = _openMapSearchCache[cacheKey];
    if (cached != null) {
      setState(() {
        _placeQuery = displayQuery ?? query;
        _openMapSearchPlaces = cached;
        _searchingOpenMap = false;
        _openMapSearchStatus = cached.isEmpty
            ? (osmTags == null
            ? 'No additional OpenStreetMap places found for "$query".'
            : 'No nearby OpenStreetMap matches for this category in the cached area.')
            : 'Found ${cached.length} OpenStreetMap results near the map view.';
      });
      await _addKnownPlaceCircles();
      if (cached.isNotEmpty) await _fitVisiblePlaces();
      return;
    }

    final int requestRevision = ++_openMapSearchRevision;
    setState(() {
      _placeQuery = displayQuery ?? query;
      _searchingOpenMap = true;
      _openMapSearchStatus = 'Searching OpenStreetMap…';
      _openMapSearchPlaces = const <NearbyPlace>[];
      _routeSummary = null;
    });
    unawaited(_clearRouteLine());
    unawaited(_addKnownPlaceCircles());

    final DateTime now = DateTime.now();
    final DateTime? lastSearch = _lastOpenMapSearchAt;
    if (lastSearch != null && now.difference(lastSearch) < const Duration(seconds: 1)) {
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    if (requestRevision != _openMapSearchRevision || !mounted) return;
    _lastOpenMapSearchAt = DateTime.now();

    Dio? client;
    try {
      // Use the coarse-rounded current map center as the search relevance
      // bias. Precise device coordinates remain local for distance calculation.
      client = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          listFormat: ListFormat.multi,
          headers: const <String, String>{
            'Accept': 'application/geo+json, application/json',
            'User-Agent': 'MetaZone/1.0 (OpenStreetMap place search)',
          },
        ),
      );
      final Map<String, dynamic> parameters = <String, dynamic>{
        'lat': bias.latitude,
        'lon': bias.longitude,
        'limit': 20,
        'lang': RegExp(r'[\u0600-\u06FF]').hasMatch(query) ? 'ar' : 'en',
      };
      final String endpoint;
      if (osmTags == null) {
        endpoint = _placeSearchUrl;
        parameters.addAll(<String, dynamic>{
          'q': query,
          // The map zoom is used only for cache separation. Photon’s public
          // API does not accept a `zoom` query parameter; keep relevance bias
          // via the coarse map center and supported location_bias_scale.
          'location_bias_scale': 0.15,
        });
      } else {
        // Photon supports tag-filtered reverse lookups (e.g. nearby pharmacies)
        // so category chips discover real OSM POIs rather than only filtering
        // the small locally curated MetaZone directory.
        endpoint = _placeReverseUrl;
        parameters.addAll(<String, dynamic>{
          // Dio's default ListFormat.multi encodes this as repeated osm_tag
          // parameters, which Photon explicitly supports.
          'osm_tag': osmTags,
          'radius': 15,
        });
      }
      final Response<dynamic> response = await client.get<dynamic>(
        endpoint,
        queryParameters: parameters,
      );

      if (requestRevision != _openMapSearchRevision || !mounted) return;
      final dynamic payload = response.data;
      if (payload is! Map || payload['features'] is! List) {
        throw const FormatException('OpenStreetMap search returned an invalid response.');
      }

      final List<NearbyPlace> results = <NearbyPlace>[];
      final Set<String> seenIds = <String>{};
      for (final dynamic feature in payload['features'] as List<dynamic>) {
        final NearbyPlace? place = _placeFromPhotonFeature(feature);
        if (place == null || !seenIds.add(place.id)) continue;
        results.add(place);
      }
      final List<NearbyPlace> immutableResults =
      List<NearbyPlace>.unmodifiable(results);
      _openMapSearchCache[cacheKey] = immutableResults;
      if (_openMapSearchCache.length > 25) {
        _openMapSearchCache.remove(_openMapSearchCache.keys.first);
      }

      if (requestRevision != _openMapSearchRevision || !mounted) return;
      setState(() {
        _openMapSearchPlaces = immutableResults;
        _openMapSearchStatus = immutableResults.isEmpty
            ? (osmTags == null
            ? 'No OpenStreetMap results found. Try another name or category.'
            : 'No nearby matches in OpenStreetMap for this category. Try moving the map or another category.')
            : 'Found ${immutableResults.length} OpenStreetMap results near the map view. Details may need verification.';
      });
      await _addKnownPlaceCircles();
      if (immutableResults.isNotEmpty) await _fitVisiblePlaces();
    } catch (error) {
      if (error is DioException) {
        debugPrint(
          'MetaZone Photon request failed: '
              'status=${error.response?.statusCode}; '
              'uri=${error.requestOptions.uri}; '
              'body=${error.response?.data}',
        );
      } else {
        debugPrint('MetaZone OpenStreetMap place search failed: $error');
      }
      if (requestRevision == _openMapSearchRevision && mounted) {
        final int? statusCode = error is DioException
            ? error.response?.statusCode
            : null;
        setState(() {
          _openMapSearchPlaces = const <NearbyPlace>[];
          _openMapSearchStatus = statusCode == 400
              ? 'The public search rejected this request. Try another name or category.'
              : 'Open map search is unavailable right now. The local directory still works.';
        });
      }
    } finally {
      client?.close(force: true);
      if (requestRevision == _openMapSearchRevision && mounted) {
        setState(() => _searchingOpenMap = false);
        await _addKnownPlaceCircles();
      }
    }
  }

  NearbyPlace? _placeFromPhotonFeature(dynamic feature) {
    if (feature is! Map) return null;
    final dynamic rawProperties = feature['properties'];
    final dynamic rawGeometry = feature['geometry'];
    if (rawProperties is! Map || rawGeometry is! Map) return null;
    final Map<String, dynamic> properties =
    Map<String, dynamic>.from(rawProperties);
    final dynamic rawCoordinates = rawGeometry['coordinates'];
    if (rawCoordinates is! List ||
        rawCoordinates.length < 2 ||
        rawCoordinates[0] is! num ||
        rawCoordinates[1] is! num) {
      return null;
    }

    final double longitude = (rawCoordinates[0] as num).toDouble();
    final double latitude = (rawCoordinates[1] as num).toDouble();
    if (!latitude.isFinite || !longitude.isFinite ||
        latitude < -90 || latitude > 90 ||
        longitude < -180 || longitude > 180) {
      return null;
    }

    final String osmId = (properties['osm_id'] ?? '').toString().trim();
    final String osmType = (properties['osm_type'] ?? '').toString().trim().toUpperCase();
    final String? elementType = switch (osmType) {
      'N' || 'NODE' => 'node',
      'W' || 'WAY' => 'way',
      'R' || 'RELATION' => 'relation',
      _ => null,
    };
    if (osmId.isEmpty || elementType == null) return null;

    final String name = _firstPropertyText(properties, const <String>[
      'name', 'street', 'locality', 'district',
    ]);
    if (name.isEmpty) return null;

    final List<String> addressParts = <String>[];
    final String street = (properties['street'] ?? '').toString().trim();
    final String houseNumber = (properties['housenumber'] ?? '').toString().trim();
    final String streetLabel = <String>[street, houseNumber]
        .where((String part) => part.isNotEmpty)
        .join(' ');
    if (streetLabel.isNotEmpty && _normalize(streetLabel) != _normalize(name)) {
      addressParts.add(streetLabel);
    }
    for (final String key in const <String>['district', 'city', 'state', 'country']) {
      final String part = (properties[key] ?? '').toString().trim();
      if (part.isNotEmpty &&
          !addressParts.any((String existing) => _normalize(existing) == _normalize(part))) {
        addressParts.add(part);
      }
    }

    final String category = _categoryFromPhoton(properties);
    final String osmKey = (properties['osm_key'] ?? '').toString().trim();
    final String osmValue = (properties['osm_value'] ?? '').toString().trim();
    final String osmTagLabel = osmKey.isNotEmpty || osmValue.isNotEmpty
        ? ' ($osmKey=$osmValue)'
        : '';
    return NearbyPlace(
      id: 'osm_${elementType}_$osmId',
      name: name,
      category: category,
      imageUrl: '',
      rating: 0,
      reviewCount: 0,
      distance: 'Enable location',
      isOpen: false,
      zoneStatus: 'OpenStreetMap result',
      latitude: latitude,
      longitude: longitude,
      coordinatesVerified: true,
      address: addressParts.isEmpty ? null : addressParts.join(', '),
      description: 'Search result from public OpenStreetMap-derived data. '
          'MetaZone has not field-verified this place, its contact details, '
          'photos, services, or opening hours. OSM feature: '
          '$osmType/$osmId$osmTagLabel.',
      phone: _optionalPropertyText(properties, const <String>['phone']),
      websiteUrl: _optionalPropertyText(properties, const <String>['website', 'url']),
      isVerified: false,
      ratingVerified: false,
      openingStatusVerified: false,
      dataSourceLabel: 'OpenStreetMap contributors · Photon',
      locationSourceUrl: 'https://www.openstreetmap.org/$elementType/$osmId',
      lastVerifiedAt: null,
    );
  }

  static String _firstPropertyText(Map<String, dynamic> properties, List<String> keys) {
    for (final String key in keys) {
      final String value = (properties[key] ?? '').toString().trim();
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  static String? _optionalPropertyText(Map<String, dynamic> properties, List<String> keys) {
    final String value = _firstPropertyText(properties, keys);
    return value.isEmpty ? null : value;
  }

  static String _categoryFromPhoton(Map<String, dynamic> properties) {
    final String key = (properties['osm_key'] ?? '').toString().toLowerCase();
    final String value = (properties['osm_value'] ?? '').toString().toLowerCase();
    if (key == 'shop') {
      if (value == 'supermarket') return 'Supermarket';
      if (value == 'bakery') return 'Bakery';
      if (value == 'convenience') return 'Convenience Store';
      return 'Shop';
    }
    switch (value) {
      case 'hospital':
        return 'Hospital';
      case 'clinic':
      case 'doctors':
      case 'healthcare':
        return 'Healthcare';
      case 'pharmacy':
        return 'Pharmacy';
      case 'restaurant':
      case 'food_court':
        return 'Restaurant';
      case 'fast_food':
        return 'Fast Food';
      case 'cafe':
      case 'coffee_shop':
        return 'Cafe';
      case 'school':
      case 'university':
      case 'college':
      case 'kindergarten':
      case 'library':
        return 'Education';
      case 'hotel':
      case 'hostel':
      case 'motel':
      case 'guest_house':
        return 'Accommodation';
      case 'bus_station':
      case 'bus_stop':
      case 'railway_station':
      case 'parking':
        return 'Transport';
      case 'park':
      case 'museum':
      case 'cinema':
      case 'playground':
        return 'Leisure';
      case 'bank':
      case 'atm':
        return 'Finance';
      case 'fuel':
        return 'Fuel';
      case 'mosque':
      case 'place_of_worship':
        return 'Worship';
      case 'police':
      case 'post_office':
      case 'townhall':
      case 'government':
        return 'Public Service';
    }
    final String fallback = value.isNotEmpty
        ? value
        : (properties['type'] ?? 'Place').toString();
    return fallback
        .replaceAll('_', ' ')
        .split(' ')
        .where((String part) => part.isNotEmpty)
        .map((String part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  List<String>? _photonTagsForCategory(String category) {
    switch (category) {
      case 'Food':
        return const <String>[
          'amenity:restaurant',
          'amenity:fast_food',
          'shop:bakery',
        ];
      case 'Cafes':
        return const <String>['amenity:cafe'];
      case 'Health':
        return const <String>[
          'amenity:pharmacy',
          'amenity:hospital',
          'amenity:clinic',
          'amenity:doctors',
        ];
      case 'Education':
        return const <String>[
          'amenity:school',
          'amenity:university',
          'amenity:college',
          'amenity:kindergarten',
        ];
      case 'Shopping':
        return const <String>[
          'shop:supermarket',
          'shop:convenience',
          'shop:department_store',
        ];
      case 'Hotels':
        return const <String>[
          'tourism:hotel',
          'tourism:hostel',
          'tourism:guest_house',
          'tourism:motel',
        ];
      case 'Worship':
        return const <String>['amenity:place_of_worship'];
      case 'Public services':
        return const <String>[
          'amenity:police',
          'amenity:post_office',
          'amenity:townhall',
          'office:government',
        ];
      case 'Transport':
        return const <String>[
          'highway:bus_stop',
          'amenity:bus_station',
          'railway:station',
          'amenity:parking',
        ];
      case 'Leisure':
        return const <String>[
          'leisure:park',
          'tourism:museum',
          'amenity:cinema',
          'leisure:playground',
        ];
      case 'Finance':
        return const <String>['amenity:bank', 'amenity:atm'];
      case 'Fuel':
        return const <String>['amenity:fuel'];
      default:
        return null;
    }
  }

  void _setCategoryFilter(String value) {
    FocusScope.of(context).unfocus();
    if (_categoryFilter == value) return;
    // Invalidate any search currently in flight before starting a category
    // lookup. A deliberate tap causes at most one new public-search request.
    _openMapSearchRevision++;
    setState(() {
      _categoryFilter = value;
      _placeQuery = '';
      _searchingOpenMap = false;
      _routeSummary = null;
      if (value == 'All') {
        _openMapSearchStatus = null;
      } else {
        _openMapSearchPlaces = const <NearbyPlace>[];
        _openMapSearchStatus = null;
      }
    });
    unawaited(_clearRouteLine());
    unawaited(_addKnownPlaceCircles());

    final List<String>? osmTags = _photonTagsForCategory(value);
    if (osmTags != null) {
      // Use the map's coarse visible center (not raw device GPS) for the
      // category lookup. Photon supports multiple OSM tags in one request.
      unawaited(
        _searchOpenStreetMap(value, displayQuery: '', osmTags: osmTags),
      );
    }
  }

  void _handleCircleTapped(Circle circle) {
    _handlePlaceAnnotationTap(circle.data?['zoneId']);
  }

  void _handleSymbolTapped(Symbol symbol) {
    _handlePlaceAnnotationTap(symbol.data?['zoneId']);
  }

  void _handlePlaceAnnotationTap(dynamic rawId) {
    if (rawId is! String || rawId.isEmpty) return;

    final List<NearbyPlace> candidates = <NearbyPlace>[
      if (widget.place != null) widget.place!,
      ...widget.places,
      ..._openMapSearchPlaces,
    ];
    NearbyPlace? tappedPlace;
    for (final NearbyPlace candidate in candidates) {
      if (candidate.id == rawId) {
        tappedPlace = candidate;
        break;
      }
    }
    if (tappedPlace == null) return;

    final NearbyPlace selected = _placeWithCurrentDistance(tappedPlace);
    final ValueChanged<NearbyPlace>? callback = widget.onPlaceSelected;
    if (callback != null) {
      callback(selected);
      return;
    }

    // On a single-Zone map page, keep the user inside MetaZone and recenter.
    _showMessage(tappedPlace.name);
    unawaited(_centerOnPlace(tappedPlace));
  }

  Future<void> _fitVisiblePlaces() async {
    final List<NearbyPlace> places = _filteredPlaces
        .where((NearbyPlace place) => place.hasExactCoordinates)
        .toList(growable: false);
    if (places.isEmpty) {
      _showMessage('مفيش أماكن بإحداثيات متاحة في نتائج البحث الحالية.');
      return;
    }
    if (places.length == 1) {
      await _centerOnPlace(places.first);
      return;
    }

    final double minLat = places
        .map((NearbyPlace place) => place.latitude!)
        .reduce((double a, double b) => a < b ? a : b);
    final double maxLat = places
        .map((NearbyPlace place) => place.latitude!)
        .reduce((double a, double b) => a > b ? a : b);
    final double minLon = places
        .map((NearbyPlace place) => place.longitude!)
        .reduce((double a, double b) => a < b ? a : b);
    final double maxLon = places
        .map((NearbyPlace place) => place.longitude!)
        .reduce((double a, double b) => a > b ? a : b);

    // Some search providers can return multiple features at the same point.
    // Avoid zero-area bounds, which are not useful for camera fitting.
    if ((maxLat - minLat).abs() < 0.0001 &&
        (maxLon - minLon).abs() < 0.0001) {
      await _centerOnPlace(places.first);
      return;
    }

    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLon),
          northeast: LatLng(maxLat, maxLon),
        ),
        left: 28,
        top: 205,
        right: 86,
        bottom: 310,
      ),
    );
  }

  /// Straight-line distance to a sourced map pin, not driving distance.
  String? _distanceLabelFor(NearbyPlace place) {
    final LatLng? origin = _userPosition;
    if (origin == null || !place.hasExactCoordinates) return null;

    final double meters = Geolocator.distanceBetween(
      origin.latitude,
      origin.longitude,
      place.latitude!,
      place.longitude!,
    );
    if (!meters.isFinite) return null;
    if (meters < 1000) return '≈ ${meters.round()} m';
    return '≈ ${(meters / 1000).toStringAsFixed(1)} km';
  }

  NearbyPlace _placeWithCurrentDistance(NearbyPlace place) {
    return place.withDistance(_distanceLabelFor(place) ?? 'Enable location');
  }

  LatLng get _initialTarget {
    final NearbyPlace? place = _selectedPlace;
    if (place != null && place.hasExactCoordinates) {
      return LatLng(place.latitude!, place.longitude!);
    }
    return _approximateCenter(widget.locationName);
  }

  double get _initialZoom {
    if (_hasExactDestination) return 16.0;
    if (_isNewDamietta(widget.locationName)) return 13.0;
    if (_isKnownArea(widget.locationName)) return 10.5;
    return 5.2;
  }

  static bool _isNewDamietta(String value) {
    final String normalized = _normalize(value);
    return normalized.contains('new damietta') || normalized.contains('دمياط الجديدة');
  }

  @override
  void dispose() {
    _annotationRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MetaZoneMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.place?.id != widget.place?.id ||
        oldWidget.places != widget.places) {
      _routeSummary = null;
      if (_styleLoaded) {
        unawaited(_addKnownPlaceCircles());
        unawaited(_clearRouteLine());
      }
    }
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
    // Both the marker and its label can be tapped to open the same Zone.
    controller.onCircleTapped.add(_handleCircleTapped);
    controller.onSymbolTapped.add(_handleSymbolTapped);
  }

  Future<void> _onStyleLoaded() async {
    _styleLoaded = true;
    await _addKnownPlaceCircles();
  }

  void _onMapCameraIdle() {
    if (!_styleLoaded || !mounted) return;
    final bool labelsShouldBeVisible = _shouldShowPlaceLabels;
    if (_lastRenderedPlaceLabelsVisible != labelsShouldBeVisible) {
      unawaited(_addKnownPlaceCircles());
    }
  }

  String _shortMapLabel(String value) {
    final String name = value.trim();
    if (name.length <= 26) return name;
    return '${name.substring(0, 23).trimRight()}…';
  }

  Future<void> _addKnownPlaceCircles() async {
    final MapLibreMapController? controller = _mapController;
    if (controller == null || !_styleLoaded || !mounted) return;
    final int revision = ++_annotationRevision;
    final bool showLabels = _shouldShowPlaceLabels;
    _lastRenderedPlaceLabelsVisible = showLabels;

    try {
      await controller.clearCircles();
      await controller.clearSymbols();
      if (revision != _annotationRevision || !mounted) return;

      final List<NearbyPlace> candidates = <NearbyPlace>[
        if (widget.place != null) widget.place!,
        ..._filteredPlaces,
      ];
      final Set<String> seenIds = <String>{};
      final List<CircleOptions> circleOptions = <CircleOptions>[];
      final List<Map<String, dynamic>> circleData = <Map<String, dynamic>>[];
      final List<SymbolOptions> symbolOptions = <SymbolOptions>[];
      final List<Map<String, dynamic>> symbolData = <Map<String, dynamic>>[];

      for (final NearbyPlace place in candidates) {
        if (revision != _annotationRevision || !mounted) return;
        if (!place.hasExactCoordinates || !seenIds.add(place.id)) continue;

        final bool isSelected = place.id == widget.place?.id;
        final LatLng geometry = LatLng(place.latitude!, place.longitude!);
        circleOptions.add(
          CircleOptions(
            geometry: geometry,
            circleRadius: isSelected ? 12 : 9,
            circleColor: isSelected ? '#9D7BFF' : '#55D6D0',
            circleOpacity: 0.98,
            circleStrokeColor: '#FFFFFF',
            circleStrokeWidth: isSelected ? 3 : 2,
            circleStrokeOpacity: 0.98,
          ),
        );
        circleData.add(<String, dynamic>{
          'zoneId': place.id,
          'zoneName': place.name,
          'category': place.category,
        });

        if (showLabels) {
          symbolOptions.add(
            SymbolOptions(
              geometry: geometry,
              textField: _shortMapLabel(place.name),
              textSize: isSelected ? 12 : 10,
              textColor: '#FFFFFF',
              textHaloColor: '#101828',
              textHaloWidth: 1.5,
              textHaloBlur: 0.2,
              textAnchor: 'top',
              textOffset: const Offset(0, 0.9),
              textMaxWidth: 12,
              zIndex: isSelected ? 100 : 10,
            ),
          );
          symbolData.add(<String, dynamic>{
            'zoneId': place.id,
            'zoneName': place.name,
            'category': place.category,
          });
        }
      }

      if (revision != _annotationRevision || !mounted) return;
      if (circleOptions.isNotEmpty) {
        await controller.addCircles(circleOptions, circleData);
      }
      if (revision != _annotationRevision || !mounted) return;
      if (symbolOptions.isNotEmpty) {
        await controller.addSymbols(symbolOptions, symbolData);
      }

      if (revision != _annotationRevision || !mounted) return;
      final LatLng? userPosition = _userPosition;
      if (userPosition != null) {
        await controller.addCircle(
          CircleOptions(
            geometry: userPosition,
            circleRadius: 7,
            circleColor: '#51B9FF',
            circleOpacity: 1,
            circleStrokeColor: '#FFFFFF',
            circleStrokeWidth: 2,
            circleStrokeOpacity: 1,
          ),
          const <String, dynamic>{'kind': 'user'},
        );
      }
    } catch (error) {
      debugPrint('MetaZone map annotation update failed: $error');
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);

    try {
      final LatLng? target = await _requestCurrentLatLng();
      if (target == null || !mounted) return;

      setState(() => _userPosition = target);
      final MapLibreMapController? controller = _mapController;
      if (controller != null) {
        await controller.animateCamera(CameraUpdate.newLatLngZoom(target, 15.5));
        await _addKnownPlaceCircles();
      }
    } catch (error) {
      debugPrint('MetaZone current-location map request failed: $error');
      if (mounted) _showMessage('مش قادرين نحدد موقعك دلوقتي. جرّب تاني.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<LatLng?> _requestCurrentLatLng() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage('فعّل خدمة الموقع علشان نحدد نقطة البداية.');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showMessage('اسمح لـ MetaZone باستخدام الموقع علشان نحسب الطريق.');
      return null;
    }

    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    return LatLng(position.latitude, position.longitude);
  }

  Future<void> _clearRouteLine() async {
    try {
      await _mapController?.clearLines();
    } catch (error) {
      debugPrint('MetaZone route-line clear failed: $error');
    }
  }

  /// Draws a real road route from the device's current position to a Zone.
  /// The routing endpoint is configurable. The public OSRM endpoint is only a
  /// development fallback; production must use an owned/licensed service.
  Future<void> _buildRoute() async {
    final NearbyPlace? place = _selectedPlace;
    final MapLibreMapController? controller = _mapController;

    if (place == null || !place.hasExactCoordinates || controller == null) {
      _showMessage('المكان محتاج إحداثيات من مصدر خرائط قبل رسم الطريق.');
      return;
    }
    if (_routing) return;

    setState(() {
      _routing = true;
      _routeSummary = null;
    });

    Dio? routeClient;
    try {
      final LatLng? origin = await _requestCurrentLatLng();
      if (origin == null || !mounted) return;

      setState(() => _userPosition = origin);
      await _addKnownPlaceCircles();

      final String coordinates =
          '${origin.longitude},${origin.latitude};'
          '${place.longitude},${place.latitude}';
      routeClient = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 18),
          headers: const <String, String>{
            'Accept': 'application/json',
            'User-Agent': 'MetaZone/1.0 (in-app routing)',
          },
        ),
      );
      final Response<dynamic> response = await routeClient.get<dynamic>(
        '$_routingBaseUrl/route/v1/driving/$coordinates',
        queryParameters: const <String, dynamic>{
          'overview': 'full',
          'geometries': 'geojson',
          'steps': false,
          'alternatives': false,
        },
      );

      final dynamic payload = response.data;
      if (payload is! Map) throw StateError('Invalid route response.');
      if (payload['code'] != 'Ok') {
        throw StateError('No drivable route was found for this Zone.');
      }

      final dynamic rawRoutes = payload['routes'];
      if (rawRoutes is! List || rawRoutes.isEmpty || rawRoutes.first is! Map) {
        throw StateError('No route was returned.');
      }
      final Map<String, dynamic> firstRoute =
      Map<String, dynamic>.from(rawRoutes.first as Map);
      final dynamic rawGeometry = firstRoute['geometry'];
      if (rawGeometry is! Map || rawGeometry['coordinates'] is! List) {
        throw StateError('Route geometry is missing.');
      }

      final List<dynamic> rawCoordinates = rawGeometry['coordinates'] as List<dynamic>;
      final List<LatLng> routePoints = rawCoordinates
          .whereType<List<dynamic>>()
          .where((List<dynamic> pair) => pair.length >= 2 && pair[0] is num && pair[1] is num)
          .map((List<dynamic> pair) => LatLng(
        (pair[1] as num).toDouble(),
        (pair[0] as num).toDouble(),
      ))
          .toList(growable: false);
      if (routePoints.length < 2) throw StateError('Route geometry is incomplete.');

      await controller.clearLines();
      await controller.addLine(
        LineOptions(
          geometry: routePoints,
          lineColor: '#9D7BFF',
          lineWidth: 5,
          lineOpacity: 0.95,
          lineJoin: 'round',
        ),
      );

      final double distanceMeters = (firstRoute['distance'] as num?)?.toDouble() ?? 0;
      final double durationSeconds = (firstRoute['duration'] as num?)?.toDouble() ?? 0;
      final String distanceLabel = distanceMeters >= 1000
          ? '${(distanceMeters / 1000).toStringAsFixed(1)} km'
          : '${distanceMeters.round()} m';
      final int minutes = (durationSeconds / 60).round();
      final String durationLabel = minutes >= 60
          ? '${minutes ~/ 60} h ${minutes % 60} min'
          : '$minutes min';

      final double minLat = routePoints.map((LatLng point) => point.latitude).reduce((a, b) => a < b ? a : b);
      final double maxLat = routePoints.map((LatLng point) => point.latitude).reduce((a, b) => a > b ? a : b);
      final double minLon = routePoints.map((LatLng point) => point.longitude).reduce((a, b) => a < b ? a : b);
      final double maxLon = routePoints.map((LatLng point) => point.longitude).reduce((a, b) => a > b ? a : b);

      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLon),
            northeast: LatLng(maxLat, maxLon),
          ),
          left: 34,
          top: 120,
          right: 34,
          bottom: 300,
        ),
      );

      if (!mounted) return;
      setState(() {
        _routeSummary = '$distanceLabel · $durationLabel by car';
      });
    } catch (error) {
      debugPrint('MetaZone in-app routing failed: $error');
      if (mounted) {
        _showMessage(
          'مش قادرين نحسب الطريق دلوقتي. اتأكد من الإنترنت ودقة موقع المكان.',
        );
      }
    } finally {
      routeClient?.close(force: true);
      if (mounted) setState(() => _routing = false);
    }
  }

  Future<void> _zoomIn() async {
    await _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    await _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  Future<void> _recenterOnZone() async {
    final NearbyPlace? place = _selectedPlace;
    if (place == null) return;
    await _centerOnPlace(place);
  }

  Future<void> _centerOnPlace(NearbyPlace place) async {
    if (!place.hasExactCoordinates) {
      _showMessage('المكان لسه محتاج إحداثيات دقيقة موثّقة في MetaZone.');
      return;
    }

    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(place.latitude!, place.longitude!),
        16,
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  static bool _isKnownArea(String value) {
    final String normalized = _normalize(value);
    return _areaCoordinates.keys.any((String key) => normalized.contains(key));
  }

  static LatLng _approximateCenter(String locationName) {
    final String normalized = _normalize(locationName);
    final List<String> keys = _areaCoordinates.keys.toList()
      ..sort((String a, String b) => b.length.compareTo(a.length));
    for (final String key in keys) {
      if (normalized.contains(key)) return _areaCoordinates[key]!;
    }
    return const LatLng(26.8206, 30.8025); // Egypt overview only.
  }

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ى', 'ي');

  static const Map<String, LatLng> _areaCoordinates = <String, LatLng>{
    // Approximate overview center for this current New Damietta seed directory.
    'new damietta': LatLng(31.4401, 31.6838),
    'new damietta, damietta': LatLng(31.4401, 31.6838),
    'دمياط الجديدة': LatLng(31.4401, 31.6838),
    'damietta': LatLng(31.4165, 31.8133),
    'دمياط': LatLng(31.4165, 31.8133),
    'cairo': LatLng(30.0444, 31.2357),
    'القاهرة': LatLng(30.0444, 31.2357),
    'giza': LatLng(29.9870, 31.2118),
    'الجيزة': LatLng(29.9870, 31.2118),
    'alexandria': LatLng(31.2001, 29.9187),
    'الاسكندرية': LatLng(31.2001, 29.9187),
    'port said': LatLng(31.2653, 32.3019),
    'بورسعيد': LatLng(31.2653, 32.3019),
    'suez': LatLng(29.9668, 32.5498),
    'السويس': LatLng(29.9668, 32.5498),
    'mansoura': LatLng(31.0409, 31.3785),
    'المنصورة': LatLng(31.0409, 31.3785),
    'tanta': LatLng(30.7865, 31.0004),
    'طنطا': LatLng(30.7865, 31.0004),
    'luxor': LatLng(25.6872, 32.6396),
    'الاقصر': LatLng(25.6872, 32.6396),
    'aswan': LatLng(24.0889, 32.8998),
    'اسوان': LatLng(24.0889, 32.8998),
  };

  @override
  Widget build(BuildContext context) {
    final NearbyPlace? place = _selectedPlace;
    final bool keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          MapLibreMap(
            styleString: MetaZoneMapScreen.defaultStyleUrl,
            initialCameraPosition: CameraPosition(
              target: _initialTarget,
              zoom: _initialZoom,
            ),
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoaded,
            onCameraIdle: _onMapCameraIdle,
            annotationOrder: const <AnnotationType>[
              AnnotationType.line,
              AnnotationType.circle,
              AnnotationType.symbol,
              AnnotationType.fill,
            ],
            compassEnabled: false,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            trackCameraPosition: true,
            myLocationEnabled: false,
            myLocationTrackingMode: MyLocationTrackingMode.none,
          ),
          SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: _MapTopBar(
                    title: place == null ? 'MetaZone Map' : 'Zone map',
                    subtitle: place == null
                        ? 'Explore the real world'
                        : place.name,
                    onBack: () => Navigator.maybePop(context),
                  ),
                ),
                if (place == null) ...<Widget>[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _MapSearchField(
                      query: _placeQuery,
                      onChanged: _handleSearchChanged,
                      onSubmitted: (String value) {
                        FocusScope.of(context).unfocus();
                        unawaited(_searchOpenStreetMap(value));
                      },
                      busy: _searchingOpenMap,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _mapCategoryFilters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 7),
                      itemBuilder: (BuildContext context, int index) {
                        final String filter = _mapCategoryFilters[index];
                        final bool selected = _categoryFilter == filter;
                        return ChoiceChip(
                          label: Text(filter),
                          selected: selected,
                          onSelected: (_) => _setCategoryFilter(filter),
                          showCheckmark: false,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          side: BorderSide(
                            color: selected
                                ? const Color(0xFFBCA4FF)
                                : Colors.white.withValues(alpha: 0.13),
                          ),
                          backgroundColor: const Color(0xF20B1120),
                          selectedColor: const Color(0xFF6346B8),
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                ],
                if (!keyboardVisible) const Spacer(),
                if (!keyboardVisible) Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16, bottom: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (place == null) ...<Widget>[
                          _MapControl(
                            icon: Icons.zoom_out_map_rounded,
                            tooltip: 'Show all matching places',
                            onTap: _fitVisiblePlaces,
                          ),
                          const SizedBox(height: 8),
                        ],
                        _MapControl(
                          icon: Icons.add_rounded,
                          tooltip: 'Zoom in',
                          onTap: _zoomIn,
                        ),
                        const SizedBox(height: 8),
                        _MapControl(
                          icon: Icons.remove_rounded,
                          tooltip: 'Zoom out',
                          onTap: _zoomOut,
                        ),
                        const SizedBox(height: 8),
                        _MapControl(
                          icon: _locating
                              ? Icons.location_searching_rounded
                              : Icons.my_location_rounded,
                          tooltip: 'My location',
                          onTap: _goToCurrentLocation,
                          busy: _locating,
                        ),
                        if (place != null && place.hasExactCoordinates) ...<Widget>[
                          const SizedBox(height: 8),
                          _MapControl(
                            icon: Icons.place_rounded,
                            tooltip: 'Center on Zone',
                            onTap: _recenterOnZone,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (!keyboardVisible && place != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                    child: _ZoneMapCard(
                      place: place,
                      locationName: widget.locationName,
                      hasExactCoordinates: place.hasExactCoordinates,
                      onCenter: _recenterOnZone,
                      onRoute: _buildRoute,
                      isRouting: _routing,
                      routeSummary: _routeSummary,
                    ),
                  )
                else if (!keyboardVisible)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                    child: _MapBrowseCard(
                      places: _filteredPlaces,
                      query: _placeQuery,
                      distanceForPlace: _distanceLabelFor,
                      onPlaceTap: (NearbyPlace selected) {
                        final ValueChanged<NearbyPlace>? callback = widget.onPlaceSelected;
                        if (callback != null) {
                          callback(_placeWithCurrentDistance(selected));
                        } else {
                          _showMessage('افتح Zone من نتائج البحث أو من صفحة المكان.');
                        }
                      },
                      onCenter: _centerOnPlace,
                      searchStatus: _openMapSearchStatus,
                      searchingOpenMap: _searchingOpenMap,
                    ),
                  ),
                if (!keyboardVisible)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                    child: const _AttributionPill(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapTopBar extends StatelessWidget {
  const _MapTopBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xF20B1120),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.11)),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x25000000), blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Back',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFFBCA4FF), Color(0xFF8050F6)],
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.explore_rounded, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFB0B8CC), fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControl extends StatelessWidget {
  const _MapControl({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.busy = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xF20B1120),
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: busy ? null : onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: busy
                ? const Padding(
              padding: EdgeInsets.all(13),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Icon(icon, color: Colors.white, size: 21),
          ),
        ),
      ),
    );
  }
}

class _MapSearchField extends StatefulWidget {
  const _MapSearchField({
    required this.query,
    required this.onChanged,
    required this.onSubmitted,
    required this.busy,
  });

  final String query;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final bool busy;

  @override
  State<_MapSearchField> createState() => _MapSearchFieldState();
}

class _MapSearchFieldState extends State<_MapSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant _MapSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query && _controller.text != widget.query) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xF20B1120),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x24000000), blurRadius: 18, offset: Offset(0, 7)),
        ],
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.search_rounded, color: Color(0xFFBCA4FF), size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              cursorColor: const Color(0xFFBCA4FF),
              textInputAction: TextInputAction.search,
              onSubmitted: widget.onSubmitted,
              decoration: const InputDecoration(
                hintText: 'Search any place near this map view',
                hintStyle: TextStyle(color: Color(0xFF8993AA), fontSize: 12),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Search OpenStreetMap',
            visualDensity: VisualDensity.compact,
            onPressed: widget.busy ? null : () => widget.onSubmitted(_controller.text),
            icon: widget.busy
                ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.travel_explore_rounded, color: Color(0xFF62DDB0), size: 19),
          ),
          if (widget.query.isNotEmpty)
            IconButton(
              tooltip: 'Clear search',
              visualDensity: VisualDensity.compact,
              onPressed: () {
                _controller.clear();
                widget.onChanged('');
              },
              icon: const Icon(Icons.close_rounded, color: Color(0xFFB0B8CC), size: 18),
            ),
        ],
      ),
    );
  }
}

class _MapPlacePlaceholder extends StatelessWidget {
  const _MapPlacePlaceholder({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final String value = category.toLowerCase();
    final IconData icon = value.contains('hospital') || value.contains('health')
        ? Icons.local_hospital_rounded
        : value.contains('school') || value.contains('education')
        ? Icons.school_rounded
        : value.contains('cafe')
        ? Icons.local_cafe_rounded
        : value.contains('food') || value.contains('restaurant') || value.contains('fast')
        ? Icons.restaurant_rounded
        : value.contains('shop') || value.contains('market') || value.contains('supermarket')
        ? Icons.storefront_rounded
        : value.contains('mosque') || value.contains('worship')
        ? Icons.mosque
        : value.contains('police') || value.contains('public service')
        ? Icons.local_police_rounded
        : Icons.place_rounded;
    return ColoredBox(
      color: const Color(0xFF252C41),
      child: Center(
        child: Icon(icon, color: const Color(0xFFBCA4FF), size: 23),
      ),
    );
  }
}

class _MapBrowseCard extends StatelessWidget {
  const _MapBrowseCard({
    required this.places,
    required this.query,
    required this.distanceForPlace,
    required this.onPlaceTap,
    required this.onCenter,
    required this.searchStatus,
    required this.searchingOpenMap,
  });

  final List<NearbyPlace> places;
  final String query;
  final String? Function(NearbyPlace) distanceForPlace;
  final ValueChanged<NearbyPlace> onPlaceTap;
  final ValueChanged<NearbyPlace> onCenter;
  final String? searchStatus;
  final bool searchingOpenMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 13, 13, 12),
      decoration: BoxDecoration(
        color: const Color(0xF20B1120),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Places & MetaZone Zones',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${places.length} places',
                style: const TextStyle(color: Color(0xFFB0B8CC), fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'Local MetaZone entries plus nearby OpenStreetMap results. Public coverage may be incomplete; external venue details are not field-verified.',
            maxLines: 2,
            style: TextStyle(color: Color(0xFF9EA8BD), fontSize: 9.5, height: 1.35),
          ),
          if (searchStatus != null) ...<Widget>[
            const SizedBox(height: 7),
            Text(
              searchStatus!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: searchingOpenMap ? const Color(0xFF62DDB0) : const Color(0xFFB0B8CC),
                fontSize: 9.5,
                height: 1.3,
              ),
            ),
          ],
          const SizedBox(height: 10),
          if (places.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text(
                  query.trim().isEmpty
                      ? 'No local places match yet. Search a place name or choose a category above.'
                      : 'No local places match "$query". Tap the map-search icon to search OpenStreetMap.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFB0B8CC), fontSize: 11),
                ),
              ),
            )
          else
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: places.length,
                separatorBuilder: (_, __) => const SizedBox(width: 9),
                itemBuilder: (BuildContext context, int index) {
                  final NearbyPlace place = places[index];
                  final bool exact = place.hasExactCoordinates;
                  final String? distanceLabel = distanceForPlace(place);
                  return SizedBox(
                    width: 222,
                    child: Material(
                      color: const Color(0xFF151D30),
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        onTap: () => onPlaceTap(place),
                        borderRadius: BorderRadius.circular(15),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 51,
                                  height: 60,
                                  child: place.imageUrl.trim().startsWith('https://')
                                      ? Image.network(
                                    place.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _MapPlacePlaceholder(
                                      category: place.category,
                                    ),
                                  )
                                      : _MapPlacePlaceholder(category: place.category),
                                ),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      place.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      place.category,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Color(0xFFB0B8CC), fontSize: 9.5),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: <Widget>[
                                        Icon(
                                          exact ? Icons.location_on_rounded : Icons.location_searching_rounded,
                                          color: exact ? const Color(0xFF62DDB0) : const Color(0xFFFFC86B),
                                          size: 11,
                                        ),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            distanceLabel != null
                                                ? '$distanceLabel · Mapped pin'
                                                : (exact ? 'Mapped location available' : 'Location not verified'),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: distanceLabel != null || exact
                                                  ? const Color(0xFF62DDB0)
                                                  : const Color(0xFFFFC86B),
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (exact)
                                IconButton(
                                  tooltip: 'Center on map',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => onCenter(place),
                                  icon: const Icon(Icons.my_location_rounded, color: Color(0xFFBCA4FF), size: 17),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ZoneMapCard extends StatelessWidget {
  const _ZoneMapCard({
    required this.place,
    required this.locationName,
    required this.hasExactCoordinates,
    required this.onCenter,
    required this.onRoute,
    required this.isRouting,
    required this.routeSummary,
  });

  final NearbyPlace place;
  final String locationName;
  final bool hasExactCoordinates;
  final VoidCallback onCenter;
  final VoidCallback onRoute;
  final bool isRouting;
  final String? routeSummary;

  @override
  Widget build(BuildContext context) {
    final String? address = place.address?.trim();
    final String secondLine = (address != null && address.isNotEmpty)
        ? address
        : locationName;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xF20B1120),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0x229D7BFF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFFBCA4FF),
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      secondLine,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFB0B8CC),
                        fontSize: 10.5,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        Icon(
                          hasExactCoordinates
                              ? Icons.location_on_rounded
                              : Icons.info_outline_rounded,
                          size: 13,
                          color: hasExactCoordinates
                              ? const Color(0xFF62DDB0)
                              : const Color(0xFFFFC86B),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hasExactCoordinates
                                ? 'Mapped coordinates available'
                                : 'Location not verified yet',
                            style: TextStyle(
                              color: hasExactCoordinates
                                  ? const Color(0xFF62DDB0)
                                  : const Color(0xFFFFC86B),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (hasExactCoordinates) ...<Widget>[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Center on this Zone',
                  onPressed: onCenter,
                  icon: const Icon(
                    Icons.my_location_rounded,
                    color: Color(0xFFBCA4FF),
                  ),
                ),
              ],
            ],
          ),
          if (place.locationSourceUrl?.trim().isNotEmpty == true) ...<Widget>[
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                const Icon(Icons.source_outlined, size: 13, color: Color(0xFF9EA8BD)),
                const SizedBox(width: 5),
                const Expanded(
                  child: Text(
                    'Coordinates sourced from a public map record; not field-verified by MetaZone.',
                    style: TextStyle(color: Color(0xFF9EA8BD), fontSize: 9, height: 1.3),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final Uri? uri = Uri.tryParse(place.locationSourceUrl!);
                    if (uri == null || !(uri.scheme == 'https' || uri.scheme == 'http')) return;
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (error) {
                      debugPrint('Could not open coordinate source: $error');
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFBCA4FF),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    minimumSize: const Size(44, 30),
                  ),
                  child: const Text('Source', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
          if (hasExactCoordinates) ...<Widget>[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton.icon(
                onPressed: isRouting ? null : onRoute,
                icon: isRouting
                    ? const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.alt_route_rounded, size: 18),
                label: Text(
                  isRouting ? 'Calculating route…' : 'Route here inside MetaZone',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Road route and ETA are estimates from a public best-effort routing service; turn-by-turn navigation is not included.',
              style: TextStyle(color: Color(0xFF8993AA), fontSize: 9, height: 1.3),
            ),
            if (routeSummary != null) ...<Widget>[
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.route_rounded,
                    size: 14,
                    color: Color(0xFF62DDB0),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      routeSummary!,
                      style: const TextStyle(
                        color: Color(0xFF62DDB0),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _AttributionPill extends StatelessWidget {
  const _AttributionPill();

  static const String _attribution = String.fromEnvironment(
    'METAZONE_MAP_ATTRIBUTION',
    defaultValue: 'OpenFreeMap · © OpenMapTiles · © OpenStreetMap contributors',
  );

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            final Uri uri = Uri.parse('https://www.openstreetmap.org/copyright');
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (error) {
              debugPrint('MetaZone map attribution link failed: $error');
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xD90B1120),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.map_outlined, color: Color(0xFFBCA4FF), size: 13),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'MetaZone Map · $_attribution · License',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFFD1D7E5), fontSize: 9),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.open_in_new_rounded, color: Color(0xFFB0B8CC), size: 11),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
