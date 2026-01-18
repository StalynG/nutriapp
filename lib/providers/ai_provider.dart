// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/entities/food_analysis.dart';
import '../domain/repositories/ai_repository.dart';

/// Estado de carga para las operaciones de IA
enum AILoadingState { idle, loading, success, error }

/// Provider que gestiona el estado de las operaciones de inteligencia artificial
class AiProvider extends ChangeNotifier {
  final AiRepository _aiRepository;

  AILoadingState _state = AILoadingState.idle;
  String _error = '';
  FoodAnalysis? _currentFoodAnalysis;
  String _currentResponse = '';
  List<String> _chatHistory = [];

  AiProvider(this._aiRepository);

  // Getters
  AILoadingState get state => _state;
  String get error => _error;
  FoodAnalysis? get currentFoodAnalysis => _currentFoodAnalysis;
  String get currentResponse => _currentResponse;
  List<String> get chatHistory => List.unmodifiable(_chatHistory);
  bool get isLoading => _state == AILoadingState.loading;

  /// Analiza una imagen de comida
  Future<void> analyzeFood(File imageFile) async {
    _state = AILoadingState.loading;
    _error = '';
    notifyListeners();

    try {
      _currentFoodAnalysis = await _aiRepository.analyzeFood(imageFile);
      _state = AILoadingState.success;
    } catch (e) {
      _error = 'Error al analizar la comida: ${e.toString()}';
      _state = AILoadingState.error;
    }

    notifyListeners();
  }

  /// Obtiene recomendaciones nutricionales para el análisis actual
  Future<void> getNutritionRecommendations() async {
    if (_currentFoodAnalysis == null) {
      _error = 'No hay análisis de comida disponible';
      _state = AILoadingState.error;
      notifyListeners();
      return;
    }

    _state = AILoadingState.loading;
    _error = '';
    notifyListeners();

    try {
      _currentResponse = await _aiRepository.getNutritionRecommendations(_currentFoodAnalysis!);
      _state = AILoadingState.success;
    } catch (e) {
      _error = 'Error al obtener recomendaciones: ${e.toString()}';
      _state = AILoadingState.error;
    }

    notifyListeners();
  }

  /// Genera un plan de comidas personalizado
  Future<void> generateMealPlan({
    required int days,
    required int dailyCalories,
    required List<String> dietaryRestrictions,
  }) async {
    _state = AILoadingState.loading;
    _error = '';
    notifyListeners();

    try {
      _currentResponse = await _aiRepository.generateMealPlan(
        days: days,
        dailyCalories: dailyCalories,
        dietaryRestrictions: dietaryRestrictions,
      );
      _state = AILoadingState.success;
    } catch (e) {
      _error = 'Error al generar el plan de comidas: ${e.toString()}';
      _state = AILoadingState.error;
    }

    notifyListeners();
  }

  /// Envía un mensaje de chat
  Future<void> sendChatMessage(String message) async {
    _state = AILoadingState.loading;
    _error = '';
    _chatHistory.add('Tu: $message');
    notifyListeners();

    try {
      final response = await _aiRepository.sendChatMessage(message);
      _currentResponse = response;
      _chatHistory.add('IA: $response');
      _state = AILoadingState.success;
    } catch (e) {
      _error = 'Error en el chat: ${e.toString()}';
      _state = AILoadingState.error;
    }

    notifyListeners();
  }

  /// Limpia el historial de chat
  void clearChatHistory() {
    _chatHistory.clear();
    _currentResponse = '';
    _state = AILoadingState.idle;
    notifyListeners();
  }

  /// Limpia el análisis actual
  void clearAnalysis() {
    _currentFoodAnalysis = null;
    _currentResponse = '';
    _state = AILoadingState.idle;
    notifyListeners();
  }

  /// Limpia todos los datos
  void clearAll() {
    _state = AILoadingState.idle;
    _error = '';
    _currentFoodAnalysis = null;
    _currentResponse = '';
    _chatHistory.clear();
    notifyListeners();
  }
}
