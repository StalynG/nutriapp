import 'package:flutter/material.dart';
import '../ingredients/ingredients_screen.dart';
import '../scanned_foods/scanned_foods_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NutriApp')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => IngredientsScreen()),
                );
              },
              child: const Text('Ver Ingredientes'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ScannedFoodsScreen()),
                );
              },
              child: const Text('Ver Comidas Escaneadas'),
            ),
          ],
        ),
      ),
    );
  }
}
