import '../models/food_item.dart';

class NutritionalCalculator {
  
  // Esta función recibe el alimento base y el peso que confirmó el usuario
  Map<String, double> calculateItemMacros(FoodItem item, double weightInGrams) {
    
    // Factor de conversión
    double factor = weightInGrams / 100.0;

    return {
      "calories": item.caloriesPer100g * factor,
      "protein": item.proteinPer100g * factor,
      "carbs": item.carbsPer100g * factor,
      "fat": item.fatPer100g * factor,
    };
  }

  // Esta función suma todo el plato (si hay varios ingredientes)
  Map<String, double> calculateTotalMeal(List<Map<String, dynamic>> mealItems) {
    double totalCalories = 0;
    double totalProtein = 0;
    
    for (var entry in mealItems) {
      FoodItem item = entry['item'];
      double weight = entry['weight'];
      
      var macros = calculateItemMacros(item, weight);
      totalCalories += macros['calories']!;
      totalProtein += macros['protein']!;
      // ... sumar el resto
    }

    return {
      "totalCalories": totalCalories,
      "totalProtein": totalProtein,
      // ... retornar el resto
    };
  }
}