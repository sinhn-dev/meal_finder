import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meal_finder/config/app_constants.dart';
import 'package:meal_finder/services/theme_store.dart';

void main() {
  test('ThemeStore defaults to system and persists dark', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await ThemeStore.create();

    expect(store.mode, ThemeMode.system);

    await store.setMode(ThemeMode.dark);

    expect(store.mode, ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(AppConstants.themeModeKey), 'dark');
  });

  test('ThemeStore restores saved light mode', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.themeModeKey: 'light',
    });
    final store = await ThemeStore.create();

    expect(store.mode, ThemeMode.light);
  });

  test('ThemeStore skips notify when mode is unchanged', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await ThemeStore.create();
    var notifications = 0;
    store.addListener(() => notifications++);

    await store.setMode(ThemeMode.system);

    expect(notifications, 0);
  });
}
