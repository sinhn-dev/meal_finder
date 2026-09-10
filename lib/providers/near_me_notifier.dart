import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/meal.dart';
import '../services/location_service.dart';
import '../utils/cuisine_area_mapper.dart';
import 'app_providers.dart';

class NearMeState {
  const NearMeState({
    required this.isLoading,
    required this.error,
    required this.failureReason,
    required this.latitude,
    required this.longitude,
    required this.area,
    required this.meals,
    required this.isFromCache,
  });

  factory NearMeState.initial() {
    return const NearMeState(
      isLoading: true,
      error: null,
      failureReason: null,
      latitude: null,
      longitude: null,
      area: null,
      meals: [],
      isFromCache: false,
    );
  }

  final bool isLoading;
  final String? error;
  final LocationFailureReason? failureReason;
  final double? latitude;
  final double? longitude;
  final String? area;
  final List<MealSummary> meals;
  final bool isFromCache;

  bool get hasPosition => latitude != null && longitude != null;

  NearMeState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    LocationFailureReason? failureReason,
    bool clearFailureReason = false,
    double? latitude,
    double? longitude,
    String? area,
    List<MealSummary>? meals,
    bool? isFromCache,
  }) {
    return NearMeState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      failureReason: clearFailureReason
          ? null
          : (failureReason ?? this.failureReason),
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      area: area ?? this.area,
      meals: meals ?? this.meals,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

class NearMeNotifier extends StateNotifier<NearMeState> {
  NearMeNotifier(this._ref) : super(NearMeState.initial());

  final Ref _ref;

  Future<void> load() async {
    state = NearMeState.initial();
    try {
      final position = await _ref
          .read(locationServiceProvider)
          .getCurrentPosition();
      await _loadMealsFor(position);
    } on LocationException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.message,
        failureReason: error.reason,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> _loadMealsFor(Position position) async {
    final area = CuisineAreaMapper.latLngToCuisineArea(
      position.latitude,
      position.longitude,
    );
    debugPrint('NearMeNotifier: mapped area=$area');
    state = state.copyWith(
      latitude: position.latitude,
      longitude: position.longitude,
      area: area,
      clearError: true,
      clearFailureReason: true,
    );

    try {
      final result = await _ref.read(mealRepositoryProvider).byArea(area);
      state = state.copyWith(
        meals: result.data,
        isFromCache: result.isFromCache,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> openSettings() async {
    final reason = state.failureReason;
    final service = _ref.read(locationServiceProvider);
    if (reason == LocationFailureReason.serviceDisabled) {
      await service.openLocationSettings();
      return;
    }
    await service.openAppSettings();
  }
}

final nearMeProvider =
    StateNotifierProvider.autoDispose<NearMeNotifier, NearMeState>((ref) {
      return NearMeNotifier(ref);
    });
