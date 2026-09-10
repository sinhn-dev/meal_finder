import 'package:flutter_test/flutter_test.dart';

import 'package:meal_finder/models/meal.dart';
import 'package:meal_finder/repositories/meal_repository.dart';
import 'package:meal_finder/services/meal_api.dart';
import 'package:meal_finder/data/local/app_database.dart';
import 'package:meal_finder/data/local/meal_cache_keys.dart';
import 'package:meal_finder/data/local/meal_local_data_source.dart';
import 'package:drift/native.dart';

class _FakeMealApi extends MealApi {
  _FakeMealApi();

  int categoriesCalls = 0;
  int searchCalls = 0;
  int byCategoryCalls = 0;
  int lookupCalls = 0;
  int randomCalls = 0;
  bool failSearch = false;
  bool failByCategory = false;
  bool failCategories = false;

  @override
  Future<List<String>> categories() async {
    categoriesCalls += 1;
    if (failCategories) {
      throw const MealApiException('categories network error');
    }
    return const ['Beef', 'Chicken'];
  }

  @override
  Future<List<MealSummary>> search(String query) async {
    searchCalls += 1;
    if (failSearch) {
      throw const MealApiException('search network error');
    }
    return [MealSummary(id: '1', name: 'Searched $query', thumbnail: '')];
  }

  @override
  Future<List<MealSummary>> byCategory(String category) async {
    byCategoryCalls += 1;
    if (failByCategory) {
      throw const MealApiException('category network error');
    }
    return [MealSummary(id: '2', name: '$category meal', thumbnail: '')];
  }

  @override
  Future<List<MealSummary>> byArea(String area) async {
    return [MealSummary(id: '4', name: '$area meal', thumbnail: '')];
  }

  @override
  Future<Meal?> lookup(String id) async {
    lookupCalls += 1;
    return Meal(id: id, name: 'Meal $id', thumbnail: '', ingredients: const []);
  }

  @override
  Future<Meal?> random() async {
    randomCalls += 1;
    return const Meal(id: '9', name: 'Random', thumbnail: '', ingredients: []);
  }
}

void main() {
  late _FakeMealApi api;
  late MealRepositoryImpl repository;

  setUp(() {
    api = _FakeMealApi();
    repository = MealRepositoryImpl(
      api,
      categoriesCacheTtl: const Duration(minutes: 5),
    );
  });

  test('delegates search, byCategory, lookup, random to MealApi', () async {
    final searched = await repository.search('pasta');
    final byCategory = await repository.byCategory('Beef');
    final lookup = await repository.lookup('52772');
    final random = await repository.random();

    expect(searched.data.single.name, 'Searched pasta');
    expect(searched.isFromCache, isFalse);
    expect(byCategory.data.single.name, 'Beef meal');
    expect(lookup?.id, '52772');
    expect(random?.name, 'Random');
    expect(api.searchCalls, 1);
    expect(api.byCategoryCalls, 1);
    expect(api.lookupCalls, 1);
    expect(api.randomCalls, 1);
  });

  test('caches categories within TTL', () async {
    final first = await repository.categories();
    final second = await repository.categories();

    expect(first.data, ['Beef', 'Chicken']);
    expect(second.data, ['Beef', 'Chicken']);
    expect(api.categoriesCalls, 1);
  });

  test('refetches categories after cache clear', () async {
    await repository.categories();
    repository.clearCategoriesCache();
    await repository.categories();

    expect(api.categoriesCalls, 2);
  });

  test('refetches categories after TTL expires', () async {
    final shortLived = MealRepositoryImpl(
      api,
      categoriesCacheTtl: Duration.zero,
    );

    await shortLived.categories();
    await Future<void>.delayed(const Duration(milliseconds: 1));
    await shortLived.categories();

    expect(api.categoriesCalls, 2);
  });

  test('getCached* returns empty when local data source is absent', () async {
    expect(await repository.getCachedBySourceKey('category:Beef'), isEmpty);
    expect(await repository.getCachedCategories(), isEmpty);
  });

  test('offline search returns Drift cache with isFromCache', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final local = MealLocalDataSource(database);
    await local.replaceMealsForSource(MealCacheKeys.search('pasta'), const [
      MealSummary(id: '9', name: 'Cached pasta', thumbnail: ''),
    ]);

    final offlineRepo = MealRepositoryImpl(
      api,
      local: local,
      isOnline: () async => false,
    );

    final result = await offlineRepo.search('pasta');

    expect(result.isFromCache, isTrue);
    expect(result.data.single.name, 'Cached pasta');
    expect(api.searchCalls, 0);
  });

  test('offline search without cache throws clear error', () async {
    final offlineRepo = MealRepositoryImpl(api, isOnline: () async => false);

    expect(
      () => offlineRepo.search('pasta'),
      throwsA(
        isA<MealApiException>().having(
          (e) => e.message,
          'message',
          contains('offline'),
        ),
      ),
    );
    expect(api.searchCalls, 0);
  });

  test('online failure falls back to Drift cache', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final local = MealLocalDataSource(database);
    await local.replaceMealsForSource(MealCacheKeys.category('Beef'), const [
      MealSummary(id: '3', name: 'Cached beef', thumbnail: ''),
    ]);
    api.failByCategory = true;

    final repo = MealRepositoryImpl(api, local: local);

    final result = await repo.byCategory('Beef');

    expect(result.isFromCache, isTrue);
    expect(result.data.single.name, 'Cached beef');
    expect(api.byCategoryCalls, 1);
  });

  test('online categories failure falls back to Drift', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final local = MealLocalDataSource(database);
    await local.replaceCategories(const ['Seafood']);
    api.failCategories = true;

    final repo = MealRepositoryImpl(api, local: local);
    final result = await repo.categories();

    expect(result.isFromCache, isTrue);
    expect(result.data, ['Seafood']);
  });

  test('byArea write-through uses area cache key', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final local = MealLocalDataSource(database);
    final repo = MealRepositoryImpl(api, local: local);

    final result = await repo.byArea('Vietnamese');
    final cached = await repo.getCachedBySourceKey(
      MealCacheKeys.area('Vietnamese'),
    );

    expect(result.data.single.name, 'Vietnamese meal');
    expect(cached.single.name, 'Vietnamese meal');
  });
}
