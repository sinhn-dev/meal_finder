/// Cache key helpers for [MealLocalDataSource] / repository write-through.
class MealCacheKeys {
  MealCacheKeys._();

  static String category(String category) => 'category:$category';

  static String search(String query) => 'search:$query';

  static String area(String area) => 'area:$area';
}
