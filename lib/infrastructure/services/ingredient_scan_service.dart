// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../domain/entities/ingredient_scan.dart';
import '../../domain/repositories/ingredient_scan_repository.dart';

/// Servicio de escaneo de ingredientes con API
class IngredientScanService implements IngredientScanRepository {
  final String _baseUrl;
  final String Function() _getAuthToken;
  late http.Client _httpClient;

  IngredientScanService({
    required String baseUrl,
    required String Function() getAuthToken,
  })  : _baseUrl = baseUrl,
        _getAuthToken = getAuthToken {
    _httpClient = http.Client();
  }

  /// Obtiene headers con autenticación
  Map<String, String> _getHeaders() {
    return {
      'Authorization': 'Bearer ${_getAuthToken()}',
    };
  }

  @override
  Future<IngredientScanResult> scanIngredients(IngredientScanRequest request) async {
    try {
      final imageBytes = await request.imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/ingredients/scan'),
        headers: {
          'Content-Type': 'application/json',
          ..._getHeaders(),
        },
        body: jsonEncode({
          'image': base64Image,
          'image_name': request.imageFile.path.split('/').last,
          'user_id': request.userId,
          'description': request.description,
        }),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return IngredientScanResult.fromJson(data['scan_result']);
      } else {
        throw HttpException('Error escaneo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al escanear ingredientes: ${e.toString()}');
    }
  }

  @override
  Future<List<IngredientScanResult>> getScanHistory(String userId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/scans/history?user_id=$userId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data
            .map((item) => IngredientScanResult.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException('Error obteniendo historial');
      }
    } catch (e) {
      throw Exception('Error al obtener historial: ${e.toString()}');
    }
  }

  @override
  Future<IngredientScanResult?> getScanById(String scanId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/scans/$scanId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return IngredientScanResult.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw HttpException('Error obteniendo escaneo');
      }
    } catch (e) {
      throw Exception('Error al obtener escaneo: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteScan(String scanId) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('$_baseUrl/scans/$scanId'),
        headers: _getHeaders(),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw HttpException('Error eliminando escaneo');
      }
    } catch (e) {
      throw Exception('Error al eliminar escaneo: ${e.toString()}');
    }
  }

  @override
  Future<void> saveScan(String scanId) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/scans/$scanId/save'),
        headers: _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw HttpException('Error guardando escaneo');
      }
    } catch (e) {
      throw Exception('Error al guardar escaneo: ${e.toString()}');
    }
  }

  @override
  Future<List<IngredientScanResult>> getSavedScans(String userId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/scans/saved?user_id=$userId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data
            .map((item) => IngredientScanResult.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException('Error obteniendo escaneos guardados');
      }
    } catch (e) {
      throw Exception('Error al obtener escaneos guardados: ${e.toString()}');
    }
  }
}
