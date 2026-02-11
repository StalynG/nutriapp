import '../entities/nutritional_result.dart';

abstract class ScanResultRepository {
  /// Save a nutritional result from a scan
  Future<void> saveScanResult(NutritionalResult result);

  /// Get a specific scan result by ID
  Future<NutritionalResult?> getScanResult(String resultId);

  /// Get all scan results for a user
  Future<List<NutritionalResult>> getUserScanResults(String userId);

  /// Get saved/bookmarked scan results
  Future<List<NutritionalResult>> getSavedResults(String userId);

  /// Delete a scan result
  Future<void> deleteScanResult(String resultId);

  /// Toggle save status of a result
  Future<void> toggleSaveResult(String resultId);

  /// Get scan results within a date range
  Future<List<NutritionalResult>> getResultsInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Calculate total nutritional summary for user's results
  Future<Map<String, dynamic>> calculateNutritionalSummary(String userId);

  /// Verify that stored results are valid
  Future<List<String>> validateStoredResults(String userId);

  /// Clear old results (older than specified days)
  Future<void> clearOldResults(String userId, int daysToKeep);
}
