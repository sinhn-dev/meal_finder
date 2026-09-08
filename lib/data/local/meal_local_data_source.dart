import 'package:flutter/foundation.dart';

import '../../models/meal.dart';
import 'app_database.dart';

class MealLocalDataSource {
  MealLocalDataSource(this._db);

  final AppDatabase _db;

  Future<void> replaceMealsForSource(
    String sourceKey,
    List<MealSummary> meals,
  ) async {
    debugPrint(
      'MealLocalDataSource: write ${meals.length} meals sourceKey=$sourceKey',
    );
    await _db.transaction(() async {
      await (_db.delete(
        _db.cachedMeals,
      )..where((row) => row.sourceKey.equals(sourceKey))).go();

      if (meals.isEmpty) {
        return;
      }

      final now = DateTime.now();
      await _db.batch((batch) {
        batch.insertAll(
          _db.cachedMeals,
          meals
              .map(
                (meal) => CachedMealsCompanion.insert(
                  id: meal.id,
                  name: meal.name,
                  thumbnail: meal.thumbnail,
                  sourceKey: sourceKey,
                  updatedAt: now,
                ),
              )
              .toList(),
        );
      });
    });
  }

  Future<List<MealSummary>> getMealsBySourceKey(String sourceKey) async {
    final rows = await (_db.select(
      _db.cachedMeals,
    )..where((row) => row.sourceKey.equals(sourceKey))).get();
    debugPrint(
      'MealLocalDataSource: read ${rows.length} meals sourceKey=$sourceKey',
    );
    return rows
        .map(
          (row) =>
              MealSummary(id: row.id, name: row.name, thumbnail: row.thumbnail),
        )
        .toList();
  }

  Future<void> replaceCategories(List<String> names) async {
    debugPrint('MealLocalDataSource: write ${names.length} categories');
    await _db.transaction(() async {
      await _db.delete(_db.cachedCategories).go();
      if (names.isEmpty) {
        return;
      }
      final now = DateTime.now();
      await _db.batch((batch) {
        batch.insertAll(
          _db.cachedCategories,
          names
              .map(
                (name) => CachedCategoriesCompanion.insert(
                  name: name,
                  updatedAt: now,
                ),
              )
              .toList(),
        );
      });
    });
  }

  Future<List<String>> getCategories() async {
    final rows = await _db.select(_db.cachedCategories).get();
    debugPrint('MealLocalDataSource: read ${rows.length} categories');
    return rows.map((row) => row.name).toList();
  }
}
