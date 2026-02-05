import 'dart:io';
import 'package:flutter/material.dart';
// Importa tus modelos y servicios
import 'package:nutriapp/models/food_model.dart';
import 'package:nutriapp/services/vision_service.dart';
import 'package:nutriapp/services/nutritional_engine.dart';

class NutritionalInfoScreen extends StatefulWidget {
  // Ahora recibimos el archivo de imagen capturado por la cámara
  final File imageFile;

  const NutritionalInfoScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<NutritionalInfoScreen> createState() => _NutritionalInfoScreenState();
}

class _NutritionalInfoScreenState extends State<NutritionalInfoScreen> {
  // 1. Instanciamos los servicios creados en Sprints anteriores
  final VisionService _visionService = VisionService();
  final NutritionalEngine _nutritionalEngine = NutritionalEngine();

  bool _isLoading = true;
  FoodModel? _foodData;
  String? _errorMessage;
  String? _feedbackMessage; // Para mostrar el mensaje de alerta del motor

  @override
  void initState() {
    super.initState();
    // Iniciamos el análisis apenas carga la pantalla
    _analizarFoto();
  }

  // Lógica principal: Visión -> Motor -> UI
  Future<void> _analizarFoto() async {
    try {
      setState(() => _isLoading = true);

      // PASO 1 (NUT-33): Enviar foto a Google Vision API
      // Esto devuelve una lista de etiquetas, ej: ["Grilled Chicken", "Meat"]
      final etiquetas = await _visionService.analizarImagen(widget.imageFile);

      if (etiquetas.isEmpty) {
        throw Exception("No se pudo identificar ningún alimento en la imagen.");
      }

      // Tomamos la etiqueta con mayor confianza (la primera)
      String mejorEtiqueta = etiquetas.first;

      // PASO 2 (NUT-24): Procesar con el Motor Nutricional
      // Nota: Aquí simulamos los datos de usuario (meta/consumido) 
      // En una app real, esto vendría de tu UserProvider o AuthBloc
      final resultadoMotor = _nutritionalEngine.procesarAlimentoDetectado(
        etiquetaIA: mejorEtiqueta,
        pesoUsuario: 200.0, // Valor por defecto o podrías pedirlo con un Dialog antes
        metaCalorica: 2000.0,
        consumidoHoy: 850.0,
      );

      // PASO 3: Adaptar la respuesta del Motor (Map) a tu FoodModel (UI)
      // Extraemos los datos del JSON que devuelve el motor
      final datosNutricionales = resultadoMotor['nutrition_data'] as Map<String, double>;

      setState(() {
        _foodData = FoodModel(
          productName: resultadoMotor['item_name'], // Ej. "Pechuga de Pollo"
          calories: datosNutricionales['calories']?.toInt() ?? 0,
          proteins: datosNutricionales['protein'] ?? 0.0,
          carbs: datosNutricionales['carbs'] ?? 0.0,
          fats: datosNutricionales['fat'] ?? 0.0,
        );
        
        // Guardamos el feedback (ej. "¡Cuidado! Te vas a pasar...")
        _feedbackMessage = resultadoMotor['user_feedback'];
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = "Error al analizar: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis Inteligente'),
        backgroundColor: Colors.green,
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
            Text("Analizando imagen con IA..."),
            Text("Detectando ingredientes...", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _analizarFoto,
                child: const Text("Reintentar"),
              )
            ],
          ),
        ),
      );
    }

    if (_foodData != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen capturada por el usuario
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  widget.imageFile,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Resultado del Análisis
            Center(
              child: Column(
                children: [
                   Text(
                     _foodData!.productName,
                     style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                     textAlign: TextAlign.center,
                   ),
                   const SizedBox(height: 8),
                   // Feedback del Motor (Alerta o Éxito)
                   Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(
                       color: _feedbackMessage!.contains("Cuidado") ? Colors.orange.shade100 : Colors.green.shade100,
                       borderRadius: BorderRadius.circular(8)
                     ),
                     child: Text(
                       _feedbackMessage ?? "",
                       style: TextStyle(
                         color: _feedbackMessage!.contains("Cuidado") ? Colors.orange.shade900 : Colors.green.shade900,
                         fontWeight: FontWeight.bold
                       ),
                       textAlign: TextAlign.center,
                     ),
                   )
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            const Text("Información Nutricional (Estimada)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const Divider(),
            
            // Tabla de macros
            _buildNutrientRow("Calorías", "${_foodData!.calories} kcal", true),
            _buildNutrientRow("Proteínas", "${_foodData!.proteins.toStringAsFixed(1)} g", false),
            _buildNutrientRow("Carbohidratos", "${_foodData!.carbs.toStringAsFixed(1)} g", false),
            _buildNutrientRow("Grasas", "${_foodData!.fats.toStringAsFixed(1)} g", false),
            
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Lógica para guardar en Firebase (Sprint 4)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comida registrada en tu diario'))
                  );
                },
                icon: const Icon(Icons.check_circle),
                label: const Text("Confirmar y Registrar"),
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
