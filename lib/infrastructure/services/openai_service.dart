// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/food_analysis.dart';

/// Modelo para mensajes de chat
class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
  };
}

/// Servicio de integración con OpenAI API
class OpenAIService {
  final String _apiKey;
  final Uri _endpoint = Uri.parse('https://api.openai.com/v1/chat/completions');
  final String _model;
  final double _temperature;
  final int _maxTokens;

  OpenAIService({
    String? apiKey,
    String model = 'gpt-4o',
    double temperature = 0.7,
    int maxTokens = 2000,
  })  : _apiKey = apiKey ?? dotenv.env['OPENAI_API_KEY'] ?? '',
        _model = model,
        _temperature = temperature,
        _maxTokens = maxTokens;

  /// Valida que la API key esté configurada
  bool get isConfigured => _apiKey.isNotEmpty;

  /// Analiza una imagen [image] y devuelve un [FoodAnalysis].
  /// Lanza excepciones si la API falla o la respuesta no contiene el JSON esperado.
  Future<FoodAnalysis> analyzeImage(File image) async {
    if (_apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY no configurada en .env');
    }

    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    final systemPrompt =
        'Eres un nutricionista experto. Analiza la imagen, identifica la comida y estima calorías y macros. Responde solo en JSON';

    final userInstruction =
        'Recibirás una imagen en Base64. Analízala y responde EXCLUSIVAMENTE un JSON con estos campos exactos: descripcion_plato (String), calorias_totales (int), proteinas_totales_g (double), grasas_totales_g (double), carbs_totales_g (double), ingredientes (List<String>). Imagen base64: $base64Image';

    final Map<String, dynamic> body = {
      'model': _model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userInstruction},
      ],
      'response_format': {'type': 'json_object'},
      'temperature': _temperature,
      'max_tokens': _maxTokens,
    };

    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    final response = await http
        .post(_endpoint, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw HttpException(
        'OpenAI API request failed with status ${response.statusCode}: ${response.body}',
      );
    }

    final Map<String, dynamic> decoded = jsonDecode(response.body);

    try {
      // OpenAI Chat Completions normalmente devuelve: { choices: [ { message: { content: '...' } } ] }
      String content = '';

      if (decoded.containsKey('choices') &&
          decoded['choices'] is List &&
          decoded['choices'].isNotEmpty) {
        final firstChoice = decoded['choices'][0];
        if (firstChoice is Map) {
          // new format: firstChoice['message']['content']
          final message = firstChoice['message'];
          if (message != null && message is Map && message['content'] != null) {
            content = message['content'].toString();
          } else if (firstChoice['text'] != null) {
            content = firstChoice['text'].toString();
          }
        }
      }

      if (content.isEmpty) {
        // Try to find a JSON object directly in the raw response as fallback
        final jsonMatch = RegExp(r"\{[\s\S]*\}").firstMatch(response.body);
        if (jsonMatch != null) {
          content = jsonMatch.group(0)!;
        }
      }

      if (content.isEmpty) {
        throw FormatException(
          'No se encontró contenido JSON en la respuesta de OpenAI',
        );
      }

      final Map<String, dynamic> jsonResult =
          jsonDecode(content) as Map<String, dynamic>;

      // Construimos la entidad y devolvemos
      return FoodAnalysis.fromJson(jsonResult);
    } catch (e) {
      // Re-lanzamos con contexto claro
      throw FormatException(
        'Error al parsear la respuesta de OpenAI: ${e.toString()}',
      );
    }
  }

  /// Envía una solicitud de chat genérica a OpenAI
  Future<String> sendMessage(String message, {List<ChatMessage>? previousMessages}) async {
    if (_apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY no configurada en .env');
    }

    final messages = <Map<String, dynamic>>[
      if (previousMessages != null) ...previousMessages.map((m) => m.toJson()),
      {'role': 'user', 'content': message},
    ];

    final Map<String, dynamic> body = {
      'model': _model,
      'messages': messages,
      'temperature': _temperature,
      'max_tokens': _maxTokens,
    };

    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    final response = await http
        .post(_endpoint, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw HttpException(
        'OpenAI API request failed with status ${response.statusCode}: ${response.body}',
      );
    }

    final Map<String, dynamic> decoded = jsonDecode(response.body);

    try {
      if (decoded.containsKey('choices') &&
          decoded['choices'] is List &&
          decoded['choices'].isNotEmpty) {
        final firstChoice = decoded['choices'][0];
        if (firstChoice is Map) {
          final message = firstChoice['message'];
          if (message != null && message is Map && message['content'] != null) {
            return message['content'].toString();
          }
        }
      }

      throw FormatException('No se encontró contenido en la respuesta de OpenAI');
    } catch (e) {
      throw FormatException('Error al parsear la respuesta de OpenAI: ${e.toString()}');
    }
  }

  /// Obtiene recomendaciones nutricionales basadas en el análisis de comida
  Future<String> getNutritionRecommendations(FoodAnalysis analysis) async {
    final prompt = '''
Basándote en el siguiente análisis nutricional de una comida, proporciona recomendaciones personalizadas:
- Plato: ${analysis.descripcionPlato}
- Calorías: ${analysis.caloriasTotales}
- Proteínas: ${analysis.proteinasTotalesG}g
- Grasas: ${analysis.grasasTotalesG}g
- Carbohidratos: ${analysis.carbsTotalesG}g

Por favor, proporciona:
1. Evaluación de la comida
2. Recomendaciones de mejora
3. Alternativas más saludables
4. Consejos nutricionales específicos
''';

    return sendMessage(prompt);
  }

  /// Genera un plan de comidas nutricionales personalizados
  Future<String> generateMealPlan({
    required int days,
    required int dailyCalories,
    required List<String> dietaryRestrictions,
  }) async {
    final restrictions = dietaryRestrictions.join(', ');
    final prompt = '''
Por favor, genera un plan de comidas para $days días con las siguientes características:
- Calorías diarias objetivo: $dailyCalories kcal
- Restricciones dietéticas: $restrictions
- Incluye desayuno, almuerzo, merienda y cena
- Para cada comida, especifica calorías aproximadas
- Proporciona consejos nutricionales

Responde de forma estructurada y clara.
''';

    return sendMessage(prompt);
  }
}
