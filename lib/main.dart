import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dio/dio.dart';

import 'data/local/app_database.dart';
import 'data/local/meal_local_data_source.dart';
import 'providers/app_providers.dart';
import 'services/api_client.dart';
import 'services/auth_store.dart';
import 'services/favorites_store.dart';
import 'services/meal_api.dart';
import 'services/search_history_store.dart';
import 'services/session_handler.dart';
import 'services/theme_store.dart';
import 'services/token_storage.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = SecureTokenStorage();
  final auth = await AuthStore.create(tokenStorage: tokenStorage);
  final userId = auth.currentUser?.id;
  final favorites = await FavoritesStore.create(userId: userId);
  final searchHistory = await SearchHistoryStore.create(userId: userId);
  final theme = await ThemeStore.create();
  final database = AppDatabase();
  final mealLocal = MealLocalDataSource(database);

  final sessionHandler = SessionHandler(
    messengerKey: scaffoldMessengerKey,
    auth: auth,
    favorites: favorites,
    searchHistory: searchHistory,
  );

  final mealApi = MealApi(
    dio: ApiClient(
      tokenStorage: tokenStorage,
      onUnauthorized: sessionHandler.handleUnauthorized,
      baseOptions: BaseOptions(
        baseUrl: 'https://www.themealdb.com/api/json/v1/1/',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    ).create(),
  );

  runApp(
    ProviderScope(
      overrides: [
        authStoreProvider.overrideWith((ref) => auth),
        favoritesStoreProvider.overrideWith((ref) => favorites),
        searchHistoryStoreProvider.overrideWith((ref) => searchHistory),
        themeStoreProvider.overrideWith((ref) => theme),
        mealApiProvider.overrideWith((ref) => mealApi),
        mealLocalDataSourceProvider.overrideWith((ref) => mealLocal),
      ],
      child: const MealFinderApp(),
    ),
  );
}

class MealFinderApp extends ConsumerWidget {
  const MealFinderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const seed = Color(0xFFE07A5F);
    final theme = ref.watch(themeStoreProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Meal Finder',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: theme.mode,
      routerConfig: router,
    );
  }
}
