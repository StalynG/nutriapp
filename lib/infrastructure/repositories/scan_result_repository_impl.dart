import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/nutritional_result.dart';
import '../../domain/repositories/scan_result_repository.dart';

class ScanResultRepositoryImpl implements ScanResultRepository {
  static const String _resultsKeyPrefix = 'nutritional_results_';
  static const String _savedResultsKey = 'saved_nutritional_results_';
  static const String _summaryKey = 'nutritional_summary_';

  final SharedPreferences _prefs;

  ScanResultRepositoryImpl(this._prefs);

  /// Generate storage key for user's results
  String _getUserResultsKey(String userId) => '$_resultsKeyPrefix$userId';

  /// Generate storage key for user's saved results
  String _getUserSavedKey(String userId) => '$_savedResultsKey$userId';

  /// Generate storage key for user's summary
  String _getUserSummaryKey(String userId) => '$_summaryKey$userId';

  @override
  Future<void> saveScanResult(NutritionalResult result) async {
    try {
      // Validate data before saving
      if (!result.validateNutritionalData()) {
        throw Exception('Invalid nutritional data: validation failed');
      }

      // Get existing results
      final key = _getUserResultsKey(result.userId);
      final existingJson = _prefs.getStringList(key) ?? [];

      // Add new result
      existingJson.add(jsonEncode(result.toJson()));

      // Save to SharedPreferences
      await _prefs.setStringList(key, existingJson);

      // Update summary
      await _updateSummary(result.userId);
    } catch (e) {
      throw Exception('Failed to save scan result: $e');
    }
  }

  @override
  Future<NutritionalResult?> getScanResult(String resultId) async {
    try {
      // Search through all stored results to find by ID
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_resultsKeyPrefix)) {
          final resultsList = _prefs.getStringList(key);
          if (resultsList != null) {
            for (final jsonStr in resultsList) {
              final result = NutritionalResult.fromJson(
                jsonDecode(jsonStr) as Map<String, dynamic>,
              );
              if (result.id == resultId) {
                return result;
              }
            }
          }
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get scan result: $e');
    }
  }

  @override
  Future<List<NutritionalResult>> getUserScanResults(String userId) async {
    try {
      final key = _getUserResultsKey(userId);
      final resultsList = _prefs.getStringList(key) ?? [];

      final results = resultsList
          .map((jsonStr) => NutritionalResult.fromJson(
                jsonDecode(jsonStr) as Map<String, dynamic>,
              ))
          .toList();

      // Sort by date (newest first)
      results.sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));

      return results;
    } catch (e) {
      throw Exception('Failed to get user scan results: $e');
    }
  }

  @override
  Future<List<NutritionalResult>> getSavedResults(String userId) async {
    try {
      final allResults = await getUserScanResults(userId);
      return allResults.where((result) => result.isSaved).toList();
    } catch (e) {
      throw Exception('Failed to get saved results: $e');
    }
  }

  @override
  Future<void> deleteScanResult(String resultId) async {
    try {
      final keys = _prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_resultsKeyPrefix)) {
          final resultsList = _prefs.getStringList(key);
          if (resultsList != null) {
            // Filter out the result to delete
            final updatedList = resultsList
                .where((jsonStr) {
                  final result = NutritionalResult.fromJson(
                    jsonDecode(jsonStr) as Map<String, dynamic>,
                  );
                  return result.id != resultId;
                })
                .toList();

            if (updatedList.length != resultsList.length) {
              // Result was found and deleted
              if (updatedList.isEmpty) {
                await _prefs.remove(key);
              } else {
                await _prefs.setStringList(key, updatedList);
              }

              // Extract userId from key and update summary
              final userId = key.replaceFirst(_resultsKeyPrefix, '');
              await _updateSummary(userId);
              return;
            }
          }
        }
      }

      throw Exception('Result not found: $resultId');
    } catch (e) {
      throw Exception('Failed to delete scan result: $e');
    }
  }

  @override
  Future<void> toggleSaveResult(String resultId) async {
    try {
      final result = await getScanResult(resultId);
      if (result == null) {
        throw Exception('Result not found: $resultId');
      }

      // Delete old result
      await deleteScanResult(resultId);

      // Save updated result with toggled isSaved status
      final updatedResult = result.copyWith(isSaved: !result.isSaved);
      await saveScanResult(updatedResult);
    } catch (e) {
      throw Exception('Failed to toggle save result: $e');
    }
  }

  @override
  Future<List<NutritionalResult>> getResultsInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allResults = await getUserScanResults(userId);
      return allResults
          .where((result) =>
              result.calculatedAt.isAfter(startDate) &&
              result.calculatedAt.isBefore(endDate))
          .toList();
    } catch (e) {
      throw Exception('Failed to get results in date range: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> calculateNutritionalSummary(
    String userId,
  ) async {
    try {
      final results = await getUserScanResults(userId);

      if (results.isEmpty) {
        return {
          'totalScans': 0,
          'totalCalories': 0.0,
          'totalProtein': 0.0,
          'totalFat': 0.0,
          'totalCarbs': 0.0,
          'totalFiber': 0.0,
          'averageCalories': 0.0,
          'averageProtein': 0.0,
          'averageFat': 0.0,
          'averageCarbs': 0.0,
          'averageFiber': 0.0,
        };
      }

      double totalCalories = 0.0;
      double totalProtein = 0.0;
      double totalFat = 0.0;
      double totalCarbs = 0.0;
      double totalFiber = 0.0;

      for (final result in results) {
        totalCalories += result.totalCalories;
        totalProtein += result.proteinGrams;
        totalFat += result.fatGrams;
        totalCarbs += result.carbsGrams;
        totalFiber += result.fiberGrams;
      }

      final count = results.length.toDouble();

      return {
        'totalScans': results.length,
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalFat': totalFat,
        'totalCarbs': totalCarbs,
        'totalFiber': totalFiber,
        'averageCalories': totalCalories / count,
        'averageProtein': totalProtein / count,
        'averageFat': totalFat / count,
        'averageCarbs': totalCarbs / count,
        'averageFiber': totalFiber / count,
      };
    } catch (e) {
      throw Exception('Failed to calculate summary: $e');
    }
  }

  @override
  Future<List<String>> validateStoredResults(String userId) async {
    try {
      final results = await getUserScanResults(userId);
      final invalidIds = <String>[];

      for (final result in results) {
        if (!result.validateNutritionalData()) {
          invalidIds.add(result.id);
        }
      }

      return invalidIds;
    } catch (e) {
      throw Exception('Failed to validate stored results: $e');
    }
  }

  @override
  Future<void> clearOldResults(String userId, int daysToKeep) async {
    try {
      final key = _getUserResultsKey(userId);
      final resultsList = _prefs.getStringList(key) ?? [];

      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      final filteredList = resultsList
          .where((jsonStr) {
            final result = NutritionalResult.fromJson(
              jsonDecode(jsonStr) as Map<String, dynamic>,
            );
            return result.calculatedAt.isAfter(cutoffDate);
          })
          .toList();

      if (filteredList.isEmpty) {
        await _prefs.remove(key);
      } else {
        await _prefs.setStringList(key, filteredList);
      }

      // Update summary
      await _updateSummary(userId);
    } catch (e) {
      throw Exception('Failed to clear old results: $e');
    }
  }

  /// Update user's nutritional summary
  Future<void> _updateSummary(String userId) async {
    try {
      final summary = await calculateNutritionalSummary(userId);
      final key = _getUserSummaryKey(userId);
      await _prefs.setString(key, jsonEncode(summary));
    } catch (e) {
      // Log but don't throw - summary update failure shouldn't break operations
      print('Failed to update summary: $e');
    }
  }
}
