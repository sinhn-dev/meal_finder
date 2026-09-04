import '../models/user.dart';

class AuthSession {
  const AuthSession({required this.user, required this.token});

  final User user;
  final String token;
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Mock auth API. Replace impl when wiring a real backend.
abstract class AuthRepository {
  Future<AuthSession> login({
    required String userName,
    required String password,
  });
}

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({this.delay = const Duration(milliseconds: 400)});

  final Duration delay;

  @override
  Future<AuthSession> login({
    required String userName,
    required String password,
  }) async {
    await Future<void>.delayed(delay);

    final name = userName.trim();
    final pass = password.trim();
    if (name.isEmpty || pass.isEmpty) {
      throw const AuthException('User name and password are required.');
    }

    if (name.toLowerCase() != 'demo') {
      throw const AuthException('Invalid credentials. Use user name "demo".');
    }

    const user = User(
      id: 'mock-demo',
      userName: 'demo',
      displayName: 'Demo User',
    );
    return AuthSession(user: user, token: 'mock-token-${user.id}');
  }
}
