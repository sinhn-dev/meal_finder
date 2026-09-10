import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:meal_finder/services/location_service.dart';

void main() {
  Position position() {
    return Position(
      latitude: 21.0,
      longitude: 105.8,
      timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      accuracy: 1,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  test('returns position when permission is granted', () async {
    final service = LocationService(
      isLocationServiceEnabled: () async => true,
      checkPermission: () async => LocationPermission.whileInUse,
      getCurrentPosition: () async => position(),
    );

    final result = await service.getCurrentPosition();
    expect(result.latitude, 21.0);
    expect(result.longitude, 105.8);
  });

  test('throws denied when user denies request', () async {
    final service = LocationService(
      isLocationServiceEnabled: () async => true,
      checkPermission: () async => LocationPermission.denied,
      requestPermission: () async => LocationPermission.denied,
    );

    expect(
      () => service.getCurrentPosition(),
      throwsA(
        isA<LocationException>().having(
          (e) => e.reason,
          'reason',
          LocationFailureReason.denied,
        ),
      ),
    );
  });

  test('throws deniedForever when permanently denied', () async {
    final service = LocationService(
      isLocationServiceEnabled: () async => true,
      checkPermission: () async => LocationPermission.deniedForever,
    );

    expect(
      () => service.getCurrentPosition(),
      throwsA(
        isA<LocationException>().having(
          (e) => e.reason,
          'reason',
          LocationFailureReason.deniedForever,
        ),
      ),
    );
  });

  test('throws serviceDisabled when GPS is off', () async {
    final service = LocationService(
      isLocationServiceEnabled: () async => false,
    );

    expect(
      () => service.getCurrentPosition(),
      throwsA(
        isA<LocationException>().having(
          (e) => e.reason,
          'reason',
          LocationFailureReason.serviceDisabled,
        ),
      ),
    );
  });
}
