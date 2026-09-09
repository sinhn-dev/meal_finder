import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum LocationFailureReason { denied, deniedForever, serviceDisabled }

class LocationException implements Exception {
  const LocationException(this.reason, this.message);

  final LocationFailureReason reason;
  final String message;

  @override
  String toString() => message;
}

/// Permission + GPS — injectable for tests via constructor overrides.
class LocationService {
  LocationService({
    Future<bool> Function()? isLocationServiceEnabled,
    Future<LocationPermission> Function()? checkPermission,
    Future<LocationPermission> Function()? requestPermission,
    Future<Position> Function()? getCurrentPosition,
    Future<bool> Function()? openAppSettings,
    Future<bool> Function()? openLocationSettings,
  }) : _isLocationServiceEnabled =
           isLocationServiceEnabled ?? Geolocator.isLocationServiceEnabled,
       _checkPermission = checkPermission ?? Geolocator.checkPermission,
       _requestPermission = requestPermission ?? Geolocator.requestPermission,
       _getCurrentPosition =
           getCurrentPosition ??
           (() => Geolocator.getCurrentPosition(
             locationSettings: const LocationSettings(
               accuracy: LocationAccuracy.medium,
             ),
           )),
       _openAppSettings = openAppSettings ?? Geolocator.openAppSettings,
       _openLocationSettings =
           openLocationSettings ?? Geolocator.openLocationSettings;

  final Future<bool> Function() _isLocationServiceEnabled;
  final Future<LocationPermission> Function() _checkPermission;
  final Future<LocationPermission> Function() _requestPermission;
  final Future<Position> Function() _getCurrentPosition;
  final Future<bool> Function() _openAppSettings;
  final Future<bool> Function() _openLocationSettings;

  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await _isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('LocationService: location services disabled');
      throw const LocationException(
        LocationFailureReason.serviceDisabled,
        'Location services are turned off. Enable them in Settings.',
      );
    }

    var permission = await _checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _requestPermission();
    }

    if (permission == LocationPermission.denied) {
      debugPrint('LocationService: permission denied');
      throw const LocationException(
        LocationFailureReason.denied,
        'Location permission was denied. Allow location to try the demo.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('LocationService: permission denied forever');
      throw const LocationException(
        LocationFailureReason.deniedForever,
        'Location permission is permanently denied. Open Settings to enable it.',
      );
    }

    final position = await _getCurrentPosition();
    debugPrint(
      'LocationService: position lat=${position.latitude} '
      'lng=${position.longitude}',
    );
    return position;
  }

  Future<bool> openAppSettings() => _openAppSettings();

  Future<bool> openLocationSettings() => _openLocationSettings();
}
