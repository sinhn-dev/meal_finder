import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meal_finder/services/connectivity_service.dart';

void main() {
  test('isOnlineFromResults is false for empty or none-only', () {
    expect(ConnectivityService.isOnlineFromResults(const []), isFalse);
    expect(
      ConnectivityService.isOnlineFromResults(const [ConnectivityResult.none]),
      isFalse,
    );
  });

  test('isOnlineFromResults is true when any non-none result exists', () {
    expect(
      ConnectivityService.isOnlineFromResults(const [ConnectivityResult.wifi]),
      isTrue,
    );
    expect(
      ConnectivityService.isOnlineFromResults(const [
        ConnectivityResult.none,
        ConnectivityResult.mobile,
      ]),
      isTrue,
    );
  });
}
