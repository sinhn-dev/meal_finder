import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meal_finder/models/fetch_result.dart';
import 'package:meal_finder/models/meal.dart';
import 'package:meal_finder/providers/app_providers.dart';
import 'package:meal_finder/providers/home_meals_notifier.dart';
import 'package:meal_finder/repositories/meal_repository.dart';
import 'package:meal_finder/services/search_history_store.dart';

class _FakeMealRepository implements MealRepository {
  _FakeMealRepository({
    this.failCategories = false,
    this.failSearch = false,
    this.fromCache = false,
  });

  final bool failCategories;
  final bool failSearch;
  final bool fromCache;

  int categoriesCalls = 0;
  int byCategoryCalls = 0;
  int searchCalls = 0;
  String? lastCategory;

  @override
  Future<FetchResult<List<String>>> categories() async {
    categoriesCalls += 1;
    if (failCategories) {
      throw Exception('categories failed');
    }
    return FetchResult(const ['Beef', 'Chicken'], isFromCache: fromCache);
  }

  @override
  Future<FetchResult<List<MealSummary>>> byCategory(String category) async {
    byCategoryCalls += 1;
    lastCategory = category;
    return FetchResult([
      MealSummary(id: '1', name: '$category meal', thumbnail: ''),
    ], isFromCache: fromCache);
  }

  @override
  Future<FetchResult<List<MealSummary>>> byArea(String area) async {
    return FetchResult([
      MealSummary(id: '3', name: '$area meal', thumbnail: ''),
    ], isFromCache: fromCache);
  }

  @override
  Future<FetchResult<List<MealSummary>>> search(String query) async {
    searchCalls += 1;
    if (failSearch) {
      throw Exception('search failed');
    }
    return FetchResult([
      MealSummary(id: '2', name: 'Searched $query', thumbnail: ''),
    ], isFromCache: fromCache);
  }

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
  late ProviderContainer container;
  late _FakeMealRepository repository;
  late SearchHistoryStore searchHistory;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = _FakeMealRepository();
    searchHistory = await SearchHistoryStore.create(userId: 'mock-demo');
    container = ProviderContainer(
      overrides: [
        mealRepositoryProvider.overrideWith((ref) => repository),
        searchHistoryStoreProvider.overrideWith((ref) => searchHistory),
        isOnlineProvider.overrideWith((ref) => Stream.value(true)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('bootstrap loads categories and first category meals', () async {
    final notifier = container.read(homeMealsProvider.notifier);

    await notifier.bootstrap();

    final state = container.read(homeMealsProvider);
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
    expect(state.categories, ['Beef', 'Chicken']);
    expect(state.selectedCategory, 'Beef');
    expect(state.meals.single.name, 'Beef meal');
    expect(state.isFromCache, isFalse);
    expect(repository.categoriesCalls, 1);
    expect(repository.byCategoryCalls, 1);
  });

  test('bootstrap surfaces error when categories fail', () async {
    repository = _FakeMealRepository(failCategories: true);
    container.dispose();
    container = ProviderContainer(
      overrides: [
        mealRepositoryProvider.overrideWith((ref) => repository),
        searchHistoryStoreProvider.overrideWith((ref) => searchHistory),
        isOnlineProvider.overrideWith((ref) => Stream.value(true)),
      ],
    );

    await container.read(homeMealsProvider.notifier).bootstrap();

    final state = container.read(homeMealsProvider);
    expect(state.isLoading, isFalse);
    expect(state.error, contains('categories failed'));
  });

  test('search loads meals and writes search history', () async {
    final notifier = container.read(homeMealsProvider.notifier);
    await notifier.bootstrap();

    await notifier.search('pasta');

    final state = container.read(homeMealsProvider);
    expect(state.selectedCategory, isNull);
    expect(state.query, 'pasta');
    expect(state.meals.single.name, 'Searched pasta');
    expect(searchHistory.keywords, ['pasta']);
    expect(repository.searchCalls, 1);
  });

  test('search with empty query reloads selected or first category', () async {
    final notifier = container.read(homeMealsProvider.notifier);
    await notifier.bootstrap();
    await notifier.loadCategory('Chicken');
    repository.byCategoryCalls = 0;

    await notifier.search('   ');

    expect(repository.byCategoryCalls, 1);
    expect(repository.lastCategory, 'Chicken');
    expect(container.read(homeMealsProvider).selectedCategory, 'Chicken');
  });

  test('loadCategory updates meals', () async {
    final notifier = container.read(homeMealsProvider.notifier);
    await notifier.bootstrap();

    await notifier.loadCategory('Chicken');

    final state = container.read(homeMealsProvider);
    expect(state.selectedCategory, 'Chicken');
    expect(state.meals.single.name, 'Chicken meal');
  });

  test('search surfaces error without writing history', () async {
    repository = _FakeMealRepository(failSearch: true);
    container.dispose();
    container = ProviderContainer(
      overrides: [
        mealRepositoryProvider.overrideWith((ref) => repository),
        searchHistoryStoreProvider.overrideWith((ref) => searchHistory),
        isOnlineProvider.overrideWith((ref) => Stream.value(true)),
      ],
    );
    final notifier = container.read(homeMealsProvider.notifier);
    await notifier.bootstrap();

    await notifier.search('pasta');

    final state = container.read(homeMealsProvider);
    expect(state.error, contains('search failed'));
    expect(searchHistory.keywords, isEmpty);
  });

  test('bootstrap sets isFromCache when repository returns cache', () async {
    repository = _FakeMealRepository(fromCache: true);
    container.dispose();
    container = ProviderContainer(
      overrides: [
        mealRepositoryProvider.overrideWith((ref) => repository),
        searchHistoryStoreProvider.overrideWith((ref) => searchHistory),
        isOnlineProvider.overrideWith((ref) => Stream.value(false)),
      ],
    );

    await container.read(homeMealsProvider.notifier).bootstrap();

    final state = container.read(homeMealsProvider);
    expect(state.isFromCache, isTrue);
    expect(state.isOffline, isTrue);
    expect(state.meals, isNotEmpty);
  });
}
