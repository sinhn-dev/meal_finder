import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class CachedMeals extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get thumbnail => text()();
  TextColumn get category => text().nullable()();
  TextColumn get area => text().nullable()();
  TextColumn get sourceKey => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id, sourceKey};
}

class CachedCategories extends Table {
  TextColumn get name => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}

@DriftDatabase(tables: [CachedMeals, CachedCategories])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'meal_finder');
  }
}
