import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around [Connectivity] — injectable for tests.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return isOnlineFromResults(results);
  }

  /// Emits whenever connectivity changes (does not replay the current value).
  Stream<bool> get onStatusChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      final online = isOnlineFromResults(results);
      debugPrint('ConnectivityService: online=$online ($results)');
      return online;
    });
  }

  @visibleForTesting
  static bool isOnlineFromResults(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return false;
    }
    return results.any((result) => result != ConnectivityResult.none);
  }
}
