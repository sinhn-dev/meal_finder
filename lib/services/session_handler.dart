import 'package:flutter/material.dart';

import 'auth_store.dart';
import 'favorites_store.dart';
import 'search_history_store.dart';

/// Clears session state and surfaces a global snackbar on HTTP 401.
class SessionHandler {
  SessionHandler({
    required GlobalKey<ScaffoldMessengerState> messengerKey,
    required AuthStore auth,
    required FavoritesStore favorites,
    required SearchHistoryStore searchHistory,
  }) : _messengerKey = messengerKey,
       _auth = auth,
       _favorites = favorites,
       _searchHistory = searchHistory;

  final GlobalKey<ScaffoldMessengerState> _messengerKey;
  final AuthStore _auth;
  final FavoritesStore _favorites;
  final SearchHistoryStore _searchHistory;

  Future<void> handleUnauthorized() async {
    await _auth.handleUnauthorized();
    _favorites.clearSession();
    _searchHistory.clearSession();

    final messenger = _messengerKey.currentState;
    if (messenger == null) {
      return;
    }
    messenger.clearSnackBars();
    messenger.showSnackBar(
      const SnackBar(content: Text('Session expired. Please sign in again.')),
    );
  }
}
