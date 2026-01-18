// ignore_for_file: public_member_api_docs

import 'dart:io';

import '../../infrastructure/services/openai_service.dart';
import '../entities/food_analysis.dart';
import 'ai_repository.dart';

/// Implementación del repositorio de inteligencia artificial usando OpenAI
class AiRepositoryImpl implements AiRepository {
  final OpenAIService _openaiService;

  AiRepositoryImpl(this._openaiService);

  @override
  Future<FoodAnalysis> analyzeFood(File imageFile) async {
    return _openaiService.analyzeImage(imageFile);
  }

  @override
  Future<String> getNutritionRecommendations(FoodAnalysis analysis) async {
    return _openaiService.getNutritionRecommendations(analysis);
  }

  @override
  Future<String> generateMealPlan({
    required int days,
    required int dailyCalories,
    required List<String> dietaryRestrictions,
  }) async {
    return _openaiService.generateMealPlan(
      days: days,
      dailyCalories: dailyCalories,
      dietaryRestrictions: dietaryRestrictions,
    );
  }

  @override
  Future<String> sendChatMessage(String message) async {
    return _openaiService.sendMessage(message);
  }
}
