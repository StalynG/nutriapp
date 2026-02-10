import 'package:flutter/material.dart';
import '../../models/food_model.dart';
import '../../infrastructure/food_repository.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = FoodRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Comidas')),
      body: FutureBuilder<List<Food>>(
        future: repository.getScannedFoodHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay historial disponible.'));
          }

          final history = snapshot.data!;

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: item.imagePath != null 
                    ? NetworkImage(item.imagePath!) 
                    : null,
                  child: item.imagePath == null ? const Icon(Icons.fastfood) : null,
                ),
                title: Text(item.name),
                subtitle: Text(item.description),
                trailing: Text(item.category, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              );
            },
          );
        },
      ),
    );
  }
}