import 'package:flutter/material.dart';

class CaloriasCard extends StatelessWidget {
  const CaloriasCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Calorías Totales',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '1800 kcal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
