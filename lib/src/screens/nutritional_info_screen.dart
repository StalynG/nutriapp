import 'package:flutter/material.dart';

class NutritionalInfoScreen extends StatelessWidget {
  const NutritionalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ---------------------------------------------------------
    // DATOS MOCK (Simulados para la visualización)
    // ---------------------------------------------------------
    final double caloriesConsumed = 1250;
    final double caloriesGoal = 2000;
    final double progress = (caloriesConsumed / caloriesGoal).clamp(0.0, 1.0);
    
    // Colores de la app (puedes ajustarlos a tu theme)
    final Color primaryColor = const Color(0xFF4CAF50); // Verde NutriApp
    final Color backgroundColor = const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Información Nutricional",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87, // Color del texto e iconos
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓN 1: RESUMEN DE CALORÍAS ---
            const Text(
              "Resumen Diario",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildCaloriesCard(caloriesConsumed, caloriesGoal, progress, primaryColor),

            const SizedBox(height: 25),

            // --- SECCIÓN 2: MACRONUTRIENTES ---
            const Text(
              "Macronutrientes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMacroCard("Proteínas", "110g", 0.7, Colors.blueAccent),
                _buildMacroCard("Carbos", "200g", 0.5, Colors.orangeAccent),
                _buildMacroCard("Grasas", "45g", 0.3, Colors.redAccent),
              ],
            ),

            const SizedBox(height: 25),

            // --- SECCIÓN 3: REGISTRO DE COMIDAS ---
            const Text(
              "Comidas de Hoy",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildMealItem("Desayuno", "Avena con manzana", 350, primaryColor),
            _buildMealItem("Almuerzo", "Pechuga de pollo y arroz", 600, primaryColor),
            _buildMealItem("Cena", "Ensalada César", 300, primaryColor),
            
            // Espacio extra al final
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // WIDGET: Tarjeta Principal de Calorías
  Widget _buildCaloriesCard(double consumed, double goal, double progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Consumido", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    "${consumed.toInt()} kcal",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Meta", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    "${goal.toInt()} kcal",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${(progress * 100).toInt()}% completado",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: Tarjeta de Macros
  Widget _buildMacroCard(String label, String value, double percent, Color color) {
    return Container(
      width: 105, // Ancho fijo para que se alineen bien
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 5,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // WIDGET: Item de la lista de comidas
  Widget _buildMealItem(String title, String subtitle, int cals, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(Icons.restaurant, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        trailing: Text(
          "$cals kcal",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}

