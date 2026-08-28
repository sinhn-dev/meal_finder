import 'package:flutter_test/flutter_test.dart';

import 'package:meal_finder/models/meal.dart';
import 'package:meal_finder/repositories/meal_repository.dart';
import 'package:meal_finder/services/meal_api.dart';

class _FakeMealApi extends MealApi {
  _FakeMealApi();

  int categoriesCalls = 0;
  int searchCalls = 0;
  int byCategoryCalls = 0;
  int lookupCalls = 0;
  int randomCalls = 0;

  @override
  Future<List<String>> categories() async {
    categoriesCalls += 1;
    return const ['Beef', 'Chicken'];
  }

  @override
  Future<List<MealSummary>> search(String query) async {
    searchCalls += 1;
    return [MealSummary(id: '1', name: 'Searched $query', thumbnail: '')];
  }

  @override
  Future<List<MealSummary>> byCategory(String category) async {
    byCategoryCalls += 1;
    return [MealSummary(id: '2', name: '$category meal', thumbnail: '')];
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

    expect(searched.single.name, 'Searched pasta');
    expect(byCategory.single.name, 'Beef meal');
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

    expect(first, ['Beef', 'Chicken']);
    expect(second, ['Beef', 'Chicken']);
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
}
