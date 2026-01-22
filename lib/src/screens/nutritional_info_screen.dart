import 'package:flutter/material.dart';
// Asegúrate de que esta importación coincida con tu estructura real
import 'package:nutriapp/models/food_model.dart'; 

class NutritionalInfoScreen extends StatefulWidget {
  final String barcode;

  const NutritionalInfoScreen({Key? key, required this.barcode}) : super(key: key);

  @override
  State<NutritionalInfoScreen> createState() => _NutritionalInfoScreenState();
}

class _NutritionalInfoScreenState extends State<NutritionalInfoScreen> {
  bool _isLoading = true;
  FoodModel? _foodData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNutritionalInfo();
  }

  // Simulación de la llamada End-To-End (Infraestructura -> API)
  Future<void> _fetchNutritionalInfo() async {
    try {
      // TODO: Aquí debes llamar a tu repositorio real. 
      // Ejemplo: final result = await GetIt.I<FoodRepository>().getByBarcode(widget.barcode);
      
      // Simulación de espera de red
      await Future.delayed(const Duration(seconds: 2));

      // Simulación de datos recibidos (MOCK)
      // Reemplaza esto con la respuesta real de tu backend
      setState(() {
        _foodData = FoodModel(
          productName: "Yogurt Griego Natural", // Asumiendo campos de tu modelo
          calories: 120,
          proteins: 10.5,
          carbs: 8.0,
          fats: 0.5,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "No se pudo obtener información para el código: ${widget.barcode}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información Nutricional'),
        backgroundColor: Colors.green, // Ajusta a tu tema
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Buscando producto..."),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchNutritionalInfo,
              child: const Text("Reintentar"),
            )
          ],
        ),
      );
    }

    if (_foodData != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera del producto
            Center(
              child: Column(
                children: [
                   const Icon(Icons.fastfood, size: 80, color: Colors.orange), // Placeholder de imagen
                   const SizedBox(height: 10),
                   Text(
                     _foodData!.productName, // Usando el modelo
                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                     textAlign: TextAlign.center,
                   ),
                   Text("Código: ${widget.barcode}", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            const Text("Información por porción", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const Divider(),
            
            // Tabla de macros
            _buildNutrientRow("Calorías", "${_foodData!.calories} kcal", true),
            _buildNutrientRow("Proteínas", "${_foodData!.proteins} g", false),
            _buildNutrientRow("Carbohidratos", "${_foodData!.carbs} g", false),
            _buildNutrientRow("Grasas", "${_foodData!.fats} g", false),
            
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Lógica para guardar en la dieta diaria
                  // TODO: Implementar lógica de guardado
                },
                icon: const Icon(Icons.add),
                label: const Text("Añadir a mi Diario"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white
                ),
              ),
            )
          ],
        ),
      );
    }

    return const Center(child: Text("Sin datos"));
  }

  Widget _buildNutrientRow(String label, String value, bool isBold) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
