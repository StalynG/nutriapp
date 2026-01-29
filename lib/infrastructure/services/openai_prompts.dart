// ignore_for_file: public_member_api_docs

/// Clase que centraliza los prompts para OpenAI
/// Sigue Clean Architecture separando la lógica de prompts
class OpenAIPrompts {
  /// System prompt que instruye a GPT-4o a actuar como nutricionista experto
  static String get systemPrompt {
    return '''Eres un nutricionista experto certificado. Tu rol es analizar imágenes de alimentos 
y proporcionar información nutricional precisa y científicamente basada.

IMPORTANTE:
- Responde ÚNICAMENTE en formato JSON válido
- No incluyas texto adicional antes ni después del JSON
- No uses markdown, asteriscos u otros caracteres especiales fuera del JSON
- El JSON debe ser válido y parseable

Estructura exacta del JSON de respuesta:
{
  "descripcion_plato": "descripción clara del alimento",
  "calorias_totales": número entero de calorías,
  "proteinas_totales_g": número decimal de proteínas,
  "grasas_totales_g": número decimal de grasas,
  "carbs_totales_g": número decimal de carbohidratos,
  "ingredientes": ["ingrediente 1", "ingrediente 2"]
}''';
  }

  /// Construye el mensaje del usuario con la imagen en base64
  static String buildUserMessage(String base64Image) {
    return '''Analiza esta imagen de alimento. Identifica qué comida es, estima las porciones y 
proporciona el análisis nutricional.

Responde con JSON que contenga:
- descripcion_plato: Descripción clara de qué es el plato
- calorias_totales: Calorías totales estimadas para la porción mostrada
- proteinas_totales_g: Gramos de proteína
- grasas_totales_g: Gramos de grasa total
- carbs_totales_g: Gramos de carbohidratos
- ingredientes: Lista de ingredientes identificados en la imagen

Imagen en formato base64:
data:image/jpeg;base64,$base64Image''';
  }
}
