import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meal_finder/config/app_constants.dart';
import 'package:meal_finder/models/meal.dart';
import 'package:meal_finder/services/favorites_store.dart';

const _userA = 'mock-anna';
const _userB = 'mock-bob';

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
      final store = await FavoritesStore.create(userId: _userA);
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
    final store = await FavoritesStore.create(userId: _userA);

    expect(await store.removeById('missing'), isNull);
  });

  test('insertAt does not duplicate an existing meal', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await FavoritesStore.create(userId: _userA);
    await store.toggle(_pasta);

    await store.insertAt(0, _pasta);

    expect(store.meals, hasLength(1));
  });

  test('switchUser loads separate favorites per user', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await FavoritesStore.create(userId: _userA);
    await store.toggle(_pasta);
    await store.toggle(_curry);

    await store.switchUser(_userB);
    expect(store.meals, isEmpty);

    await store.toggle(_curry);
    expect(store.meals, hasLength(1));
    expect(store.contains('1'), isFalse);

    await store.switchUser(_userA);
    expect(store.meals, hasLength(2));
    expect(store.contains('1'), isTrue);
    expect(store.contains('2'), isTrue);
  });

  test('persists favorites under user-scoped key', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await FavoritesStore.create(userId: _userA);
    await store.toggle(_pasta);

    final prefs = await SharedPreferences.getInstance();
    final key = AppConstants.favoriteMealsKeyFor(_userA);
    expect(prefs.getStringList(key), hasLength(1));
    expect(prefs.getStringList(AppConstants.favoriteMealsKey), isNull);
  });

  test('migrates legacy global favorites key once', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.favoriteMealsKey: [jsonEncode(_pasta.toJson())],
    });

    final store = await FavoritesStore.create(userId: _userA);

    expect(store.meals, hasLength(1));
    expect(store.meals.first.id, '1');

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getStringList(AppConstants.favoriteMealsKeyFor(_userA)),
      hasLength(1),
    );
    expect(prefs.getStringList(AppConstants.favoriteMealsKey), isNull);
  });

  test(
    'clearSession clears in-memory list without deleting persisted data',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = await FavoritesStore.create(userId: _userA);
      await store.toggle(_pasta);

      store.clearSession();

      expect(store.userId, isNull);
      expect(store.meals, isEmpty);

      await store.switchUser(_userA);
      expect(store.meals, hasLength(1));
    },
  );

  test('toggle is ignored when no user is active', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await FavoritesStore.create();

    await store.toggle(_pasta);

    expect(store.meals, isEmpty);
  });
}
