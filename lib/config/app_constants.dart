class AppConstants {
  AppConstants._();

  static const themeModeKey = 'theme_mode';
  static const authUserKey = 'auth_user';
  static const favoriteMealsKey = 'favorite_meals';
  static const searchDebounce = Duration(milliseconds: 300);
  static const searchMaxLength = 40;
  static const categoriesCacheTtl = Duration(minutes: 5);
}
