// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/food_analysis.dart';

class OpenAIService {
  final String _apiKey;
  final Uri _endpoint = Uri.parse('https://api.openai.com/v1/chat/completions');

  OpenAIService({String? apiKey})
    : _apiKey = apiKey ?? dotenv.env['OPENAI_API_KEY'] ?? '';

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
      'model': 'gpt-4o',
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userInstruction},
      ],
      // Forzamos que la respuesta venga como objeto JSON
      'response_format': {'type': 'json_object'},
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
}
//////////////////////