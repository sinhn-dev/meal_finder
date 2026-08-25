import 'package:flutter_test/flutter_test.dart';
import 'package:meal_finder/models/meal.dart';

void main() {
  test('MealSummary parses TheMealDB json', () {
    final meal = MealSummary.fromJson({
      'idMeal': '52772',
      'strMeal': 'Teriyaki Chicken Casserole',
      'strMealThumb':
          'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
    });

    expect(meal.id, '52772');
    expect(meal.name, 'Teriyaki Chicken Casserole');
    expect(meal.thumbnail, contains('themealdb.com'));
  });

  test('Meal parses ingredients and skips empty slots', () {
    final meal = Meal.fromJson({
      'idMeal': '1',
      'strMeal': 'Arrabiata',
      'strMealThumb': '',
      'strCategory': 'Vegetarian',
      'strArea': 'Italian',
      'strInstructions': 'Cook pasta.',
      'strIngredient1': 'Pennette',
      'strMeasure1': '1 pound',
      'strIngredient2': 'Garlic',
      'strMeasure2': '3 cloves',
      'strIngredient3': ' ',
      'strMeasure3': '',
    });

    expect(meal.ingredients, hasLength(2));
    expect(meal.ingredients.first.name, 'Pennette');
    expect(meal.ingredients.last.measure, '3 cloves');
  });
}
