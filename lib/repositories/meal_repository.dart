import 'package:flutter/foundation.dart';

import '../config/app_constants.dart';
import '../data/local/meal_cache_keys.dart';
import '../data/local/meal_local_data_source.dart';
import '../models/fetch_result.dart';
import '../models/meal.dart';
import '../services/meal_api.dart';

/// Contract for meal data. UI depends on this, not on Dio/`MealApi`.
abstract class MealRepository {
  Future<FetchResult<List<MealSummary>>> search(String query);

  Future<FetchResult<List<MealSummary>>> byCategory(String category);

  Future<FetchResult<List<MealSummary>>> byArea(String area);

  Future<Meal?> lookup(String id);

  Future<Meal?> random();

  Future<FetchResult<List<String>>> categories();

  /// Read previously persisted list cache (offline / fallback).
  Future<List<MealSummary>> getCachedBySourceKey(String sourceKey);

  Future<List<String>> getCachedCategories();
}

/// Remote repository backed by TheMealDB via [MealApi], with optional Drift cache.
class MealRepositoryImpl implements MealRepository {
  MealRepositoryImpl(
    this._api, {
    MealLocalDataSource? local,
    Future<bool> Function()? isOnline,
    this.categoriesCacheTtl = AppConstants.categoriesCacheTtl,
  }) : _local = local,
       _isOnline = isOnline ?? _alwaysOnline;

  final MealApi _api;
  final MealLocalDataSource? _local;
  final Future<bool> Function() _isOnline;
  final Duration categoriesCacheTtl;

  List<String>? _cachedCategories;
  DateTime? _categoriesCachedAt;

  static Future<bool> _alwaysOnline() async => true;

  Future<bool> _online() => _isOnline();

  Future<FetchResult<List<MealSummary>>> _mealsWithCache({
    required String sourceKey,
    required String label,
    required Future<List<MealSummary>> Function() fetchRemote,
  }) async {
    if (!await _online()) {
      debugPrint('MealRepository: offline $label → cache key=$sourceKey');
      final cached = await getCachedBySourceKey(sourceKey);
      if (cached.isEmpty) {
        throw const MealApiException(
          "You're offline and no cached meals are available for this request.",
        );
      }
      return FetchResult(cached, isFromCache: true);
    }

    try {
      debugPrint('MealRepository: $label');
      final meals = await fetchRemote();
      await _local?.replaceMealsForSource(sourceKey, meals);
      return FetchResult(meals);
    } catch (error, stackTrace) {
      debugPrint('MealRepository: $label failed, trying cache: $error');
      final cached = await getCachedBySourceKey(sourceKey);
      if (cached.isNotEmpty) {
        return FetchResult(cached, isFromCache: true);
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  @override
  Future<FetchResult<List<MealSummary>>> search(String query) {
    return _mealsWithCache(
      sourceKey: MealCacheKeys.search(query),
      label: 'search query="$query"',
      fetchRemote: () => _api.search(query),
    );
  }

  @override
  Future<FetchResult<List<MealSummary>>> byCategory(String category) {
    return _mealsWithCache(
      sourceKey: MealCacheKeys.category(category),
      label: 'byCategory="$category"',
      fetchRemote: () => _api.byCategory(category),
    );
  }

  @override
  Future<FetchResult<List<MealSummary>>> byArea(String area) {
    return _mealsWithCache(
      sourceKey: MealCacheKeys.area(area),
      label: 'byArea="$area"',
      fetchRemote: () => _api.byArea(area),
    );
  }

  @override
  Future<Meal?> lookup(String id) async {
    if (!await _online()) {
      debugPrint('MealRepository: offline lookup id=$id');
      throw const MealApiException(
        "You're offline. Meal details need a network connection.",
      );
    }
    debugPrint('MealRepository: lookup id=$id');
    return _api.lookup(id);
  }

  @override
  Future<Meal?> random() async {
    if (!await _online()) {
      debugPrint('MealRepository: offline random');
      throw const MealApiException(
        "You're offline. Random meal needs a network connection.",
      );
    }
    debugPrint('MealRepository: random');
    return _api.random();
  }

  @override
  Future<FetchResult<List<String>>> categories() async {
    final cached = _cachedCategories;
    final cachedAt = _categoriesCachedAt;
    if (cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < categoriesCacheTtl) {
      debugPrint(
        'MealRepository: categories memory cache hit (${cached.length})',
      );
      return FetchResult(cached);
    }

    if (!await _online()) {
      debugPrint('MealRepository: offline categories → Drift');
      final localCats = await getCachedCategories();
      if (localCats.isEmpty) {
        throw const MealApiException(
          "You're offline and no cached categories are available.",
        );
      }
      _cachedCategories = localCats;
      _categoriesCachedAt = DateTime.now();
      return FetchResult(localCats, isFromCache: true);
    }

    try {
      debugPrint('MealRepository: categories fetch');
      final categories = await _api.categories();
      _cachedCategories = categories;
      _categoriesCachedAt = DateTime.now();
      await _local?.replaceCategories(categories);
      return FetchResult(categories);
    } catch (error, stackTrace) {
      debugPrint('MealRepository: categories failed, trying cache: $error');
      final localCats = await getCachedCategories();
      if (localCats.isNotEmpty) {
        _cachedCategories = localCats;
        _categoriesCachedAt = DateTime.now();
        return FetchResult(localCats, isFromCache: true);
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
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
