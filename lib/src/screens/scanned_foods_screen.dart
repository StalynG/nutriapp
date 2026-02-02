import 'package:flutter/material.dart';
import '../../models/scanned_food.dart';

class ScannedFoodsScreen extends StatelessWidget {
  ScannedFoodsScreen({super.key});

  final List<ScannedFood> scannedFoods = [
    ScannedFood(
      name: 'Ensalada César',
      calories: 320,
      scannedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ScannedFood(
      name: 'Hamburguesa',
      calories: 540,
      scannedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comidas Escaneadas')),
      body: ListView.builder(
        itemCount: scannedFoods.length,
        itemBuilder: (context, index) {
          final food = scannedFoods[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(food.name),
              subtitle: Text(
                '${food.calories} kcal · ${food.scannedAt.day}/${food.scannedAt.month}',
              ),
            ),
          );
        },
      ),
    );
  }
}
