import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meal_finder/providers/app_providers.dart';
import 'package:meal_finder/services/auth_store.dart';
import 'package:meal_finder/services/favorites_store.dart';

List<Override> appOverrides({AuthStore? auth, FavoritesStore? favorites}) {
  return [
    if (auth != null) authStoreProvider.overrideWith((ref) => auth),
    if (favorites != null)
      favoritesStoreProvider.overrideWith((ref) => favorites),
  ];
}

Widget wrapWithProviders(
  Widget child, {
  AuthStore? auth,
  FavoritesStore? favorites,
}) {
  return ProviderScope(
    overrides: appOverrides(auth: auth, favorites: favorites),
    child: child,
  );
}
