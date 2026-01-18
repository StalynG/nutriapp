// ignore_for_file: public_member_api_docs

import '../entities/nutritional_food.dart';

/// Contrato para el repositorio de catálogo nutricional
abstract class NutritionCatalogRepository {
  /// Obtiene todos los alimentos del catálogo
  Future<List<NutritionalFood>> getAllFoods();

  /// Obtiene alimentos por categoría
  Future<List<NutritionalFood>> getFoodsByCategory(String category);

  /// Busca alimentos por nombre
  Future<List<NutritionalFood>> searchFoodsByName(String query);

  /// Obtiene un alimento específico por ID
  Future<NutritionalFood?> getFoodById(String id);

  /// Obtiene las categorías disponibles
  Future<List<String>> getCategories();

  /// Agrega un alimento favorito
  Future<void> addFavorite(String foodId);

  /// Elimina un alimento favorito
  Future<void> removeFavorite(String foodId);

  /// Obtiene los alimentos favoritos
  Future<List<NutritionalFood>> getFavorites();
}
