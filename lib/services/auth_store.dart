import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_constants.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import 'token_storage.dart';

class AuthStore extends ChangeNotifier {
  AuthStore._(
    this._prefs,
    this._repository,
    this._tokenStorage,
    this._currentUser,
  );

  final SharedPreferences _prefs;
  final AuthRepository _repository;
  final TokenStorage _tokenStorage;
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  static Future<AuthStore> create({
    AuthRepository? repository,
    TokenStorage? tokenStorage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final storage = tokenStorage ?? SecureTokenStorage();
    final repo = repository ?? const AuthRepositoryImpl();

    User? user;
    final raw = prefs.getString(AppConstants.authUserKey);
    if (raw != null && raw.isNotEmpty) {
      user = User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }

    final token = await storage.readToken();
    if (user != null && (token == null || token.isEmpty)) {
      await prefs.remove(AppConstants.authUserKey);
      user = null;
    }

    return AuthStore._(prefs, repo, storage, user);
  }

  Future<void> login({
    required String userName,
    required String password,
  }) async {
    final session = await _repository.login(
      userName: userName,
      password: password,
    );
    _currentUser = session.user;
    await _prefs.setString(
      AppConstants.authUserKey,
      jsonEncode(session.user.toJson()),
    );
    await _tokenStorage.writeToken(session.token);
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    await _prefs.remove(AppConstants.authUserKey);
    await _tokenStorage.deleteToken();
    notifyListeners();
  }

  Future<void> handleUnauthorized() async {
    debugPrint('AuthStore: session expired (401)');
    await logout();
  }
}
