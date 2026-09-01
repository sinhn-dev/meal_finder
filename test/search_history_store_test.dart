import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meal_finder/config/app_constants.dart';
import 'package:meal_finder/services/search_history_store.dart';

const _userA = 'mock-anna';
const _userB = 'mock-bob';

void main() {
  test('add sanitizes and stores keyword', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await SearchHistoryStore.create(userId: _userA);

    await store.add('  pasta  ');

    expect(store.keywords, ['pasta']);
  });

  test('add moves duplicate to front without duplicating', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await SearchHistoryStore.create(userId: _userA);

    await store.add('pasta');
    await store.add('chicken');
    await store.add('PASTA');

    expect(store.keywords, ['PASTA', 'chicken']);
  });

  test('add ignores empty keyword', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await SearchHistoryStore.create(userId: _userA);

    await store.add('   ');

    expect(store.keywords, isEmpty);
  });

  test('keeps at most searchHistoryMaxItems entries', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await SearchHistoryStore.create(userId: _userA);

    for (var i = 1; i <= 12; i++) {
      await store.add('item$i');
    }

    expect(store.keywords, hasLength(AppConstants.searchHistoryMaxItems));
    expect(store.keywords.first, 'item12');
    expect(store.keywords.last, 'item3');
  });

  test('persists under user-scoped key', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await SearchHistoryStore.create(userId: _userA);
    await store.add('curry');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList(AppConstants.searchHistoryKeyFor(_userA)), [
      'curry',
    ]);
  });

  test('switchUser loads separate history per user', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await SearchHistoryStore.create(userId: _userA);
    await store.add('pasta');

    await store.switchUser(_userB);
    expect(store.keywords, isEmpty);

    await store.add('sushi');
    expect(store.keywords, ['sushi']);

    await store.switchUser(_userA);
    expect(store.keywords, ['pasta']);
  });

  test(
    'clearSession clears in-memory list without deleting persisted data',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = await SearchHistoryStore.create(userId: _userA);
      await store.add('pasta');

      store.clearSession();

      expect(store.userId, isNull);
      expect(store.keywords, isEmpty);

      await store.switchUser(_userA);
      expect(store.keywords, ['pasta']);
    },
  );

  test('add is ignored when no user is active', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await SearchHistoryStore.create();

    await store.add('pasta');

    expect(store.keywords, isEmpty);
  });
}
