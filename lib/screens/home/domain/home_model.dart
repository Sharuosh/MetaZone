import 'home_section_model.dart';

/// Complete data contract for MetaZone Home.
///
/// The Home UI consumes one immutable HomeData object instead of knowing
/// where individual pieces of data came from.
///
/// This keeps the presentation layer independent from:
/// - Firebase
/// - APIs
/// - Device location
/// - AI ranking
/// - Future data providers
class HomeData {
  final String locationName;

  final List<HomeCategory> categories;

  final List<NearbyPlace> nearbyPlaces;

  final List<Happening> happenings;

  final List<GoalAction> goals;

  final List<NearbyPlace> recommendations;

  const HomeData({
    required this.locationName,
    required this.categories,
    required this.nearbyPlaces,
    required this.happenings,
    required this.goals,
    required this.recommendations,
  });

  HomeData copyWith({
    String? locationName,
    List<HomeCategory>? categories,
    List<NearbyPlace>? nearbyPlaces,
    List<Happening>? happenings,
    List<GoalAction>? goals,
    List<NearbyPlace>? recommendations,
  }) {
    return HomeData(
      locationName: locationName ?? this.locationName,
      categories: categories ?? this.categories,
      nearbyPlaces: nearbyPlaces ?? this.nearbyPlaces,
      happenings: happenings ?? this.happenings,
      goals: goals ?? this.goals,
      recommendations:
      recommendations ?? this.recommendations,
    );
  }

  factory HomeData.empty() {
    return const HomeData(
      locationName: '',
      categories: [],
      nearbyPlaces: [],
      happenings: [],
      goals: [],
      recommendations: [],
    );
  }

  bool get isEmpty {
    return categories.isEmpty &&
        nearbyPlaces.isEmpty &&
        happenings.isEmpty &&
        goals.isEmpty &&
        recommendations.isEmpty;
  }

  bool get hasNearbyPlaces => nearbyPlaces.isNotEmpty;

  bool get hasHappenings => happenings.isNotEmpty;

  bool get hasGoals => goals.isNotEmpty;

  bool get hasRecommendations =>
      recommendations.isNotEmpty;
}