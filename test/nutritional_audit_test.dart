import 'package:flutter_test/flutter_test.dart';
import 'package:nutriapp/models/food_item.dart';
import 'package:nutriapp/services/nutritional_calculator.dart';

void main() {
  group('NUT-40: Auditoría de Precisión Decimal', () {
    final calculator = NutritionalCalculator();

    test('Debe evitar errores de punto flotante en sumatorias complejas', () {
      // Caso Realista: Varios ingredientes con decimales
      final item1 = FoodItem(name: "A", caloriesPer100g: 100.2, proteinPer100g: 10.1, carbsPer100g: 0, fatPer100g: 0);
      final item2 = FoodItem(name: "B", caloriesPer100g: 200.1, proteinPer100g: 20.2, carbsPer100g: 0, fatPer100g: 0);

      // Simulamos un plato con 100g de cada uno
      final plato = [
        {'item': item1, 'weight': 100.0},
        {'item': item2, 'weight': 100.0},
      ];

      final resultado = calculator.calculateTotalMeal(plato);

      // VALIDACIÓN:
      // Sin corrección, esto podría dar 300.29999999999995
      // Esperamos que el sistema lo redondee correctamente a 300.3
      expect(resultado['totalCalories'], 300.3);
      expect(resultado['totalProtein'], 30.3);
    });
  });
}