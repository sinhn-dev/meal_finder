import '../models/user.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Mock auth. Sau này chỉ sửa file này để gọi API thật.
class AuthService {
  const AuthService({this.delay = const Duration(milliseconds: 400)});

  final Duration delay;

  Future<User> login({
    required String userName,
    required String password,
  }) async {
    await Future<void>.delayed(delay);

    final name = userName.trim();
    final pass = password.trim();
    if (name.isEmpty || pass.isEmpty) {
      throw const AuthException('User name and password are required.');
    }

    return User(id: 'mock-$name', userName: name, displayName: name);
  }
}
