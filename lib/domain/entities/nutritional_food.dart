// ignore_for_file: public_member_api_docs

/// Entidad que representa un alimento en el catálogo nutricional
class NutritionalFood {
  final String id;
  final String name;
  final String category;
  final double caloriesPer100g;
  final double proteinsPer100g;
  final double fatsPer100g;
  final double carbsPer100g;
  final double fiberPer100g;
  final String? imageUrl;
  final String? description;

  NutritionalFood({
    required this.id,
    required this.name,
    required this.category,
    required this.caloriesPer100g,
    required this.proteinsPer100g,
    required this.fatsPer100g,
    required this.carbsPer100g,
    required this.fiberPer100g,
    this.imageUrl,
    this.description,
  });

  factory NutritionalFood.fromJson(Map<String, dynamic> json) {
    return NutritionalFood(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      caloriesPer100g: (json['calories_per_100g'] as num?)?.toDouble() ?? 0.0,
      proteinsPer100g: (json['proteins_per_100g'] as num?)?.toDouble() ?? 0.0,
      fatsPer100g: (json['fats_per_100g'] as num?)?.toDouble() ?? 0.0,
      carbsPer100g: (json['carbs_per_100g'] as num?)?.toDouble() ?? 0.0,
      fiberPer100g: (json['fiber_per_100g'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'calories_per_100g': caloriesPer100g,
    'proteins_per_100g': proteinsPer100g,
    'fats_per_100g': fatsPer100g,
    'carbs_per_100g': carbsPer100g,
    'fiber_per_100g': fiberPer100g,
    'image_url': imageUrl,
    'description': description,
  };

  /// Calcula los valores nutricionales para una porción específica en gramos
  NutritionalValues calculateForPortion(double grams) {
    final multiplier = grams / 100;
    return NutritionalValues(
      calories: (caloriesPer100g * multiplier).toStringAsFixed(1),
      proteins: (proteinsPer100g * multiplier).toStringAsFixed(1),
      fats: (fatsPer100g * multiplier).toStringAsFixed(1),
      carbs: (carbsPer100g * multiplier).toStringAsFixed(1),
      fiber: (fiberPer100g * multiplier).toStringAsFixed(1),
    );
  }
}

/// Clase para almacenar valores nutricionales calculados
class NutritionalValues {
  final String calories;
  final String proteins;
  final String fats;
  final String carbs;
  final String fiber;

  NutritionalValues({
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
    required this.fiber,
  });
}
