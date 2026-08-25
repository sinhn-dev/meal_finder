import 'package:flutter/material.dart';

import '../models/meal.dart';

class MealCard extends StatelessWidget {
  const MealCard({super.key, required this.meal, required this.onTap});

  final MealSummary meal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                meal.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: Color(0xFFE7E0DC),
                  child: Icon(Icons.restaurant_outlined, size: 40),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                meal.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
