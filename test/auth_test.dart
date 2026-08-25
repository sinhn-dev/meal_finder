import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meal_finder/config/app_constants.dart';
import 'package:meal_finder/services/auth_service.dart';
import 'package:meal_finder/services/auth_store.dart';

void main() {
  test('AuthService rejects empty fields', () async {
    const service = AuthService(delay: Duration.zero);
    expect(
      () => service.login(userName: ' ', password: 'x'),
      throwsA(isA<AuthException>()),
    );
  });

  test('AuthStore login persists user without password', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await AuthStore.create(
      service: const AuthService(delay: Duration.zero),
    );

    await store.login(userName: 'anna', password: 'secret');

    expect(store.isLoggedIn, isTrue);
    expect(store.currentUser?.id, 'mock-anna');
    expect(store.currentUser?.userName, 'anna');

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.authUserKey)!;
    expect(raw, contains('anna'));
    expect(raw, isNot(contains('secret')));
  });

  test('AuthStore logout clears session', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await AuthStore.create(
      service: const AuthService(delay: Duration.zero),
    );
    await store.login(userName: 'anna', password: 'secret');
    await store.logout();

    expect(store.isLoggedIn, isFalse);
    expect(store.currentUser, isNull);
  });
}
