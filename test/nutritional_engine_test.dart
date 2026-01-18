import 'package:flutter_test/flutter_test.dart';
import 'package:nutriapp/services/nutritional_engine.dart';

void main() {
  test('NUT-24: El motor debe generar alerta si se excede la meta calórica', () {
    // 1. Arrange
    final engine = NutritionalEngine();
    
    // 2. Act: Usuario tiene meta de 2000, ya comió 1800, y va a comer 400 cal de pollo
    // (200g de pollo son aprox 330 kcal, así que 1800 + 330 = 2130 -> Excede)
    final resultado = engine.procesarAlimentoDetectado(
      etiquetaIA: 'pollo',
      pesoUsuario: 200, 
      metaCalorica: 2000, 
      consumidoHoy: 1800,
    );

    // 3. Assert [cite: 473]
    expect(resultado['status_alert'], 'WARNING_LIMIT_EXCEEDED');
    expect(resultado['nutrition_data']['calories'], 330.0);
  });
}