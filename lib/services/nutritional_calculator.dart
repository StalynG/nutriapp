import '../models/food_item.dart';

class NutritionalCalculator {
  
  // CORRECCIÓN NUT-40: Método auxiliar para redondear a 1 decimal
  double _redondear(double valor) {
    return double.parse(valor.toStringAsFixed(1));
  }

  Map<String, double> calculateItemMacros(FoodItem item, double weightInGrams) {
    double factor = weightInGrams / 100.0;

    // Aplicamos redondeo a cada macro individual
    return {
      "calories": _redondear(item.caloriesPer100g * factor),
      "protein": _redondear(item.proteinPer100g * factor),
      "carbs": _redondear(item.carbsPer100g * factor),
      "fat": _redondear(item.fatPer100g * factor),
    };
  }

  Map<String, double> calculateTotalMeal(List<Map<String, dynamic>> mealItems) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    
    for (var entry in mealItems) {
      FoodItem item = entry['item'];
      double weight = entry['weight']; // Asegúrate que en tu código original esto sea double
      
      // Obtenemos los macros individuales ya redondeados
      var macros = calculateItemMacros(item, weight);
      
      // Sumamos
      totalCalories += macros['calories']!;
      totalProtein += macros['protein']!;
      totalCarbs += macros['carbs']!;
      totalFat += macros['fat']!;
    }

    // CORRECCIÓN FINAL: Redondeamos también la sumatoria total para evitar residuos
    return {
      "totalCalories": _redondear(totalCalories),
      "totalProtein": _redondear(totalProtein),
      "totalCarbs": _redondear(totalCarbs),
      "totalFat": _redondear(totalFat),
    };
  }
}