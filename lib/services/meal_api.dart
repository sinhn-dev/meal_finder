import 'package:dio/dio.dart';

import '../models/meal.dart';

class MealApiException implements Exception {
  const MealApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MealApi {
  MealApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://www.themealdb.com/api/json/v1/1/',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ),
          );

  final Dio _dio;

  Future<List<MealSummary>> search(String query) async {
    final data = await _get('search.php', {'s': query});
    return _summaries(data);
  }

  Future<List<MealSummary>> byCategory(String category) async {
    final data = await _get('filter.php', {'c': category});
    return _summaries(data);
  }

  Future<Meal?> lookup(String id) async {
    final data = await _get('lookup.php', {'i': id});
    final meals = data['meals'] as List<dynamic>?;
    if (meals == null || meals.isEmpty) {
      return null;
    }
    return Meal.fromJson(meals.first as Map<String, dynamic>);
  }

  Future<Meal?> random() async {
    final data = await _get('random.php');
    final meals = data['meals'] as List<dynamic>?;
    if (meals == null || meals.isEmpty) {
      return null;
    }
    return Meal.fromJson(meals.first as Map<String, dynamic>);
  }

  Future<List<String>> categories() async {
    final data = await _get('list.php', {'c': 'list'});
    final meals = data['meals'] as List<dynamic>?;
    if (meals == null) {
      return [];
    }
    return meals
        .map((item) => (item as Map<String, dynamic>)['strCategory'] as String)
        .toList();
  }

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, dynamic>? query,
  ]) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: query,
      );
      return response.data ?? {};
    } on DioException catch (error) {
      throw MealApiException(_messageFor(error));
    }
  }

  List<MealSummary> _summaries(Map<String, dynamic> data) {
    final meals = data['meals'] as List<dynamic>?;
    if (meals == null) {
      return [];
    }
    return meals
        .map((item) => MealSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  String _messageFor(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Request timed out. Check your internet connection.';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Cannot reach TheMealDB. Check your internet connection.';
    }
    return 'Failed to load meals. Please try again.';
  }
}
