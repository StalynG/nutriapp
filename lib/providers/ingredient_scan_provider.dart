// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/entities/ingredient_scan.dart';
import '../domain/repositories/ingredient_scan_repository.dart';

enum ScanState { idle, scanning, success, error }

/// Provider que gestiona escaneos de ingredientes
class IngredientScanProvider extends ChangeNotifier {
  final IngredientScanRepository _repository;

  ScanState _state = ScanState.idle;
  String _error = '';
  IngredientScanResult? _lastScan;
  List<IngredientScanResult> _scanHistory = [];
  List<IngredientScanResult> _savedScans = [];

  IngredientScanProvider(this._repository);

  // Getters
  ScanState get state => _state;
  String get error => _error;
  IngredientScanResult? get lastScan => _lastScan;
  List<IngredientScanResult> get scanHistory => List.unmodifiable(_scanHistory);
  List<IngredientScanResult> get savedScans => List.unmodifiable(_savedScans);
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
}
