import 'package:flutter/material.dart';
import '../../models/ingredient.dart';

class IngredientsScreen extends StatelessWidget {
  IngredientsScreen({super.key});

  final List<Ingredient> ingredients = [
    Ingredient(name: 'Tomate', calories: 18, category: 'Vegetales'),
    Ingredient(name: 'Pollo', calories: 165, category: 'Proteína'),
    Ingredient(name: 'Arroz', calories: 130, category: 'Cereales'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingredientes')),
      body: ListView.builder(
        itemCount: ingredients.length,
        itemBuilder: (context, index) {
          final ingredient = ingredients[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.food_bank),
              title: Text(ingredient.name),
              subtitle: Text(
                '${ingredient.category} · ${ingredient.calories} kcal',
              ),
            ),
          );
        },
      ),
    );
  }
}
