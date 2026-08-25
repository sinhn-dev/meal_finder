import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_constants.dart';
import '../models/user.dart';
import 'auth_service.dart';

class AuthStore extends ChangeNotifier {
  AuthStore._(this._prefs, this._service, this._currentUser);

  final SharedPreferences _prefs;
  final AuthService _service;
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  static Future<AuthStore> create({AuthService? service}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.authUserKey);
    User? user;
    if (raw != null && raw.isNotEmpty) {
      user = User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
    return AuthStore._(prefs, service ?? const AuthService(), user);
  }

  Future<void> login({
    required String userName,
    required String password,
  }) async {
    final user = await _service.login(userName: userName, password: password);
    _currentUser = user;
    await _prefs.setString(AppConstants.authUserKey, jsonEncode(user.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    await _prefs.remove(AppConstants.authUserKey);
    notifyListeners();
  }
}
