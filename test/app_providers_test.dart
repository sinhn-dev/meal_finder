import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meal_finder/providers/app_providers.dart';
import 'package:meal_finder/repositories/meal_repository.dart';
import 'package:meal_finder/services/auth_store.dart';
import 'package:meal_finder/services/meal_api.dart';

void main() {
  test('store providers throw without override', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(() => container.read(authStoreProvider), throwsStateError);
    expect(() => container.read(favoritesStoreProvider), throwsStateError);
    expect(() => container.read(themeStoreProvider), throwsStateError);
  });

  test(
    'meal providers and goRouterProvider can be read with auth override',
    () async {
      SharedPreferences.setMockInitialValues({});
      final auth = await AuthStore.create();
      final container = ProviderContainer(
        overrides: [authStoreProvider.overrideWith((ref) => auth)],
      );
      addTearDown(container.dispose);

      expect(container.read(mealApiProvider), isA<MealApi>());
      expect(container.read(mealRepositoryProvider), isA<MealRepository>());
      expect(container.read(goRouterProvider), isA<GoRouter>());
      expect(
        identical(
          container.read(goRouterProvider),
          container.read(goRouterProvider),
        ),
        isTrue,
      );
    },
  );
}
