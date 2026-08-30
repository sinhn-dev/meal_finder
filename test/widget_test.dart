import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meal_finder/screens/favorites_screen.dart';
import 'package:meal_finder/services/favorites_store.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('shows empty favorites state', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final favorites = await FavoritesStore.create(userId: 'mock-test');

    await tester.pumpWidget(
      wrapWithProviders(
        const MaterialApp(home: FavoritesScreen()),
        favorites: favorites,
      ),
    );

    expect(find.text('No favorites yet'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
  });
}
