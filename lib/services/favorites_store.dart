import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_constants.dart';
import '../models/meal.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore._(this._prefs, this._userId, this._meals);

  final SharedPreferences _prefs;
  String? _userId;
  List<MealSummary> _meals;

  String? get userId => _userId;
  List<MealSummary> get meals => List.unmodifiable(_meals);

  static Future<FavoritesStore> create({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final store = FavoritesStore._(prefs, userId, []);
    if (userId != null) {
      await store._loadForUser(userId, migrateLegacy: true);
    }
    return store;
  }

  /// Load favorites for another account after login or user switch.
  Future<void> switchUser(String userId) async {
    if (_userId == userId) {
      await reload();
      return;
    }

    _userId = userId;
    debugPrint(
      'FavoritesStore: switchUser=$userId '
      'key=${AppConstants.favoriteMealsKeyFor(userId)}',
    );
    await _loadForUser(userId, migrateLegacy: true);
    notifyListeners();
  }

  /// Clear in-memory list on logout (persisted data stays per user).
  void clearSession() {
    debugPrint('FavoritesStore: clearSession');
    _userId = null;
    _meals = [];
    notifyListeners();
  }

  bool contains(String id) => _meals.any((meal) => meal.id == id);

  int indexOf(String id) => _meals.indexWhere((meal) => meal.id == id);

  Future<void> toggle(MealSummary meal) async {
    if (_userId == null) {
      return;
    }
    if (contains(meal.id)) {
      _meals = _meals.where((item) => item.id != meal.id).toList();
    } else {
      _meals = [..._meals, meal];
    }
    await _persist();
  }

  Future<MealSummary?> removeById(String id) async {
    if (_userId == null) {
      return null;
    }
    final index = indexOf(id);
    if (index < 0) {
      return null;
    }
    final meal = _meals[index];
    _meals = [..._meals]..removeAt(index);
    debugPrint('FavoritesStore: removed ${meal.id}');
    await _persist();
    return meal;
  }

  Future<void> insertAt(int index, MealSummary meal) async {
    if (_userId == null || contains(meal.id)) {
      return;
    }
    final next = [..._meals];
    final clamped = index.clamp(0, next.length);
    next.insert(clamped, meal);
    _meals = next;
    debugPrint('FavoritesStore: restored ${meal.id} at $clamped');
    await _persist();
  }

  Future<void> reload() async {
    final userId = _userId;
    if (userId == null) {
      return;
    }
    await _loadForUser(userId);
    debugPrint('FavoritesStore: reloaded ${_meals.length} items for $userId');
    notifyListeners();
  }

  Future<void> _loadForUser(String userId, {bool migrateLegacy = false}) async {
    final key = AppConstants.favoriteMealsKeyFor(userId);
    var raw = _prefs.getStringList(key);

    if ((raw == null || raw.isEmpty) && migrateLegacy) {
      final legacy = _prefs.getStringList(AppConstants.favoriteMealsKey);
      if (legacy != null && legacy.isNotEmpty) {
        await _prefs.setStringList(key, legacy);
        await _prefs.remove(AppConstants.favoriteMealsKey);
        raw = legacy;
        debugPrint('FavoritesStore: migrated legacy favorites to $key');
      }
    }

    _meals = _decodeMeals(raw ?? []);
  }

  List<MealSummary> _decodeMeals(List<String> raw) {
    return raw
        .map(
          (item) =>
              MealSummary.fromJson(jsonDecode(item) as Map<String, dynamic>),
        )
        .toList();
  }

  String? get _storageKey {
    final userId = _userId;
    if (userId == null) {
      return null;
    }
    return AppConstants.favoriteMealsKeyFor(userId);
  }

  Future<void> _persist() async {
    final key = _storageKey;
    if (key == null) {
      return;
    }
    await _prefs.setStringList(
      key,
      _meals.map((item) => jsonEncode(item.toJson())).toList(),
    );
    notifyListeners();
  }
}
