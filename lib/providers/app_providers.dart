import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/local/meal_local_data_source.dart';
import '../repositories/meal_repository.dart';
import '../router/app_router.dart';
import '../services/auth_store.dart';
import '../services/favorites_store.dart';
import '../services/meal_api.dart';
import '../services/search_history_store.dart';
import '../services/theme_store.dart';

final mealApiProvider = Provider<MealApi>((ref) {
  throw StateError('Override mealApiProvider in main()');
});

/// Null by default in tests; overridden in main() with Drift-backed source.
final mealLocalDataSourceProvider = Provider<MealLocalDataSource?>(
  (ref) => null,
);

/// UI nên đọc provider này, không gọi [mealApiProvider] trực tiếp.
final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepositoryImpl(
    ref.watch(mealApiProvider),
    local: ref.watch(mealLocalDataSourceProvider),
  );
});

final authStoreProvider = ChangeNotifierProvider<AuthStore>((ref) {
  throw StateError('Override authStoreProvider in main()');
});

final favoritesStoreProvider = ChangeNotifierProvider<FavoritesStore>((ref) {
  throw StateError('Override favoritesStoreProvider in main()');
});

final searchHistoryStoreProvider = ChangeNotifierProvider<SearchHistoryStore>((
  ref,
) {
  throw StateError('Override searchHistoryStoreProvider in main()');
});

final themeStoreProvider = ChangeNotifierProvider<ThemeStore>((ref) {
  throw StateError('Override themeStoreProvider in main()');
});

/// Đọc AuthStore một lần — không recreate GoRouter mỗi notifyListeners.
final goRouterProvider = Provider<GoRouter>((ref) {
  debugPrint('Riverpod: create GoRouter (auth override, not on every notify)');
  return createAppRouter(ref.read(authStoreProvider));
});
