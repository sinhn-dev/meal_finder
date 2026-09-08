import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meal_finder/data/local/app_database.dart';
import 'package:meal_finder/data/local/meal_cache_keys.dart';
import 'package:meal_finder/data/local/meal_local_data_source.dart';
import 'package:meal_finder/models/meal.dart';
import 'package:meal_finder/repositories/meal_repository.dart';
import 'package:meal_finder/services/meal_api.dart';

class _FakeMealApi extends MealApi {
  @override
  Future<List<String>> categories() async => const ['Beef', 'Chicken'];

  @override
  Future<List<MealSummary>> search(String query) async {
    return [MealSummary(id: '1', name: 'Searched $query', thumbnail: 't')];
  }

  @override
  Future<List<MealSummary>> byCategory(String category) async {
    return [
      MealSummary(id: '2', name: '$category meal', thumbnail: 't2'),
      MealSummary(id: '3', name: '$category meal 2', thumbnail: 't3'),
    ];
  }

  @override
  Future<Meal?> lookup(String id) async => null;

  @override
  Future<Meal?> random() async => null;
}

void main() {
  late AppDatabase database;
  late MealLocalDataSource local;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    local = MealLocalDataSource(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('replaceMealsForSource then getMealsBySourceKey round-trips', () async {
    const meals = [
      MealSummary(id: '1', name: 'Pasta', thumbnail: 'a'),
      MealSummary(id: '2', name: 'Curry', thumbnail: 'b'),
    ];
    final key = MealCacheKeys.category('Beef');

    await local.replaceMealsForSource(key, meals);
    final loaded = await local.getMealsBySourceKey(key);

    expect(loaded, hasLength(2));
    expect(loaded.map((m) => m.id), ['1', '2']);
  });

  test('replaceMealsForSource overwrites previous rows for same key', () async {
    final key = MealCacheKeys.search('pasta');
    await local.replaceMealsForSource(key, const [
      MealSummary(id: '1', name: 'Old', thumbnail: ''),
    ]);
    await local.replaceMealsForSource(key, const [
      MealSummary(id: '9', name: 'New', thumbnail: ''),
    ]);

    final loaded = await local.getMealsBySourceKey(key);
    expect(loaded, hasLength(1));
    expect(loaded.single.id, '9');
  });

  test('replaceCategories then getCategories round-trips', () async {
    await local.replaceCategories(const ['Beef', 'Seafood']);
    expect(await local.getCategories(), ['Beef', 'Seafood']);
  });

  test(
    'MealRepositoryImpl write-through persists search and category',
    () async {
      final repository = MealRepositoryImpl(_FakeMealApi(), local: local);

      await repository.search('pasta');
      await repository.byCategory('Beef');
      await repository.categories();

      final searchCached = await repository.getCachedBySourceKey(
        MealCacheKeys.search('pasta'),
      );
      final categoryCached = await repository.getCachedBySourceKey(
        MealCacheKeys.category('Beef'),
      );
      final categoriesCached = await repository.getCachedCategories();

      expect(searchCached.single.name, 'Searched pasta');
      expect(categoryCached, hasLength(2));
      expect(categoriesCached, ['Beef', 'Chicken']);
    },
  );
}
