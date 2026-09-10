import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:meal_finder/models/fetch_result.dart';
import 'package:meal_finder/models/meal.dart';
import 'package:meal_finder/providers/app_providers.dart';
import 'package:meal_finder/providers/near_me_notifier.dart';
import 'package:meal_finder/repositories/meal_repository.dart';
import 'package:meal_finder/services/location_service.dart';

class _FakeMealRepository implements MealRepository {
  String? lastArea;

  @override
  Future<FetchResult<List<String>>> categories() async => const FetchResult([]);

  @override
  Future<FetchResult<List<MealSummary>>> byCategory(String category) async =>
      const FetchResult([]);

  @override
  Future<FetchResult<List<MealSummary>>> byArea(String area) async {
    lastArea = area;
    return FetchResult([
      MealSummary(id: '1', name: '$area meal', thumbnail: ''),
    ]);
  }

  @override
  Future<FetchResult<List<MealSummary>>> search(String query) async =>
      const FetchResult([]);

  @override
  Future<Meal?> lookup(String id) async => null;

  @override
  Future<Meal?> random() async => null;

  @override
  Future<List<MealSummary>> getCachedBySourceKey(String sourceKey) async =>
      const [];

  @override
  Future<List<String>> getCachedCategories() async => const [];
}

void main() {
  Position hanoi() {
    return Position(
      latitude: 21.03,
      longitude: 105.85,
      timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      accuracy: 1,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  test('load maps GPS to area and fetches meals', () async {
    final repository = _FakeMealRepository();
    final location = LocationService(
      isLocationServiceEnabled: () async => true,
      checkPermission: () async => LocationPermission.whileInUse,
      getCurrentPosition: () async => hanoi(),
    );
    final container = ProviderContainer(
      overrides: [
        mealRepositoryProvider.overrideWith((ref) => repository),
        locationServiceProvider.overrideWith((ref) => location),
      ],
    );
    addTearDown(container.dispose);

    await container.read(nearMeProvider.notifier).load();

    final state = container.read(nearMeProvider);
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
    expect(state.area, 'Vietnamese');
    expect(state.meals.single.name, 'Vietnamese meal');
    expect(repository.lastArea, 'Vietnamese');
  });

  test('load surfaces denied permission without crashing', () async {
    final location = LocationService(
      isLocationServiceEnabled: () async => true,
      checkPermission: () async => LocationPermission.denied,
      requestPermission: () async => LocationPermission.denied,
    );
    final container = ProviderContainer(
      overrides: [
        mealRepositoryProvider.overrideWith((ref) => _FakeMealRepository()),
        locationServiceProvider.overrideWith((ref) => location),
      ],
    );
    addTearDown(container.dispose);

    await container.read(nearMeProvider.notifier).load();

    final state = container.read(nearMeProvider);
    expect(state.isLoading, isFalse);
    expect(state.failureReason, LocationFailureReason.denied);
    expect(state.meals, isEmpty);
    expect(state.error, contains('denied'));
  });
}
