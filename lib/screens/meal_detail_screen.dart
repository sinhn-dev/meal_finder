import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/meal.dart';
import '../providers/app_providers.dart';

class MealDetailScreen extends ConsumerStatefulWidget {
  const MealDetailScreen({
    super.key,
    required this.mealId,
    required this.mealName,
    this.thumbnail,
  });

  final String mealId;
  final String mealName;
  final String? thumbnail;

  @override
  ConsumerState<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends ConsumerState<MealDetailScreen> {
  late Future<Meal?> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(mealRepositoryProvider).lookup(widget.mealId);
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesStoreProvider);
    final isFavorite = favorites.contains(widget.mealId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealName),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Remove favorite' : 'Save favorite',
            onPressed: () {
              favorites.toggle(
                MealSummary(
                  id: widget.mealId,
                  name: widget.mealName,
                  thumbnail: widget.thumbnail ?? '',
                ),
              );
            },
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: FutureBuilder<Meal?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _Message(
              icon: Icons.wifi_off_outlined,
              text: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _future = ref
                      .read(mealRepositoryProvider)
                      .lookup(widget.mealId);
                });
              },
            );
          }
          final meal = snapshot.data;
          if (meal == null) {
            return const _Message(
              icon: Icons.restaurant_outlined,
              text: 'Recipe not found.',
            );
          }
          return _MealBody(meal: meal);
        },
      ),
    );
  }
}

class _MealBody extends StatelessWidget {
  const _MealBody({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (meal.thumbnail.isNotEmpty)
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Image.network(
              meal.thumbnail,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: Color(0xFFE7E0DC),
                child: Icon(Icons.restaurant_outlined, size: 48),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(meal.name, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (meal.category != null && meal.category!.isNotEmpty)
                    Chip(label: Text(meal.category!)),
                  if (meal.area != null && meal.area!.isNotEmpty)
                    Chip(label: Text(meal.area!)),
                ],
              ),
              const SizedBox(height: 24),
              Text('Ingredients', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...meal.ingredients.map(
                (ingredient) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(ingredient.name),
                  trailing: Text(ingredient.measure),
                ),
              ),
              const SizedBox(height: 16),
              Text('Instructions', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                meal.instructions ?? 'No instructions available.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Text(
                'Recipe data and imagery: TheMealDB',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.onRetry});

  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

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
            Text(text, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
