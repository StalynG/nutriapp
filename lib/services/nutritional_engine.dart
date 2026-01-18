import '../models/food_item.dart';
import 'nutritional_calculator.dart'; // Tu código de la tarea anterior

class NutritionalEngine {
  final NutritionalCalculator _calculator = NutritionalCalculator();

  // Simulación de Base de Datos (Mapeo) 
  // En el futuro, esto se reemplaza por una llamada real a Firebase/PostgreSQL
  FoodItem _buscarEnBaseDeDatos(String etiquetaDetectada) {
    // Esto es un "Mock" temporal para que el Sprint 2 funcione
    if (etiquetaDetectada.toLowerCase().contains('pollo')) {
      return FoodItem(
        name: 'Pechuga de Pollo',
        caloriesPer100g: 165,
        proteinPer100g: 31,
        carbsPer100g: 0,
        fatPer100g: 3.6,
      );
    }
    // Retornar un valor por defecto o lanzar error si no existe
    return FoodItem(name: 'Desconocido', caloriesPer100g: 0, proteinPer100g: 0, carbsPer100g: 0, fatPer100g: 0);
  }

  // Lógica Principal del Motor 
  Map<String, dynamic> procesarAlimentoDetectado({
    required String etiquetaIA,      // Lo que dice Google Vision (ej. "Grilled Chicken")
    required double pesoUsuario,     // Lo que confirma el usuario (ej. 200g)
    required double metaCalorica,    // Del perfil de usuario (ej. 2000 kcal)
    required double consumidoHoy,    // Lo que ya ha comido hoy
  }) {
    
    // 1. MAPEO: Buscar info nutricional base
    FoodItem alimentoBase = _buscarEnBaseDeDatos(etiquetaIA);

    // 2. CÁLCULO: Usar la fórmula de NUT-12 
    Map<String, double> macros = _calculator.calculateItemMacros(alimentoBase, pesoUsuario);

    // 3. COMPARACIÓN CON METAS (Feedback) 
    double nuevasCaloriasTotales = consumidoHoy + macros['calories']!;
    bool excedeMeta = nuevasCaloriasTotales > metaCalorica;

    // Estructura de Salida JSON [cite: 521, 525]
    return {
      "item_name": alimentoBase.name,
      "nutrition_data": macros,
      "status_alert": excedeMeta ? "WARNING_LIMIT_EXCEEDED" : "OK", // Bandera de alerta [cite: 473]
      "user_feedback": excedeMeta 
          ? "¡Cuidado! Este alimento te hará superar tu meta diaria." 
          : "¡Buen trabajo! Sigues dentro de tu rango.",
    };
  }
}