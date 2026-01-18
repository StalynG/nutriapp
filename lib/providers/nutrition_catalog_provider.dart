// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import '../domain/entities/nutritional_food.dart';
import '../domain/repositories/nutrition_catalog_repository.dart';

enum CatalogLoadingState { idle, loading, success, error }

/// Provider que gestiona el estado del catálogo nutricional
class NutritionCatalogProvider extends ChangeNotifier {
  final NutritionCatalogRepository _repository;

  CatalogLoadingState _state = CatalogLoadingState.idle;
  String _error = '';
  List<NutritionalFood> _foods = [];
  List<String> _categories = [];
  String _selectedCategory = '';
  List<NutritionalFood> _favorites = [];
  String _searchQuery = '';

  NutritionCatalogProvider(this._repository);

  // Getters
  CatalogLoadingState get state => _state;
  String get error => _error;
  List<NutritionalFood> get foods => List.unmodifiable(_foods);
  List<String> get categories => List.unmodifiable(_categories);
  String get selectedCategory => _selectedCategory;
  List<NutritionalFood> get favorites => List.unmodifiable(_favorites);
  String get searchQuery => _searchQuery;
  bool get isLoading => _state == CatalogLoadingState.loading;

  /// Carga todas las categorías disponibles
  Future<void> loadCategories() async {
    _state = CatalogLoadingState.loading;
    _error = '';
    notifyListeners();

    try {
      _categories = await _repository.getCategories();
      _state = CatalogLoadingState.success;
    } catch (e) {
      _error = 'Error al cargar categorías: ${e.toString()}';
      _state = CatalogLoadingState.error;
    }

    notifyListeners();
  }

  /// Carga todos los alimentos del catálogo
  Future<void> loadAllFoods() async {
    _state = CatalogLoadingState.loading;
    _error = '';
    _searchQuery = '';
    notifyListeners();

    try {
      _foods = await _repository.getAllFoods();
      _state = CatalogLoadingState.success;
    } catch (e) {
      _error = 'Error al cargar alimentos: ${e.toString()}';
      _state = CatalogLoadingState.error;
    }

    notifyListeners();
  }

  /// Carga alimentos por categoría
  Future<void> loadFoodsByCategory(String category) async {
    _state = CatalogLoadingState.loading;
    _error = '';
    _selectedCategory = category;
    _searchQuery = '';
    notifyListeners();

    try {
      _foods = await _repository.getFoodsByCategory(category);
      _state = CatalogLoadingState.success;
    } catch (e) {
      _error = 'Error al cargar alimentos: ${e.toString()}';
      _state = CatalogLoadingState.error;
    }

    notifyListeners();
  }

  /// Busca alimentos por nombre
  Future<void> searchFoods(String query) async {
    if (query.isEmpty) {
      _searchQuery = '';
      await loadAllFoods();
      return;
    }

    _state = CatalogLoadingState.loading;
    _error = '';
    _searchQuery = query;
    _selectedCategory = '';
    notifyListeners();

    try {
      _foods = await _repository.searchFoodsByName(query);
      _state = CatalogLoadingState.success;
    } catch (e) {
      _error = 'Error en búsqueda: ${e.toString()}';
      _state = CatalogLoadingState.error;
    }

    notifyListeners();
  }

  /// Carga los alimentos favoritos
  Future<void> loadFavorites() async {
    _state = CatalogLoadingState.loading;
    _error = '';
    notifyListeners();

    try {
      _favorites = await _repository.getFavorites();
      _state = CatalogLoadingState.success;
    } catch (e) {
      _error = 'Error al cargar favoritos: ${e.toString()}';
      _state = CatalogLoadingState.error;
    }

    notifyListeners();
  }

  /// Agrega un alimento a favoritos
  Future<void> addFavorite(String foodId) async {
    try {
      await _repository.addFavorite(foodId);
      await loadFavorites();
    } catch (e) {
      _error = 'Error al agregar favorito: ${e.toString()}';
      _state = CatalogLoadingState.error;
      notifyListeners();
    }
  }

  /// Elimina un alimento de favoritos
  Future<void> removeFavorite(String foodId) async {
    try {
      await _repository.removeFavorite(foodId);
      await loadFavorites();
    } catch (e) {
      _error = 'Error al eliminar favorito: ${e.toString()}';
      _state = CatalogLoadingState.error;
      notifyListeners();
    }
  }

  /// Verifica si un alimento es favorito
  bool isFavorite(String foodId) {
    return _favorites.any((food) => food.id == foodId);
  }

  /// Limpia el estado
  void clearState() {
    _state = CatalogLoadingState.idle;
    _error = '';
    _foods = [];
    _selectedCategory = '';
    _searchQuery = '';
    notifyListeners();
  }
}
