import 'package:flutter/foundation.dart';

import '../config/app_constants.dart';
import '../data/local/meal_cache_keys.dart';
import '../data/local/meal_local_data_source.dart';
import '../models/meal.dart';
import '../services/meal_api.dart';

/// Contract for meal data. UI depends on this, not on Dio/`MealApi`.
abstract class MealRepository {
  Future<List<MealSummary>> search(String query);

  Future<List<MealSummary>> byCategory(String category);

  Future<Meal?> lookup(String id);

  Future<Meal?> random();

  Future<List<String>> categories();

  /// Read previously persisted list cache (used by offline path in P4).
  Future<List<MealSummary>> getCachedBySourceKey(String sourceKey);

  Future<List<String>> getCachedCategories();
}

/// Remote repository backed by TheMealDB via [MealApi], with optional Drift cache.
class MealRepositoryImpl implements MealRepository {
  MealRepositoryImpl(
    this._api, {
    MealLocalDataSource? local,
    this.categoriesCacheTtl = AppConstants.categoriesCacheTtl,
  }) : _local = local;

  final MealApi _api;
  final MealLocalDataSource? _local;
  final Duration categoriesCacheTtl;

  List<String>? _cachedCategories;
  DateTime? _categoriesCachedAt;

  @override
  Future<List<MealSummary>> search(String query) async {
    debugPrint('MealRepository: search query="$query"');
    final meals = await _api.search(query);
    await _local?.replaceMealsForSource(MealCacheKeys.search(query), meals);
    return meals;
  }

  @override
  Future<List<MealSummary>> byCategory(String category) async {
    debugPrint('MealRepository: byCategory="$category"');
    final meals = await _api.byCategory(category);
    await _local?.replaceMealsForSource(
      MealCacheKeys.category(category),
      meals,
    );
    return meals;
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
      debugPrint(
        'MealRepository: categories memory cache hit (${cached.length})',
      );
      return cached;
    }

    debugPrint('MealRepository: categories fetch');
    final categories = await _api.categories();
    _cachedCategories = categories;
    _categoriesCachedAt = DateTime.now();
    await _local?.replaceCategories(categories);
    return categories;
  }

  @override
  Future<List<MealSummary>> getCachedBySourceKey(String sourceKey) async {
    return _local?.getMealsBySourceKey(sourceKey) ?? const [];
  }

  @override
  Future<List<String>> getCachedCategories() async {
    return _local?.getCategories() ?? const [];
  }

  @visibleForTesting
  void clearCategoriesCache() {
    _cachedCategories = null;
    _categoriesCachedAt = null;
  }
}
