import '../../models/food_model.dart'; // Asegúrate de importar tu archivo

class FoodRepository {
  
  // Simulación: Obtener el historial desde tu lista dummyFoods
  Future<List<Food>> getScannedFoodHistory() async {
    // Simulamos un pequeño retraso de red (como si fuera una API real)
    await Future.delayed(const Duration(seconds: 1));

    // Retornamos la lista que definiste en food_model.dart
    return dummyFoods; 
  }
}