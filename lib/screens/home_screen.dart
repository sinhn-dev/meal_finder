import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/app_constants.dart';
import '../models/meal.dart';
import '../providers/app_providers.dart';
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
  List<String> _categories = [];
  String? _selectedCategory;
  List<MealSummary> _meals = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
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
    _searchDebouncer.run(() => _search(keyword));
  }

  Future<void> _bootstrap() async {
    final api = ref.read(mealApiProvider);
    try {
      final categories = await api.categories();
      final firstCategory = categories.isNotEmpty ? categories.first : null;
      final meals = firstCategory == null
          ? await api.search('chicken')
          : await api.byCategory(firstCategory);
      if (!mounted) {
        return;
      }
      setState(() {
        _categories = categories;
        _selectedCategory = firstCategory;
        _meals = meals;
        _isLoading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _loadCategory(String category) async {
    _searchDebouncer.cancel();
    setState(() {
      _selectedCategory = category;
      _isLoading = true;
      _error = null;
    });
    try {
      final meals = await ref.read(mealApiProvider).byCategory(category);
      if (!mounted) {
        return;
      }
      setState(() {
        _meals = meals;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _search(String query) async {
    final keyword = SearchQuery.sanitize(query);
    if (keyword.isEmpty) {
      if (_categories.isNotEmpty) {
        await _loadCategory(_selectedCategory ?? _categories.first);
      }
      return;
    }

    debugPrint('HomeScreen: search="$keyword"');
    setState(() {
      _selectedCategory = null;
      _isLoading = true;
      _error = null;
    });
    try {
      final meals = await ref.read(mealApiProvider).search(keyword);
      if (!mounted) {
        return;
      }
      setState(() {
        _meals = meals;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _openRandom() async {
    try {
      final meal = await ref.read(mealApiProvider).random();
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

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(authStoreProvider).currentUser?.displayName;

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
          if (_selectedCategory != null) {
            await _loadCategory(_selectedCategory!);
            return;
          }
          await _search(_searchController.text);
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
                        onPressed: () {
                          _searchDebouncer.cancel();
                          _searchController.clear();
                          setState(() {});
                          if (_categories.isNotEmpty) {
                            _loadCategory(_categories.first);
                          }
                        },
                        icon: const Icon(Icons.close),
                      ),
                  ],
                  onChanged: _onQueryChanged,
                  onSubmitted: (value) {
                    _searchDebouncer.cancel();
                    _search(value);
                  },
                ),
              ),
            ),
            if (_categories.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 52,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return FilterChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (_) => _loadCategory(category),
                      );
                    },
                  ),
                ),
              ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: _EmptyState(
                  icon: Icons.wifi_off_outlined,
                  title: 'Cannot load meals',
                  message: _error!,
                  actionLabel: 'Retry',
                  onAction: _bootstrap,
                ),
              )
            else if (_meals.isEmpty)
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
                    final meal = _meals[index];
                    return MealCard(meal: meal, onTap: () => _openDetail(meal));
                  }, childCount: _meals.length),
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
