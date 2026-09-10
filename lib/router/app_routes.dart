class AppRoutes {
  AppRoutes._();

  static const login = '/login';
  static const home = '/';
  static const favorites = '/favorites';
  static const profile = '/profile';
  static const nearMe = '/near-me';

  static String meal(String id) => '/meals/$id';
}
