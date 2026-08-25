class Ingredient {
  const Ingredient({required this.name, required this.measure});

  final String name;
  final String measure;
}

class MealSummary {
  const MealSummary({
    required this.id,
    required this.name,
    required this.thumbnail,
  });

  final String id;
  final String name;
  final String thumbnail;

  factory MealSummary.fromJson(Map<String, dynamic> json) {
    return MealSummary(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      thumbnail: (json['strMealThumb'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'idMeal': id, 'strMeal': name, 'strMealThumb': thumbnail};
  }

  MealSummary copyWith({String? id, String? name, String? thumbnail}) {
    return MealSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}

class Meal {
  const Meal({
    required this.id,
    required this.name,
    required this.thumbnail,
    this.category,
    this.area,
    this.instructions,
    this.youtubeUrl,
    this.ingredients = const [],
  });

  final String id;
  final String name;
  final String thumbnail;
  final String? category;
  final String? area;
  final String? instructions;
  final String? youtubeUrl;
  final List<Ingredient> ingredients;

  MealSummary get summary =>
      MealSummary(id: id, name: name, thumbnail: thumbnail);

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      thumbnail: (json['strMealThumb'] as String?) ?? '',
      category: json['strCategory'] as String?,
      area: json['strArea'] as String?,
      instructions: json['strInstructions'] as String?,
      youtubeUrl: json['strYoutube'] as String?,
      ingredients: _parseIngredients(json),
    );
  }

  static List<Ingredient> _parseIngredients(Map<String, dynamic> json) {
    final ingredients = <Ingredient>[];
    for (var i = 1; i <= 20; i++) {
      final name = (json['strIngredient$i'] as String?)?.trim();
      final measure = (json['strMeasure$i'] as String?)?.trim() ?? '';
      if (name == null || name.isEmpty) {
        continue;
      }
      ingredients.add(Ingredient(name: name, measure: measure));
    }
    return ingredients;
  }
}
