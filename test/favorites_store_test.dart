import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meal_finder/models/meal.dart';
import 'package:meal_finder/services/favorites_store.dart';

const _pasta = MealSummary(
  id: '1',
  name: 'Pasta',
  thumbnail: 'https://example.com/pasta.jpg',
);

const _curry = MealSummary(
  id: '2',
  name: 'Curry',
  thumbnail: 'https://example.com/curry.jpg',
);

void main() {
  test(
    'removeById deletes meal and persist can restore via insertAt',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = await FavoritesStore.create();
      await store.toggle(_pasta);
      await store.toggle(_curry);

      final removed = await store.removeById('1');

      expect(removed?.name, 'Pasta');
      expect(store.meals, hasLength(1));
      expect(store.contains('1'), isFalse);
      expect(store.contains('2'), isTrue);

      await store.insertAt(0, removed!);

      expect(store.meals.first.id, '1');
      expect(store.meals, hasLength(2));
    },
  );

  test('removeById returns null when id is missing', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await FavoritesStore.create();

    expect(await store.removeById('missing'), isNull);
  });

  test('insertAt does not duplicate an existing meal', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await FavoritesStore.create();
    await store.toggle(_pasta);

    await store.insertAt(0, _pasta);

    expect(store.meals, hasLength(1));
  });
}
