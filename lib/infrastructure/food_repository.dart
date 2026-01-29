import '../models/food_model.dart';

class FoodRepository {
  // Simula la obtención del histórico para NUT-37
  Future<List<Food>> getScannedFoodHistory() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simula carga

    // Aquí convertimos datos crudos al modelo Food usando el nuevo fromJson
    final List<Map<String, dynamic>> rawData = [
      {
        'id': '101', 
        'name': 'Manzana Roja', 
        'description': 'Fruta escaneada por la mañana', 
        'category': 'Frutas',
        'imagePath': 'https://cdn-icons-png.flaticon.com/512/415/415733.png'
      },
      {
        'id': '102', 
        'name': 'Pollo a la plancha', 
        'description': 'Proteína del almuerzo', 
        'category': 'Carnes',
        'imagePath': null
      },
    ];

    return rawData.map((json) => Food.fromJson(json)).toList();
  }
}