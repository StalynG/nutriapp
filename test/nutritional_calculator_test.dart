import 'package:flutter_test/flutter_test.dart';
import 'package:nutriapp/models/food_item.dart';
import 'package:nutriapp/services/nutritional_calculator.dart'; // Ajusta el import

void main() {
  test('Debe calcular correctamente los macros para 200g de pollo', () {
    // 1. Arrange (Preparar datos de prueba)
    final calculator = NutritionalCalculator();
    final pollo = FoodItem(
      name: 'Pollo', 
      caloriesPer100g: 165, 
      proteinPer100g: 31, 
      carbsPer100g: 0, 
      fatPer100g: 3.6
    );

    // 2. Act (Ejecutar la lógica)
    // Si tengo 200g, debería ser el doble de los valores base
    final result = calculator.calculateItemMacros(pollo, 200);

    // 3. Assert (Verificar que cumple la fórmula del informe)
    expect(result['calories'], 330); // 165 * 2
    expect(result['protein'], 62);   // 31 * 2
  });
}