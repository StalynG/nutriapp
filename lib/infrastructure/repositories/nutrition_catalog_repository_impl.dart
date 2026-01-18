// ignore_for_file: public_member_api_docs

import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/nutritional_food.dart';
import '../../domain/repositories/nutrition_catalog_repository.dart';

/// Implementación del repositorio de catálogo nutricional
class NutritionCatalogRepositoryImpl implements NutritionCatalogRepository {
  static const String _favoritesKey = 'nutrition_favorites';
  
  final SharedPreferences _prefs;

  NutritionCatalogRepositoryImpl(this._prefs);

  /// Catálogo mínimo de alimentos con valores nutricionales
  static final List<NutritionalFood> _minimalCatalog = [
    // Frutas
    NutritionalFood(
      id: 'food_001',
      name: 'Manzana',
      category: 'Frutas',
      caloriesPer100g: 52,
      proteinsPer100g: 0.3,
      fatsPer100g: 0.2,
      carbsPer100g: 14,
      fiberPer100g: 2.4,
      description: 'Rica en fibra y vitamina C',
    ),
    NutritionalFood(
      id: 'food_002',
      name: 'Plátano',
      category: 'Frutas',
      caloriesPer100g: 89,
      proteinsPer100g: 1.1,
      fatsPer100g: 0.3,
      carbsPer100g: 23,
      fiberPer100g: 2.6,
      description: 'Excelente fuente de potasio',
    ),
    NutritionalFood(
      id: 'food_003',
      name: 'Naranja',
      category: 'Frutas',
      caloriesPer100g: 47,
      proteinsPer100g: 0.9,
      fatsPer100g: 0.1,
      carbsPer100g: 12,
      fiberPer100g: 2.4,
      description: 'Alta en vitamina C',
    ),
    // Verduras
    NutritionalFood(
      id: 'food_004',
      name: 'Brócoli',
      category: 'Verduras',
      caloriesPer100g: 34,
      proteinsPer100g: 2.8,
      fatsPer100g: 0.4,
      carbsPer100g: 7,
      fiberPer100g: 2.4,
      description: 'Vegetal crucífero muy nutritivo',
    ),
    NutritionalFood(
      id: 'food_005',
      name: 'Zanahoria',
      category: 'Verduras',
      caloriesPer100g: 41,
      proteinsPer100g: 0.9,
      fatsPer100g: 0.2,
      carbsPer100g: 10,
      fiberPer100g: 2.8,
      description: 'Rica en betacaroteno',
    ),
    NutritionalFood(
      id: 'food_006',
      name: 'Espinaca',
      category: 'Verduras',
      caloriesPer100g: 23,
      proteinsPer100g: 2.7,
      fatsPer100g: 0.4,
      carbsPer100g: 3.6,
      fiberPer100g: 2.2,
      description: 'Excelente fuente de hierro',
    ),
    // Proteínas
    NutritionalFood(
      id: 'food_007',
      name: 'Pechuga de Pollo',
      category: 'Proteínas',
      caloriesPer100g: 165,
      proteinsPer100g: 31,
      fatsPer100g: 3.6,
      carbsPer100g: 0,
      fiberPer100g: 0,
      description: 'Proteína magra de alta calidad',
    ),
    NutritionalFood(
      id: 'food_008',
      name: 'Huevo',
      category: 'Proteínas',
      caloriesPer100g: 155,
      proteinsPer100g: 13,
      fatsPer100g: 11,
      carbsPer100g: 1.1,
      fiberPer100g: 0,
      description: 'Proteína completa con todos los aminoácidos',
    ),
    NutritionalFood(
      id: 'food_009',
      name: 'Salmón',
      category: 'Proteínas',
      caloriesPer100g: 208,
      proteinsPer100g: 20,
      fatsPer100g: 13,
      carbsPer100g: 0,
      fiberPer100g: 0,
      description: 'Rico en omega-3',
    ),
    // Granos
    NutritionalFood(
      id: 'food_010',
      name: 'Arroz Integral',
      category: 'Granos',
      caloriesPer100g: 112,
      proteinsPer100g: 2.6,
      fatsPer100g: 0.9,
      carbsPer100g: 24,
      fiberPer100g: 1.8,
      description: 'Mayor contenido de fibra que el arroz blanco',
    ),
    NutritionalFood(
      id: 'food_011',
      name: 'Avena',
      category: 'Granos',
      caloriesPer100g: 389,
      proteinsPer100g: 17,
      fatsPer100g: 6.9,
      carbsPer100g: 66,
      fiberPer100g: 10.6,
      description: 'Excelente para desayuno, rica en fibra soluble',
    ),
    NutritionalFood(
      id: 'food_012',
      name: 'Pan Integral',
      category: 'Granos',
      caloriesPer100g: 265,
      proteinsPer100g: 8.7,
      fatsPer100g: 3.3,
      carbsPer100g: 48,
      fiberPer100g: 4.3,
      description: 'Mejor opción que pan blanco',
    ),
    // Lácteos
    NutritionalFood(
      id: 'food_013',
      name: 'Yogur Griego',
      category: 'Lácteos',
      caloriesPer100g: 59,
      proteinsPer100g: 10,
      fatsPer100g: 0.4,
      carbsPer100g: 3.3,
      fiberPer100g: 0,
      description: 'Alto en proteína, bajo en carbohidratos',
    ),
    NutritionalFood(
      id: 'food_014',
      name: 'Leche Desnatada',
      category: 'Lácteos',
      caloriesPer100g: 35,
      proteinsPer100g: 3.4,
      fatsPer100g: 0.1,
      carbsPer100g: 4.8,
      fiberPer100g: 0,
      description: 'Baja en grasa, rica en calcio',
    ),
    NutritionalFood(
      id: 'food_015',
      name: 'Queso Fresco',
      category: 'Lácteos',
      caloriesPer100g: 98,
      proteinsPer100g: 17,
      fatsPer100g: 3,
      carbsPer100g: 1.3,
      fiberPer100g: 0,
      description: 'Proteína con moderado contenido de grasa',
    ),
    // Frutos Secos
    NutritionalFood(
      id: 'food_016',
      name: 'Almendras',
      category: 'Frutos Secos',
      caloriesPer100g: 579,
      proteinsPer100g: 21,
      fatsPer100g: 50,
      carbsPer100g: 22,
      fiberPer100g: 12.5,
      description: 'Grasas saludables y proteína',
    ),
    NutritionalFood(
      id: 'food_017',
      name: 'Nueces',
      category: 'Frutos Secos',
      caloriesPer100g: 654,
      proteinsPer100g: 9.3,
      fatsPer100g: 65,
      carbsPer100g: 14,
      fiberPer100g: 6.7,
      description: 'Ricas en omega-3 vegetal',
    ),
  ];

  @override
  Future<List<NutritionalFood>> getAllFoods() async {
    return _minimalCatalog;
  }

  @override
  Future<List<NutritionalFood>> getFoodsByCategory(String category) async {
    return _minimalCatalog
        .where((food) => food.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  Future<List<NutritionalFood>> searchFoodsByName(String query) async {
    final lowerQuery = query.toLowerCase();
    return _minimalCatalog
        .where((food) => food.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  Future<NutritionalFood?> getFoodById(String id) async {
    try {
      return _minimalCatalog.firstWhere((food) => food.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<String>> getCategories() async {
    final categories = <String>{};
    for (final food in _minimalCatalog) {
      categories.add(food.category);
    }
    return categories.toList();
  }

  @override
  Future<void> addFavorite(String foodId) async {
    final favorites = await _getFavoritesList();
    if (!favorites.contains(foodId)) {
      favorites.add(foodId);
      await _prefs.setStringList(_favoritesKey, favorites);
    }
  }

  @override
  Future<void> removeFavorite(String foodId) async {
    final favorites = await _getFavoritesList();
    favorites.removeWhere((id) => id == foodId);
    await _prefs.setStringList(_favoritesKey, favorites);
  }

  @override
  Future<List<NutritionalFood>> getFavorites() async {
    final favoriteIds = await _getFavoritesList();
    return _minimalCatalog
        .where((food) => favoriteIds.contains(food.id))
        .toList();
  }

  Future<List<String>> _getFavoritesList() async {
    return _prefs.getStringList(_favoritesKey) ?? [];
  }
}
