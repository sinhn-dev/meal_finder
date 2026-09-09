/// Demo-only mapping from coordinates → TheMealDB `strArea`.
/// Not real restaurants / cuisine detection.
class CuisineAreaMapper {
  CuisineAreaMapper._();

  static const defaultArea = 'Italian';

  /// Rough bounding boxes; more specific regions are checked first.
  static String latLngToCuisineArea(double latitude, double longitude) {
    if (_in(
      latitude,
      longitude,
      south: 8.0,
      north: 23.5,
      west: 102.0,
      east: 110.0,
    )) {
      return 'Vietnamese';
    }
    if (_in(
      latitude,
      longitude,
      south: 5.5,
      north: 20.5,
      west: 97.0,
      east: 106.0,
    )) {
      return 'Thai';
    }
    if (_in(
      latitude,
      longitude,
      south: 24.0,
      north: 46.0,
      west: 122.0,
      east: 146.0,
    )) {
      return 'Japanese';
    }
    if (_in(
      latitude,
      longitude,
      south: 18.0,
      north: 54.0,
      west: 73.0,
      east: 135.0,
    )) {
      return 'Chinese';
    }
    if (_in(
      latitude,
      longitude,
      south: 6.0,
      north: 36.0,
      west: 68.0,
      east: 97.5,
    )) {
      return 'Indian';
    }
    if (_in(
      latitude,
      longitude,
      south: 14.0,
      north: 33.0,
      west: -118.5,
      east: -86.0,
    )) {
      return 'Mexican';
    }
    if (_in(
      latitude,
      longitude,
      south: 24.0,
      north: 49.5,
      west: -125.0,
      east: -66.0,
    )) {
      return 'American';
    }
    if (_in(
      latitude,
      longitude,
      south: 49.5,
      north: 61.0,
      west: -8.5,
      east: 2.0,
    )) {
      return 'British';
    }
    if (_in(
      latitude,
      longitude,
      south: 41.0,
      north: 51.5,
      west: -5.5,
      east: 10.0,
    )) {
      return 'French';
    }
    if (_in(
      latitude,
      longitude,
      south: 36.0,
      north: 47.5,
      west: 6.0,
      east: 19.0,
    )) {
      return 'Italian';
    }
    return defaultArea;
  }

  static bool _in(
    double lat,
    double lng, {
    required double south,
    required double north,
    required double west,
    required double east,
  }) {
    return lat >= south && lat <= north && lng >= west && lng <= east;
  }
}
