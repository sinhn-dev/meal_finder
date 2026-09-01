import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_providers.dart';
import 'services/auth_store.dart';
import 'services/favorites_store.dart';
import 'services/search_history_store.dart';
import 'services/theme_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = await AuthStore.create();
  final userId = auth.currentUser?.id;
  final favorites = await FavoritesStore.create(userId: userId);
  final searchHistory = await SearchHistoryStore.create(userId: userId);
  final theme = await ThemeStore.create();
  runApp(
    ProviderScope(
      overrides: [
        authStoreProvider.overrideWith((ref) => auth),
        favoritesStoreProvider.overrideWith((ref) => favorites),
        searchHistoryStoreProvider.overrideWith((ref) => searchHistory),
        themeStoreProvider.overrideWith((ref) => theme),
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
