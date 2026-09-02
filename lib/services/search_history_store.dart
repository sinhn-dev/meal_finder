import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_constants.dart';
import '../utils/search_query.dart';

class SearchHistoryStore extends ChangeNotifier {
  SearchHistoryStore._(this._prefs, this._userId, this._keywords);

  final SharedPreferences _prefs;
  String? _userId;
  List<String> _keywords;

  String? get userId => _userId;
  List<String> get keywords => List.unmodifiable(_keywords);

  static Future<SearchHistoryStore> create({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final store = SearchHistoryStore._(prefs, userId, []);
    if (userId != null) {
      await store._loadForUser(userId);
    }
    return store;
  }

  Future<void> switchUser(String userId) async {
    if (_userId == userId) {
      await reload();
      return;
    }

    _userId = userId;
    debugPrint(
      'SearchHistoryStore: switchUser=$userId '
      'key=${AppConstants.searchHistoryKeyFor(userId)}',
    );
    await _loadForUser(userId);
    notifyListeners();
  }

  void clearSession() {
    debugPrint('SearchHistoryStore: clearSession');
    _userId = null;
    _keywords = [];
    notifyListeners();
  }

  Future<void> add(String raw) async {
    if (_userId == null) {
      return;
    }

    final keyword = SearchQuery.sanitize(raw);
    if (keyword.isEmpty) {
      return;
    }

    final next = [
      keyword,
      ..._keywords.where((item) => item.toLowerCase() != keyword.toLowerCase()),
    ];
    if (next.length > AppConstants.searchHistoryMaxItems) {
      next.removeRange(AppConstants.searchHistoryMaxItems, next.length);
    }

    _keywords = next;
    debugPrint(
      'SearchHistoryStore: add "$keyword" (${_keywords.length} items)',
    );
    await _persist();
  }

  Future<void> reload() async {
    final userId = _userId;
    if (userId == null) {
      return;
    }
    await _loadForUser(userId);
    debugPrint(
      'SearchHistoryStore: reloaded ${_keywords.length} items for $userId',
    );
    notifyListeners();
  }

  Future<void> _loadForUser(String userId) async {
    final key = AppConstants.searchHistoryKeyFor(userId);
    _keywords = _prefs.getStringList(key) ?? [];
  }

  Future<void> _persist() async {
    final userId = _userId;
    if (userId == null) {
      return;
    }
    await _prefs.setStringList(
      AppConstants.searchHistoryKeyFor(userId),
      _keywords,
    );
    notifyListeners();
  }
}
