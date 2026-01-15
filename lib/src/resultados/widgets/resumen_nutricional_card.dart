import 'package:flutter/material.dart';

class ResumenNutricionalCard extends StatelessWidget {
  const ResumenNutricionalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Resumen Diario',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Calorías consumidas: 1800 kcal'),
            Text('Objetivo: 2000 kcal'),
          ],
        ),
      ),
    );
  }
}
