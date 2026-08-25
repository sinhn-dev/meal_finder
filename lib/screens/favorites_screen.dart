import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/meal.dart';
import '../providers/app_providers.dart';
import '../router/app_routes.dart';
import '../widgets/meal_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  Future<void> _removeWithUndo(
    BuildContext context,
    WidgetRef ref,
    MealSummary meal,
    int index,
  ) async {
    final favorites = ref.read(favoritesStoreProvider);
    await favorites.removeById(meal.id);
    if (!context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Removed ${meal.name}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            favorites.insertAt(index, meal);
          },
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, MealSummary meal) {
    context.push(AppRoutes.meal(meal.id), extra: meal);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesStoreProvider);
    final meals = favorites.meals;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: meals.isEmpty
          ? RefreshIndicator(
              onRefresh: favorites.reload,
              child: const CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite_border, size: 48),
                            SizedBox(height: 12),
                            Text('No favorites yet'),
                            SizedBox(height: 8),
                            Text(
                              'Open a recipe and tap the heart icon to save it here.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: favorites.reload,
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  return Dismissible(
                    key: ValueKey(meal.id),
                    direction: DismissDirection.endToStart,
                    background: const _DeleteBackground(),
                    onDismissed: (_) {
                      _removeWithUndo(context, ref, meal, index);
                    },
                    child: MealCard(
                      meal: meal,
                      onTap: () => _openDetail(context, meal),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(Icons.delete_outline, color: Colors.white),
        ),
      ),
    );
  }
}
