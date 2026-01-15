import 'package:flutter/material.dart';
import '../widgets/nutrient_card.dart';

class ResultadosScreen extends StatelessWidget {
  const ResultadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados Nutricionales'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: const [
            NutrientCard(label: 'Calorías', value: '2200 kcal'),
            NutrientCard(label: 'Proteínas', value: '120 g'),
            NutrientCard(label: 'Carbohidratos', value: '250 g'),
            NutrientCard(label: 'Grasas', value: '70 g'),
          ],
        ),
      ),
    );
  }
}
