import '../../domain/entities/nutritional_result.dart';
import '../../domain/entities/ingredient_scan.dart';
import '../../domain/repositories/nutrition_catalog_repository.dart';

/// Service for calculating and validating nutritional information
class NutritionPersistenceService {
  final NutritionCatalogRepository _catalogRepository;

  NutritionPersistenceService(this._catalogRepository);

  /// Calculate nutritional result from detected ingredients
  Future<NutritionalResult> calculateNutritionalResult({
    required String resultId,
    required String scanId,
    required String userId,
    required List<String> ingredients,
    required DateTime calculatedAt,
    String? notes,
  }) async {
    try {
      double totalCalories = 0.0;
      double totalProtein = 0.0;
      double totalFat = 0.0;
      double totalCarbs = 0.0;
      double totalFiber = 0.0;

      // Get nutritional data for each ingredient from catalog
      for (final ingredient in ingredients) {
        final foods = await _catalogRepository.searchFoodsByName(ingredient);

        if (foods.isNotEmpty) {
          // Use the first matching food (most relevant)
          final food = foods.first;

          // Assume 100g serving as default
          totalCalories += food.caloriesPer100g;
          totalProtein += food.proteinsPer100g;
          totalFat += food.fatsPer100g;
          totalCarbs += food.carbsPer100g;
          totalFiber += food.fiberPer100g;
        }
      }

      // Calculate calorie breakdown per macronutrient
      final proteinCalories = totalProtein * 4;
      final fatCalories = totalFat * 9;
      final carbsCalories = totalCarbs * 4;

      // Calculate percentages (handle zero total case)
      final totalCaloriesFromMacros =
          proteinCalories + fatCalories + carbsCalories;
      late Map<String, double> macroPercentages;

      if (totalCaloriesFromMacros > 0) {
        macroPercentages = {
          'protein': (proteinCalories / totalCaloriesFromMacros) * 100,
          'fat': (fatCalories / totalCaloriesFromMacros) * 100,
          'carbs': (carbsCalories / totalCaloriesFromMacros) * 100,
        };
      } else {
        macroPercentages = {
          'protein': 0.0,
          'fat': 0.0,
          'carbs': 0.0,
        };
      }

      final calorieBreakdown = {
        'protein': proteinCalories,
        'fat': fatCalories,
        'carbs': carbsCalories,
      };

      // Use calculated calories from macros if significantly different
      final finalCalories = totalCalories > 0 ? totalCalories : totalCaloriesFromMacros;

      return NutritionalResult(
        id: resultId,
        scanId: scanId,
        userId: userId,
        ingredients: ingredients,
        totalCalories: finalCalories,
        proteinGrams: totalProtein,
        fatGrams: totalFat,
        carbsGrams: totalCarbs,
        fiberGrams: totalFiber,
        calorieBreakdown: calorieBreakdown,
        macroPercentages: macroPercentages,
        calculatedAt: calculatedAt,
        notes: notes,
        isSaved: false,
      );
    } catch (e) {
      throw Exception('Failed to calculate nutritional result: $e');
    }
  }

  /// Calculate nutritional result with custom portion sizes
  Future<NutritionalResult> calculateWithPortions({
    required String resultId,
    required String scanId,
    required String userId,
    required Map<String, double> ingredientPortions, // ingredient name -> grams
    required DateTime calculatedAt,
    String? notes,
  }) async {
    try {
      double totalCalories = 0.0;
      double totalProtein = 0.0;
      double totalFat = 0.0;
      double totalCarbs = 0.0;
      double totalFiber = 0.0;

      // Calculate with custom portions
      for (final entry in ingredientPortions.entries) {
        final ingredient = entry.key;
        final grams = entry.value;

        final foods = await _catalogRepository.searchFoodsByName(ingredient);

        if (foods.isNotEmpty) {
          final food = foods.first;

          // Calculate based on actual portion
          final portionFactor = grams / 100.0;
          totalCalories += food.caloriesPer100g * portionFactor;
          totalProtein += food.proteinsPer100g * portionFactor;
          totalFat += food.fatsPer100g * portionFactor;
          totalCarbs += food.carbsPer100g * portionFactor;
          totalFiber += food.fiberPer100g * portionFactor;
        }
      }

      // Calculate percentages
      final proteinCalories = totalProtein * 4;
      final fatCalories = totalFat * 9;
      final carbsCalories = totalCarbs * 4;

      final totalCaloriesFromMacros =
          proteinCalories + fatCalories + carbsCalories;
      late Map<String, double> macroPercentages;

      if (totalCaloriesFromMacros > 0) {
        macroPercentages = {
          'protein': (proteinCalories / totalCaloriesFromMacros) * 100,
          'fat': (fatCalories / totalCaloriesFromMacros) * 100,
          'carbs': (carbsCalories / totalCaloriesFromMacros) * 100,
        };
      } else {
        macroPercentages = {
          'protein': 0.0,
          'fat': 0.0,
          'carbs': 0.0,
        };
      }

      final calorieBreakdown = {
        'protein': proteinCalories,
        'fat': fatCalories,
        'carbs': carbsCalories,
      };

      final finalCalories =
          totalCalories > 0 ? totalCalories : totalCaloriesFromMacros;

      return NutritionalResult(
        id: resultId,
        scanId: scanId,
        userId: userId,
        ingredients: ingredientPortions.keys.toList(),
        totalCalories: finalCalories,
        proteinGrams: totalProtein,
        fatGrams: totalFat,
        carbsGrams: totalCarbs,
        fiberGrams: totalFiber,
        calorieBreakdown: calorieBreakdown,
        macroPercentages: macroPercentages,
        calculatedAt: calculatedAt,
        notes: notes,
        isSaved: false,
      );
    } catch (e) {
      throw Exception('Failed to calculate nutritional result with portions: $e');
    }
  }

  /// Verify nutritional calculation consistency
  bool verifyNutritionalConsistency(NutritionalResult result) {
    // Check if calories match macronutrient calculations
    final calculatedFromMacros =
        (result.proteinGrams * 4) + (result.fatGrams * 9) + (result.carbsGrams * 4);

    // Allow 5% tolerance for rounding
    final tolerance = result.totalCalories * 0.05;
    if ((calculatedFromMacros - result.totalCalories).abs() > tolerance) {
      return false;
    }

    // Verify percentages sum to ~100%
    final totalPercentage = result.macroPercentages.values
        .fold<double>(0, (sum, val) => sum + val);
    if ((totalPercentage - 100).abs() > 1.0) {
      return false;
    }

    // Verify calorie breakdown matches
    final breakdownTotal = result.calorieBreakdown.values
        .fold<double>(0, (sum, val) => sum + val);
    if ((breakdownTotal - result.totalCalories).abs() > tolerance) {
      return false;
    }

    // All values should be non-negative
    if (result.totalCalories < 0 ||
        result.proteinGrams < 0 ||
        result.fatGrams < 0 ||
        result.carbsGrams < 0 ||
        result.fiberGrams < 0) {
      return false;
    }

    return true;
  }

  /// Generate a nutritional summary report
  String generateNutritionReport(NutritionalResult result) {
    final buffer = StringBuffer();

    buffer.writeln('=== Nutritional Analysis Report ===');
    buffer.writeln('Scanned Ingredients: ${result.ingredients.join(", ")}');
    buffer.writeln('Date: ${result.calculatedAt.toLocal()}');
    buffer.writeln('');
    buffer.writeln('CALORIC CONTENT:');
    buffer.writeln('  Total Calories: ${result.formattedCalories}');
    buffer.writeln('');
    buffer.writeln('MACRONUTRIENTS:');
    buffer.writeln('  Protein: ${result.formattedProtein} (${result.macroPercentages['protein']?.toStringAsFixed(1)}%)');
    buffer.writeln('  Fat: ${result.formattedFat} (${result.macroPercentages['fat']?.toStringAsFixed(1)}%)');
    buffer.writeln('  Carbohydrates: ${result.formattedCarbs} (${result.macroPercentages['carbs']?.toStringAsFixed(1)}%)');
    buffer.writeln('  Fiber: ${result.formattedFiber}');
    buffer.writeln('');
    buffer.writeln('MACRONUTRIENT CALORIE BREAKDOWN:');
    buffer.writeln('  From Protein: ${result.calorieBreakdown['protein']?.toStringAsFixed(1)} kcal');
    buffer.writeln('  From Fat: ${result.calorieBreakdown['fat']?.toStringAsFixed(1)} kcal');
    buffer.writeln('  From Carbs: ${result.calorieBreakdown['carbs']?.toStringAsFixed(1)} kcal');
    buffer.writeln('');
    buffer.writeln('Data Validation: ${result.validateNutritionalData() ? '✓ Valid' : '✗ Invalid'}');

    if (result.notes != null && result.notes!.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Notes: ${result.notes}');
    }

    return buffer.toString();
  }
}
