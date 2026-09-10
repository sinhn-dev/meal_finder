import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/meal.dart';
import '../screens/app_shell.dart';
import '../screens/favorites_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/meal_detail_screen.dart';
import '../screens/near_me_screen.dart';
import '../screens/profile_screen.dart';
import '../services/auth_store.dart';
import 'app_routes.dart';
import 'auth_redirect.dart';

GoRouter createAppRouter(AuthStore auth) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: auth,
    redirect: (context, state) {
      final next = authRedirect(
        isLoggedIn: auth.isLoggedIn,
        location: state.matchedLocation,
      );
      if (next != null) {
        debugPrint(
          'GoRouter redirect ${state.matchedLocation} -> $next '
          '(loggedIn=${auth.isLoggedIn})',
        );
      }
      return next;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.favorites,
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.nearMe,
        builder: (context, state) => const NearMeScreen(),
      ),
      GoRoute(
        path: '/meals/:id',
        builder: (context, state) {
          final extra = state.extra as MealSummary?;
          return MealDetailScreen(
            mealId: state.pathParameters['id']!,
            mealName: extra?.name ?? 'Meal',
            thumbnail: extra?.thumbnail,
          );
        },
      ),
    ],
  );
}
