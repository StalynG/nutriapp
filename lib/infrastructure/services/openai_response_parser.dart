// ignore_for_file: public_member_api_docs

import 'dart:convert';

import '../../domain/entities/food_analysis.dart';

/// Parser de respuestas de OpenAI
/// Sigue Clean Architecture extrayendo la lógica de parsing
class OpenAIResponseParser {
  /// Parsea una respuesta JSON de OpenAI y la mapea a FoodAnalysis
  /// 
  /// Parámetros:
  /// - [responseBody]: El body de la respuesta HTTP como String
  /// 
  /// Retorna una entidad [FoodAnalysis] mapeada
  /// 
  /// Lanza:
  /// - [FormatException] si el JSON no es válido o no contiene la estructura esperada
  static FoodAnalysis parseResponse(String responseBody) {
    try {
      // Paso 1: Decodificar la respuesta principal de OpenAI
      final Map<String, dynamic> decodedResponse = jsonDecode(responseBody);

      // Paso 2: Extraer el contenido JSON del array de choices
      final String jsonContent = _extractContentFromResponse(decodedResponse);

      if (jsonContent.isEmpty) {
        throw FormatException(
          'No se encontró contenido JSON en la respuesta de OpenAI',
        );
      }

      // Paso 3: Decodificar el JSON extraído
      final Map<String, dynamic> foodJson = jsonDecode(jsonContent);

      // Paso 4: Mapear a la entidad FoodAnalysis
      return FoodAnalysis.fromJson(foodJson);
    } on FormatException catch (e) {
      throw FormatException(
        'Error al parsear respuesta de OpenAI: ${e.message}',
      );
    } catch (e) {
      throw FormatException(
        'Error inesperado al procesar respuesta de OpenAI: ${e.toString()}',
      );
    }
  }

  /// Extrae el contenido del JSON del array de choices
  /// 
  /// Estructura esperada:
  /// ```json
  /// {
  ///   "choices": [
  ///     {
  ///       "message": {
  ///         "content": "{...JSON del análisis nutricional...}"
  ///       }
  ///     }
  ///   ]
  /// }
  /// ```
  static String _extractContentFromResponse(Map<String, dynamic> response) {
    // Validar que choices exista y sea una lista
    if (!response.containsKey('choices') || response['choices'] is! List) {
      return '';
    }

    final choices = response['choices'] as List;

    // Validar que haya al menos una opción
    if (choices.isEmpty) {
      return '';
    }

    final firstChoice = choices[0];

    // Validar estructura del primer choice
    if (firstChoice is! Map<String, dynamic>) {
      return '';
    }

    final message = firstChoice['message'];

    // Validar que message existe y tiene content
    if (message is! Map<String, dynamic> || message['content'] == null) {
      return '';
    }

    // Retornar el contenido trimmed
    return message['content'].toString().trim();
  }

  /// Extrae un mensaje de error amigable de la respuesta de error de OpenAI
  /// 
  /// Parámetros:
  /// - [errorResponseBody]: El body de la respuesta de error como String
  /// 
  /// Retorna un String con el mensaje de error, o un mensaje genérico si no se puede parsear
  static String extractErrorMessage(String errorResponseBody) {
    try {
      final decoded = jsonDecode(errorResponseBody);
      if (decoded is Map && decoded['error'] != null) {
        final error = decoded['error'];
        if (error is Map && error['message'] != null) {
          return error['message'].toString();
        }
      }
    } catch (_) {
      // Ignorar errores de parsing
    }
    return 'Respuesta inválida de OpenAI';
  }

  /// Constructor vacío privado (clase utilitaria)
  OpenAIResponseParser._();
}
