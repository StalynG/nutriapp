import 'package:flutter/material.dart';
import '../../models/food_model.dart';
import '../../infrastructure/services/food_repository.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FoodRepository _repository = FoodRepository();
  late Future<List<Food>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _repository.getScannedFoodHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Escaneos'),
        backgroundColor: Colors.green, // Ajusta a tu color
      ),
      body: FutureBuilder<List<Food>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          // 1. Cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // 3. Vacío
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay historial disponible"));
          }

          final foods = snapshot.data!;

          // 4. Lista
          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: foods.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final food = foods[index];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  // Imagen (URL o Icono por defecto)
                  leading: SizedBox(
                    width: 60,
                    height: 60,
                    child: food.imagePath != null
                        ? Image.network(food.imagePath!, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, color: Colors.grey);
                          })
                        : const Icon(Icons.fastfood, size: 40, color: Colors.orange),
                  ),
                  // Título: Nombre de la comida
                  title: Text(
                    food.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  // Subtítulo: Categoría y Descripción corta
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          food.category.toUpperCase(),
                          style: TextStyle(
                            color: Colors.green[800],
                            fontSize: 10,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        food.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    // Aquí iría la navegación al detalle
                    // Navigator.pushNamed(context, '/detail', arguments: food);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}