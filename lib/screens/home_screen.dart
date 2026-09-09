import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/app_constants.dart';
import '../models/meal.dart';
import '../providers/app_providers.dart';
import '../providers/home_meals_notifier.dart';
import '../router/app_routes.dart';
import '../utils/debouncer.dart';
import '../utils/search_query.dart';
import '../widgets/meal_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _searchDebouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeMealsProvider.notifier).bootstrap());
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String raw) {
    final keyword = SearchQuery.sanitize(raw);
    if (raw.length > AppConstants.searchMaxLength) {
      _searchController.value = TextEditingValue(
        text: keyword,
        selection: TextSelection.collapsed(offset: keyword.length),
      );
    }
    setState(() {});
    _searchDebouncer.run(() {
      ref.read(homeMealsProvider.notifier).search(keyword);
    });
  }

  Future<void> _searchFromHistory(String keyword) async {
    _searchDebouncer.cancel();
    _searchController.value = TextEditingValue(
      text: keyword,
      selection: TextSelection.collapsed(offset: keyword.length),
    );
    setState(() {});
    await ref.read(homeMealsProvider.notifier).search(keyword);
  }

  Future<void> _openRandom() async {
    try {
      final meal = await ref.read(homeMealsProvider.notifier).openRandom();
      if (!mounted || meal == null) {
        return;
      }
      _openDetail(meal.summary);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void _openDetail(MealSummary meal) {
    context.push(AppRoutes.meal(meal.id), extra: meal);
  }

  void _clearSearch() {
    _searchDebouncer.cancel();
    _searchController.clear();
    setState(() {});
    final categories = ref.read(homeMealsProvider).categories;
    if (categories.isNotEmpty) {
      ref.read(homeMealsProvider.notifier).loadCategory(categories.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(authStoreProvider).currentUser?.displayName;
    final recentSearches = ref.watch(searchHistoryStoreProvider).keywords;
    final home = ref.watch(homeMealsProvider);
    final notifier = ref.read(homeMealsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Meal Finder'),
            if (name != null && name.isNotEmpty)
              Text('Hi, $name', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Random meal',
            onPressed: _openRandom,
            icon: const Icon(Icons.casino_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _searchDebouncer.cancel();
          await notifier.refresh();
          final next = ref.read(homeMealsProvider);
          if (next.query.isEmpty) {
            _searchController.clear();
          } else {
            _searchController.value = TextEditingValue(
              text: next.query,
              selection: TextSelection.collapsed(offset: next.query.length),
            );
          }
          setState(() {});
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Search pasta, chicken, curry...',
                  leading: const Icon(Icons.search),
                  trailing: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.close),
                      ),
                  ],
                  onChanged: _onQueryChanged,
                  onSubmitted: (value) {
                    _searchDebouncer.cancel();
                    notifier.search(value);
                  },
                ),
              ),
            ),
            if (recentSearches.isNotEmpty)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        'Recent searches',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: recentSearches.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final keyword = recentSearches[index];
                          return ActionChip(
                            avatar: const Icon(Icons.history, size: 18),
                            label: Text(keyword),
                            onPressed: () => _searchFromHistory(keyword),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            if (home.categories.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 52,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: home.categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = home.categories[index];
                      return FilterChip(
                        label: Text(category),
                        selected: home.selectedCategory == category,
                        onSelected: (_) {
                          _searchDebouncer.cancel();
                          _searchController.clear();
                          setState(() {});
                          notifier.loadCategory(category);
                        },
                      );
                    },
                  ),
                ),
              ),
            if (home.isFromCache && !home.isLoading && home.error == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      avatar: const Icon(Icons.offline_bolt_outlined, size: 18),
                      label: Text(
                        home.isOffline
                            ? 'Cached meals'
                            : 'Showing cached results',
                      ),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ),
            if (home.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (home.error != null)
              SliverFillRemaining(
                child: _EmptyState(
                  icon: Icons.wifi_off_outlined,
                  title: 'Cannot load meals',
                  message: home.error!,
                  actionLabel: 'Retry',
                  onAction: notifier.bootstrap,
                ),
              )
            else if (home.meals.isEmpty)
              const SliverFillRemaining(
                child: _EmptyState(
                  icon: Icons.soup_kitchen_outlined,
                  title: 'No meals found',
                  message: 'Try another keyword or pick a category.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final meal = home.meals[index];
                    return MealCard(meal: meal, onTap: () => _openDetail(meal));
                  }, childCount: home.meals.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
