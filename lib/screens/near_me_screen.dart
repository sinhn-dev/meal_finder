import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../models/meal.dart';
import '../providers/near_me_notifier.dart';
import '../router/app_routes.dart';
import '../services/location_service.dart';
import '../widgets/meal_card.dart';

class NearMeScreen extends ConsumerStatefulWidget {
  const NearMeScreen({super.key});

  @override
  ConsumerState<NearMeScreen> createState() => _NearMeScreenState();
}

class _NearMeScreenState extends ConsumerState<NearMeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(nearMeProvider.notifier).load());
  }

  void _openDetail(MealSummary meal) {
    context.push(AppRoutes.meal(meal.id), extra: meal);
  }

  Future<void> _showPermissionHelp(NearMeState state) async {
    final needsSettings =
        state.failureReason == LocationFailureReason.deniedForever ||
        state.failureReason == LocationFailureReason.serviceDisabled;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Location needed'),
          content: Text(
            state.error ?? 'Allow location access to try the Near me demo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Not now'),
            ),
            if (needsSettings)
              FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await ref.read(nearMeProvider.notifier).openSettings();
                },
                child: const Text('Open Settings'),
              )
            else
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(nearMeProvider.notifier).load();
                },
                child: const Text('Try again'),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nearMeProvider);
    final scheme = Theme.of(context).colorScheme;

    ref.listen<NearMeState>(nearMeProvider, (previous, next) {
      final becamePermissionError =
          next.failureReason != null &&
          previous?.failureReason != next.failureReason;
      if (becamePermissionError && mounted) {
        _showPermissionHelp(next);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Near me (demo)'),
        actions: [
          IconButton(
            tooltip: 'Retry',
            onPressed: state.isLoading
                ? null
                : () => ref.read(nearMeProvider.notifier).load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Material(
            color: scheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: scheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Demo mapping, not real restaurants',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _buildBody(context, state)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, NearMeState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.failureReason != null ||
        (state.error != null && !state.hasPosition)) {
      return _ErrorPane(
        message: state.error ?? 'Something went wrong.',
        actionLabel:
            state.failureReason == LocationFailureReason.deniedForever ||
                state.failureReason == LocationFailureReason.serviceDisabled
            ? 'Open Settings'
            : 'Try again',
        onAction: () async {
          if (state.failureReason == LocationFailureReason.deniedForever ||
              state.failureReason == LocationFailureReason.serviceDisabled) {
            await ref.read(nearMeProvider.notifier).openSettings();
          } else {
            await ref.read(nearMeProvider.notifier).load();
          }
        },
      );
    }

    final lat = state.latitude!;
    final lng = state.longitude!;
    final point = LatLng(lat, lng);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 220,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: 12,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.learnflutter.meal_finder',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.error,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cuisine area: ${state.area ?? '—'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}'
                  '${state.isFromCache ? ' · cached' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        if (state.error != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                state.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          )
        else if (state.meals.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('No meals found for this area.')),
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
                final meal = state.meals[index];
                return MealCard(meal: meal, onTap: () => _openDetail(meal));
              }, childCount: state.meals.length),
            ),
          ),
      ],
    );
  }
}

class _ErrorPane extends StatelessWidget {
  const _ErrorPane({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              'Cannot use Near me',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
