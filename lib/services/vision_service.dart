import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class VisionService {
  // ---------------------------------------------------------
  // CONFIGURACIÓN
  // ---------------------------------------------------------
  // TODO: Reemplaza esto con tu API Key real de Google Cloud Console
  final String _apiKey = 'TU_API_KEY_DE_GOOGLE_CLOUD'; 
  final String _apiUrl = 'https://vision.googleapis.com/v1/images:annotate';

  /// Recibe un archivo de imagen (File), lo convierte a Base64 y consulta a Google Vision.
  /// Retorna una lista de etiquetas (Strings) ordenadas por confianza.
  Future<List<String>> analizarImagen(File imagen) async {
    try {
      // 1. PRE-PROCESAMIENTO [Según informe pág. 23]
      // Convertir la imagen a bytes y luego a string Base64
      List<int> imageBytes = await imagen.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // 2. CONSTRUCCIÓN DEL BODY (JSON)
      // Solicitamos 'LABEL_DETECTION' para identificar ingredientes
      Map<String, dynamic> requestBody = {
        "requests": [
          {
            "image": {"content": base64Image},
            "features": [
              {
                "type": "LABEL_DETECTION", 
                "maxResults": 10 // Pedimos las 10 mejores coincidencias
              }
            ]
          }
        ]
      };

      // 3. PETICIÓN HTTP POST
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      // 4. PROCESAMIENTO DE RESPUESTA
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        
        // Verificamos si Google encontró algo
        var responses = jsonResponse['responses'] as List;
        if (responses.isEmpty || responses[0]['labelAnnotations'] == null) {
          return []; // No se detectó nada
        }

        List<dynamic> labelsRaw = responses[0]['labelAnnotations'];
        
        // Mapeamos el JSON complejo a una lista simple de Strings
        // Ej: de [{"description": "Banana", "score": 0.9}] a ["Banana"]
        List<String> etiquetas = labelsRaw
            .map((e) => e['description'].toString())
            .toList();

        return etiquetas;
      } else {
        // Manejo de errores de API (ej. Key inválida, cuota excedida)
        print('Error API Vision: ${response.body}');
        throw Exception('Fallo al conectar con Google Vision: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción en VisionService: $e');
      rethrow;
    }
  }
}