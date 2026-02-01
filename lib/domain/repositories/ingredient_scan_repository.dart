// ignore_for_file: public_member_api_docs

import '../entities/ingredient_scan.dart';

/// Contrato para el repositorio de escaneo de ingredientes
abstract class IngredientScanRepository {
  /// Escanea ingredientes desde una imagen
  Future<IngredientScanResult> scanIngredients(IngredientScanRequest request);

  /// Obtiene el historial de escaneos del usuario
  Future<List<IngredientScanResult>> getScanHistory(String userId);

  /// Obtiene un escaneo específico
  Future<IngredientScanResult?> getScanById(String scanId);

  /// Elimina un escaneo
  Future<void> deleteScan(String scanId);

  /// Guarda un escaneo como favorito
  Future<void> saveScan(String scanId);

  /// Obtiene escaneos guardados
  Future<List<IngredientScanResult>> getSavedScans(String userId);
}
