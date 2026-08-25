import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../services/auth_store.dart';
import '../services/favorites_store.dart';
import '../services/meal_api.dart';
import '../services/theme_store.dart';

final mealApiProvider = Provider<MealApi>((ref) => MealApi());

final authStoreProvider = ChangeNotifierProvider<AuthStore>((ref) {
  throw StateError('Override authStoreProvider in main()');
});

final favoritesStoreProvider = ChangeNotifierProvider<FavoritesStore>((ref) {
  throw StateError('Override favoritesStoreProvider in main()');
});

final themeStoreProvider = ChangeNotifierProvider<ThemeStore>((ref) {
  throw StateError('Override themeStoreProvider in main()');
});

/// Đọc AuthStore một lần — không recreate GoRouter mỗi notifyListeners.
final goRouterProvider = Provider<GoRouter>((ref) {
  debugPrint('Riverpod: create GoRouter (auth override, not on every notify)');
  return createAppRouter(ref.read(authStoreProvider));
});
