// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/entities/ingredient_scan.dart';
import '../domain/entities/nutritional_result.dart';
import '../domain/repositories/ingredient_scan_repository.dart';
import '../domain/repositories/scan_result_repository.dart';
import '../infrastructure/services/nutrition_persistence_service.dart';

enum ScanState { idle, scanning, success, error }

/// Provider que gestiona escaneos de ingredientes
class IngredientScanProvider extends ChangeNotifier {
  final IngredientScanRepository _repository;
  final ScanResultRepository _resultRepository;
  final NutritionPersistenceService _nutritionService;

  ScanState _state = ScanState.idle;
  String _error = '';
  IngredientScanResult? _lastScan;
  NutritionalResult? _lastNutritionalResult;
  List<IngredientScanResult> _scanHistory = [];
  List<IngredientScanResult> _savedScans = [];
  List<NutritionalResult> _nutritionalResults = [];
  List<NutritionalResult> _savedNutritionalResults = [];

  IngredientScanProvider(
    this._repository,
    this._resultRepository,
    this._nutritionService,
  );

  // Getters
  ScanState get state => _state;
  String get error => _error;
  IngredientScanResult? get lastScan => _lastScan;
  NutritionalResult? get lastNutritionalResult => _lastNutritionalResult;
  List<IngredientScanResult> get scanHistory => List.unmodifiable(_scanHistory);
  List<IngredientScanResult> get savedScans => List.unmodifiable(_savedScans);
  List<NutritionalResult> get nutritionalResults => List.unmodifiable(_nutritionalResults);
  List<NutritionalResult> get savedNutritionalResults => List.unmodifiable(_savedNutritionalResults);
  bool get isScanning => _state == ScanState.scanning;

  /// Escanea ingredientes desde una imagen
  Future<void> scanIngredients({
    required File imageFile,
    required String userId,
    String? description,
  }) async {
    _state = ScanState.scanning;
    _error = '';
    notifyListeners();

    try {
      final request = IngredientScanRequest(
        imageFile: imageFile,
        userId: userId,
        description: description,
      );

      _lastScan = await _repository.scanIngredients(request);
      _state = ScanState.success;
      
      // Agregar al historial
      _scanHistory.insert(0, _lastScan!);

      // Calculate nutritional result
      if (_lastScan != null && _lastScan!.ingredients.isNotEmpty) {
        await _calculateAndStoreNutritionalResult(
          userId: userId,
          scanId: _lastScan!.id,
          ingredients: _lastScan!.ingredients,
          notes: description,
        );
      }
    } catch (e) {
      _error = 'Error al escanear: ${e.toString()}';
      _state = ScanState.error;
    }

    notifyListeners();
  }

  /// Carga el historial de escaneos
  Future<void> loadScanHistory(String userId) async {
    _state = ScanState.scanning;
    _error = '';
    notifyListeners();

    try {
      _scanHistory = await _repository.getScanHistory(userId);
      
      // Load nutritional results for all scans
      _nutritionalResults = await _resultRepository.getUserScanResults(userId);
      
      _state = ScanState.success;
    } catch (e) {
      _error = 'Error cargando historial: ${e.toString()}';
      _state = ScanState.error;
    }

    notifyListeners();
  }

  /// Carga escaneos guardados
  Future<void> loadSavedScans(String userId) async {
    _state = ScanState.scanning;
    _error = '';
    notifyListeners();

    try {
      _savedScans = await _repository.getSavedScans(userId);
      _savedNutritionalResults = await _resultRepository.getSavedResults(userId);
      _state = ScanState.success;
    } catch (e) {
      _error = 'Error cargando escaneos guardados: ${e.toString()}';
      _state = ScanState.error;
    }

    notifyListeners();
  }

  /// Guarda un escaneo
  Future<void> saveScan(String scanId) async {
    try {
      await _repository.saveScan(scanId);
      
      // Actualizar en listas locales
      final scan = _scanHistory.firstWhere(
        (s) => s.id == scanId,
        orElse: () => _lastScan!,
      );
      
      if (!_savedScans.contains(scan)) {
        _savedScans.insert(0, scan);
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Error guardando escaneo: ${e.toString()}';
      _state = ScanState.error;
      notifyListeners();
    }
  }

  /// Elimina un escaneo
  Future<void> deleteScan(String scanId) async {
    try {
      await _repository.deleteScan(scanId);
      
      _scanHistory.removeWhere((s) => s.id == scanId);
      _savedScans.removeWhere((s) => s.id == scanId);
      
      if (_lastScan?.id == scanId) {
        _lastScan = null;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Error eliminando escaneo: ${e.toString()}';
      _state = ScanState.error;
      notifyListeners();
    }
  }

  /// Obtiene detalles de un escaneo
  Future<IngredientScanResult?> getScanDetails(String scanId) async {
    try {
      return await _repository.getScanById(scanId);
    } catch (e) {
      _error = 'Error obteniendo detalles: ${e.toString()}';
      return null;
    }
  }

  /// Limpia el estado
  void clearState() {
    _state = ScanState.idle;
    _error = '';
    _lastScan = null;
    notifyListeners();
  }

  /// Limpia errores
  void clearError() {
    _error = '';
    notifyListeners();
  }

  /// Calculate and store nutritional result for a scan
  Future<void> _calculateAndStoreNutritionalResult({
    required String userId,
    required String scanId,
    required List<String> ingredients,
    String? notes,
  }) async {
    try {
      final resultId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final nutritionalResult = await _nutritionService.calculateNutritionalResult(
        resultId: resultId,
        scanId: scanId,
        userId: userId,
        ingredients: ingredients,
        calculatedAt: DateTime.now(),
        notes: notes,
      );

      // Verify data consistency before storing
      if (!_nutritionService.verifyNutritionalConsistency(nutritionalResult)) {
        throw Exception('Nutritional data consistency check failed');
      }

      // Store in repository
      await _resultRepository.saveScanResult(nutritionalResult);
      
      _lastNutritionalResult = nutritionalResult;
      _nutritionalResults.insert(0, nutritionalResult);
    } catch (e) {
      // Log error but don't fail the scan
      print('Error storing nutritional result: $e');
    }
  }

  /// Get nutritional result for a specific scan
  Future<NutritionalResult?> getNutritionalResult(String scanId) async {
    try {
      final scan = _nutritionalResults.firstWhere(
        (r) => r.scanId == scanId,
        orElse: () => throw Exception('Result not found'),
      );
      return scan;
    } catch (e) {
      _error = 'Error obteniendo resultado nutricional: ${e.toString()}';
      return null;
    }
  }

  /// Toggle save status of nutritional result
  Future<void> toggleSaveNutritionalResult(String resultId) async {
    try {
      await _resultRepository.toggleSaveResult(resultId);
      
      // Update local lists
      final index = _nutritionalResults.indexWhere((r) => r.id == resultId);
      if (index != -1) {
        final result = _nutritionalResults[index];
        _nutritionalResults[index] = result.copyWith(isSaved: !result.isSaved);
        
        if (result.copyWith(isSaved: !result.isSaved).isSaved) {
          _savedNutritionalResults.insert(0, _nutritionalResults[index]);
        } else {
          _savedNutritionalResults.removeWhere((r) => r.id == resultId);
        }
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Error guardando resultado: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Get nutritional summary for user
  Future<Map<String, dynamic>> getNutritionalSummary(String userId) async {
    try {
      return await _resultRepository.calculateNutritionalSummary(userId);
    } catch (e) {
      _error = 'Error calculando resumen: ${e.toString()}';
      return {};
    }
  }

  /// Validate all stored nutritional results
  Future<List<String>> validateStoredResults(String userId) async {
    try {
      return await _resultRepository.validateStoredResults(userId);
    } catch (e) {
      _error = 'Error validando resultados: ${e.toString()}';
      return [];
    }
  }
}
