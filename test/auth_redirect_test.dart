import 'package:flutter_test/flutter_test.dart';

import 'package:meal_finder/router/app_routes.dart';
import 'package:meal_finder/router/auth_redirect.dart';

void main() {
  test('guest is sent to login', () {
    expect(
      authRedirect(isLoggedIn: false, location: AppRoutes.home),
      AppRoutes.login,
    );
    expect(
      authRedirect(isLoggedIn: false, location: AppRoutes.profile),
      AppRoutes.login,
    );
  });

  test('guest can stay on login', () {
    expect(authRedirect(isLoggedIn: false, location: AppRoutes.login), isNull);
  });

  test('logged-in user is sent away from login', () {
    expect(
      authRedirect(isLoggedIn: true, location: AppRoutes.login),
      AppRoutes.home,
    );
  });

  test('logged-in user can open app routes', () {
    expect(authRedirect(isLoggedIn: true, location: AppRoutes.home), isNull);
    expect(
      authRedirect(isLoggedIn: true, location: AppRoutes.favorites),
      isNull,
    );
    expect(authRedirect(isLoggedIn: true, location: '/meals/52772'), isNull);
  });

  test('meal path helper builds /meals/:id', () {
    expect(AppRoutes.meal('52772'), '/meals/52772');
  });
}
