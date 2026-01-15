import 'package:flutter/material.dart';

class MacroCard extends StatelessWidget {
  const MacroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Macronutrientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Proteínas: 120 g'),
            Text('Carbohidratos: 200 g'),
            Text('Grasas: 60 g'),
          ],
        ),
      ),
    );
  }
}
