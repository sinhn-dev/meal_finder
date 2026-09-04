import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meal_finder/config/app_constants.dart';
import 'package:meal_finder/repositories/auth_repository.dart';
import 'package:meal_finder/services/auth_store.dart';
import 'package:meal_finder/services/token_storage.dart';

void main() {
  group('AuthRepositoryImpl', () {
    const repository = AuthRepositoryImpl(delay: Duration.zero);

    test('rejects empty fields', () {
      expect(
        () => repository.login(userName: ' ', password: 'x'),
        throwsA(isA<AuthException>()),
      );
    });

    test('rejects non-demo user name', () {
      expect(
        () => repository.login(userName: 'anna', password: 'secret'),
        throwsA(
          predicate<AuthException>(
            (error) => error.message.contains('Invalid credentials'),
          ),
        ),
      );
    });

    test('returns user and token for demo credentials', () async {
      final session = await repository.login(
        userName: 'demo',
        password: 'secret',
      );

      expect(session.user.userName, 'demo');
      expect(session.user.id, 'mock-demo');
      expect(session.token, 'mock-token-mock-demo');
    });
  });

  group('AuthStore', () {
    test('login persists user and token without password', () async {
      SharedPreferences.setMockInitialValues({});
      final tokenStorage = InMemoryTokenStorage();
      final store = await AuthStore.create(
        repository: const AuthRepositoryImpl(delay: Duration.zero),
        tokenStorage: tokenStorage,
      );

      await store.login(userName: 'demo', password: 'secret');

      expect(store.isLoggedIn, isTrue);
      expect(store.currentUser?.userName, 'demo');
      expect(await tokenStorage.readToken(), 'mock-token-mock-demo');

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(AppConstants.authUserKey)!;
      expect(raw, contains('demo'));
      expect(raw, isNot(contains('secret')));
      expect(raw, isNot(contains('mock-token')));
    });

    test('logout clears user and token', () async {
      SharedPreferences.setMockInitialValues({});
      final tokenStorage = InMemoryTokenStorage();
      final store = await AuthStore.create(
        repository: const AuthRepositoryImpl(delay: Duration.zero),
        tokenStorage: tokenStorage,
      );
      await store.login(userName: 'demo', password: 'secret');
      await store.logout();

      expect(store.isLoggedIn, isFalse);
      expect(store.currentUser, isNull);
      expect(await tokenStorage.readToken(), isNull);
    });

    test('handleUnauthorized clears session', () async {
      SharedPreferences.setMockInitialValues({});
      final tokenStorage = InMemoryTokenStorage();
      final store = await AuthStore.create(
        repository: const AuthRepositoryImpl(delay: Duration.zero),
        tokenStorage: tokenStorage,
      );
      await store.login(userName: 'demo', password: 'secret');

      await store.handleUnauthorized();

      expect(store.isLoggedIn, isFalse);
      expect(await tokenStorage.readToken(), isNull);
    });

    test('drops stale user when token is missing on startup', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.authUserKey:
            '{"id":"mock-demo","userName":"demo","displayName":"Demo User"}',
      });
      final store = await AuthStore.create(
        repository: const AuthRepositoryImpl(delay: Duration.zero),
        tokenStorage: InMemoryTokenStorage(),
      );

      expect(store.isLoggedIn, isFalse);
    });
  });
}
