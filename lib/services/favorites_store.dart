import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_constants.dart';
import '../models/meal.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore._(this._prefs, this._meals);

  final SharedPreferences _prefs;
  List<MealSummary> _meals;

  List<MealSummary> get meals => List.unmodifiable(_meals);

  static Future<FavoritesStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(AppConstants.favoriteMealsKey) ?? [];
    final meals = raw
        .map(
          (item) =>
              MealSummary.fromJson(jsonDecode(item) as Map<String, dynamic>),
        )
        .toList();
    return FavoritesStore._(prefs, meals);
  }

  bool contains(String id) => _meals.any((meal) => meal.id == id);

  int indexOf(String id) => _meals.indexWhere((meal) => meal.id == id);

  Future<void> toggle(MealSummary meal) async {
    if (contains(meal.id)) {
      _meals = _meals.where((item) => item.id != meal.id).toList();
    } else {
      _meals = [..._meals, meal];
    }
    await _persist();
  }

  Future<MealSummary?> removeById(String id) async {
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
    if (contains(meal.id)) {
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
    final raw = _prefs.getStringList(AppConstants.favoriteMealsKey) ?? [];
    _meals = raw
        .map(
          (item) =>
              MealSummary.fromJson(jsonDecode(item) as Map<String, dynamic>),
        )
        .toList();
    debugPrint('FavoritesStore: reloaded ${_meals.length} items');
    notifyListeners();
  }

  Future<void> _persist() async {
    await _prefs.setStringList(
      AppConstants.favoriteMealsKey,
      _meals.map((item) => jsonEncode(item.toJson())).toList(),
    );
    notifyListeners();
  }
}
