import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_constants.dart';

class ThemeStore extends ChangeNotifier {
  ThemeStore._(this._prefs, this._mode);

  final SharedPreferences _prefs;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  static Future<ThemeStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.themeModeKey);
    return ThemeStore._(prefs, _fromStorage(raw));
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) {
      return;
    }
    _mode = mode;
    await _prefs.setString(AppConstants.themeModeKey, _toStorage(mode));
    debugPrint('ThemeStore: mode=$mode');
    notifyListeners();
  }

  static ThemeMode _fromStorage(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _toStorage(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
