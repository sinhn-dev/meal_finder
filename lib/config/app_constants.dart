class AppConstants {
  AppConstants._();

  static const themeModeKey = 'theme_mode';
  static const authUserKey = 'auth_user';

  /// Legacy global key — migrated once per user on first load.
  static const favoriteMealsKey = 'favorite_meals';

  static String favoriteMealsKeyFor(String userId) => 'favorite_meals_$userId';

  static String searchHistoryKeyFor(String userId) => 'search_history_$userId';

  static const searchDebounce = Duration(milliseconds: 300);
  static const searchMaxLength = 40;
  static const searchHistoryMaxItems = 10;
  static const categoriesCacheTtl = Duration(minutes: 5);
}
