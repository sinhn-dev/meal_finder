import 'package:flutter/foundation.dart';

import '../config/app_constants.dart';
import '../models/meal.dart';
import '../services/meal_api.dart';

/// Contract for meal data. UI depends on this, not on Dio/`MealApi`.
abstract class MealRepository {
  Future<List<MealSummary>> search(String query);

  Future<List<MealSummary>> byCategory(String category);

  Future<Meal?> lookup(String id);

  Future<Meal?> random();

  Future<List<String>> categories();
}

/// Remote repository backed by TheMealDB via [MealApi].
class MealRepositoryImpl implements MealRepository {
  MealRepositoryImpl(
    this._api, {
    this.categoriesCacheTtl = AppConstants.categoriesCacheTtl,
  });

  final MealApi _api;
  final Duration categoriesCacheTtl;

  List<String>? _cachedCategories;
  DateTime? _categoriesCachedAt;

  @override
  Future<List<MealSummary>> search(String query) async {
    debugPrint('MealRepository: search query="$query"');
    return _api.search(query);
  }

  @override
  Future<List<MealSummary>> byCategory(String category) async {
    debugPrint('MealRepository: byCategory="$category"');
    return _api.byCategory(category);
  }

  @override
  Future<Meal?> lookup(String id) async {
    debugPrint('MealRepository: lookup id=$id');
    return _api.lookup(id);
  }

  @override
  Future<Meal?> random() async {
    debugPrint('MealRepository: random');
    return _api.random();
  }

  @override
  Future<List<String>> categories() async {
    final cached = _cachedCategories;
    final cachedAt = _categoriesCachedAt;
    if (cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < categoriesCacheTtl) {
      debugPrint('MealRepository: categories cache hit (${cached.length})');
      return cached;
    }

    debugPrint('MealRepository: categories fetch');
    final categories = await _api.categories();
    _cachedCategories = categories;
    _categoriesCachedAt = DateTime.now();
    return categories;
  }

  @visibleForTesting
  void clearCategoriesCache() {
    _cachedCategories = null;
    _categoriesCachedAt = null;
  }
}
