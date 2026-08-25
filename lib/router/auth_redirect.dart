import 'app_routes.dart';

/// Pure redirect helper — easy to unit test (giống ProtectedRoute).
String? authRedirect({required bool isLoggedIn, required String location}) {
  final loggingIn = location == AppRoutes.login;
  if (!isLoggedIn && !loggingIn) {
    return AppRoutes.login;
  }
  if (isLoggedIn && loggingIn) {
    return AppRoutes.home;
  }
  return null;
}
