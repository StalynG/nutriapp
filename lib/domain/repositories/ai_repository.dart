// ignore_for_file: public_member_api_docs

import 'dart:io';

import '../entities/food_analysis.dart';

/// Contrato para el repositorio de inteligencia artificial
abstract class AiRepository {
  /// Analiza una imagen de comida
  Future<FoodAnalysis> analyzeFood(File imageFile);

  /// Obtiene recomendaciones nutricionales
  Future<String> getNutritionRecommendations(FoodAnalysis analysis);

  /// Genera un plan de comidas
  Future<String> generateMealPlan({
    required int days,
    required int dailyCalories,
    required List<String> dietaryRestrictions,
  });

  /// Envía un mensaje de chat genérico a la IA
  Future<String> sendChatMessage(String message);
}
