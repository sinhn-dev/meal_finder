import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/meal.dart';
import '../utils/search_query.dart';
import 'app_providers.dart';

class HomeMealsState {
  const HomeMealsState({
    required this.categories,
    required this.selectedCategory,
    required this.meals,
    required this.isLoading,
    required this.error,
    required this.query,
    required this.isOffline,
    required this.isFromCache,
  });

  factory HomeMealsState.initial() {
    return const HomeMealsState(
      categories: [],
      selectedCategory: null,
      meals: [],
      isLoading: true,
      error: null,
      query: '',
      isOffline: false,
      isFromCache: false,
    );
  }

  final List<String> categories;
  final String? selectedCategory;
  final List<MealSummary> meals;
  final bool isLoading;
  final String? error;
  final String query;
  final bool isOffline;
  final bool isFromCache;

  HomeMealsState copyWith({
    List<String>? categories,
    String? selectedCategory,
    bool clearSelectedCategory = false,
    List<MealSummary>? meals,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? query,
    bool? isOffline,
    bool? isFromCache,
  }) {
    return HomeMealsState(
      categories: categories ?? this.categories,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      meals: meals ?? this.meals,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      query: query ?? this.query,
      isOffline: isOffline ?? this.isOffline,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

/// ViewModel for Discover/Home — fetch logic lives here, not in the Widget.
class HomeMealsNotifier extends StateNotifier<HomeMealsState> {
  HomeMealsNotifier(this._ref) : super(HomeMealsState.initial()) {
    _ref.listen<AsyncValue<bool>>(isOnlineProvider, (previous, next) {
      next.whenData((online) {
        state = state.copyWith(isOffline: !online);
      });
    }, fireImmediately: true);
  }

  final Ref _ref;

  Future<void> bootstrap() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = _ref.read(mealRepositoryProvider);
      final categoriesResult = await repo.categories();
      final categories = categoriesResult.data;
      final firstCategory = categories.isNotEmpty ? categories.first : null;
      final mealsResult = firstCategory == null
          ? await repo.search('chicken')
          : await repo.byCategory(firstCategory);
      state = state.copyWith(
        categories: categories,
        selectedCategory: firstCategory,
        clearSelectedCategory: firstCategory == null,
        meals: mealsResult.data,
        isLoading: false,
        clearError: true,
        query: '',
        isFromCache: categoriesResult.isFromCache || mealsResult.isFromCache,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> loadCategory(String category) async {
    state = state.copyWith(
      selectedCategory: category,
      isLoading: true,
      clearError: true,
      query: '',
    );
    try {
      final result = await _ref
          .read(mealRepositoryProvider)
          .byCategory(category);
      state = state.copyWith(
        meals: result.data,
        isLoading: false,
        clearError: true,
        isFromCache: result.isFromCache,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> search(String raw) async {
    final keyword = SearchQuery.sanitize(raw);
    if (keyword.isEmpty) {
      if (state.categories.isNotEmpty) {
        await loadCategory(state.selectedCategory ?? state.categories.first);
      }
      return;
    }

    debugPrint('HomeMealsNotifier: search="$keyword"');
    state = state.copyWith(
      clearSelectedCategory: true,
      isLoading: true,
      clearError: true,
      query: keyword,
    );
    try {
      final result = await _ref.read(mealRepositoryProvider).search(keyword);
      await _ref.read(searchHistoryStoreProvider).add(keyword);
      state = state.copyWith(
        meals: result.data,
        isLoading: false,
        clearError: true,
        isFromCache: result.isFromCache,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> refresh() async {
    final selected = state.selectedCategory;
    if (selected != null) {
      await loadCategory(selected);
      return;
    }
    final query = state.query;
    if (query.isNotEmpty) {
      await search(query);
      return;
    }
    await bootstrap();
  }

  Future<Meal?> openRandom() {
    return _ref.read(mealRepositoryProvider).random();
  }
}

final homeMealsProvider =
    StateNotifierProvider<HomeMealsNotifier, HomeMealsState>((ref) {
      return HomeMealsNotifier(ref);
    });
