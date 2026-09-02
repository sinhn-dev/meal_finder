import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meal_finder/repositories/auth_repository.dart';
import 'package:meal_finder/screens/login_screen.dart';
import 'package:meal_finder/services/auth_store.dart';
import 'package:meal_finder/services/token_storage.dart';

import 'helpers/pump_app.dart';

Future<AuthStore> createAuth() async {
  SharedPreferences.setMockInitialValues({});
  return AuthStore.create(
    repository: const AuthRepositoryImpl(delay: Duration.zero),
    tokenStorage: InMemoryTokenStorage(),
  );
}

void main() {
  testWidgets('shows login fields and button', (tester) async {
    final auth = await createAuth();
    await tester.pumpWidget(
      wrapWithProviders(const MaterialApp(home: LoginScreen()), auth: auth),
    );

    expect(find.text('Meal Finder'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'User name'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
  });

  testWidgets('shows Required when submitting empty fields', (tester) async {
    final auth = await createAuth();
    await tester.pumpWidget(
      wrapWithProviders(const MaterialApp(home: LoginScreen()), auth: auth),
    );

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Required'), findsNWidgets(2));
    expect(auth.isLoggedIn, isFalse);
  });

  testWidgets('shows invalid credentials for non-demo user', (tester) async {
    final auth = await createAuth();
    await tester.pumpWidget(
      wrapWithProviders(const MaterialApp(home: LoginScreen()), auth: auth),
    );

    await tester.enterText(find.byType(TextField).first, 'anna');
    await tester.enterText(find.byType(TextField).last, 'secret');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Invalid credentials'), findsOneWidget);
    expect(auth.isLoggedIn, isFalse);
  });

  testWidgets('logs in when demo credentials are provided', (tester) async {
    final auth = await createAuth();
    await tester.pumpWidget(
      wrapWithProviders(const MaterialApp(home: LoginScreen()), auth: auth),
    );

    await tester.enterText(find.byType(TextField).first, 'demo');
    await tester.enterText(find.byType(TextField).last, 'secret');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Required'), findsNothing);
    expect(auth.isLoggedIn, isTrue);
    expect(auth.currentUser?.userName, 'demo');
  });
}
