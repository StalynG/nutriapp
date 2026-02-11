import 'package:json_annotation/json_annotation.dart';

part 'nutritional_result.g.dart';

/// Represents the nutritional analysis of a scanned ingredient/meal
@JsonSerializable()
class NutritionalResult {
  /// Unique identifier for the result
  final String id;

  /// Scan ID this result belongs to
  final String scanId;

  /// User ID who performed the scan
  final String userId;

  /// List of detected ingredients
  final List<String> ingredients;

  /// Total calories (kcal)
  final double totalCalories;

  /// Protein in grams
  final double proteinGrams;

  /// Fat in grams
  final double fatGrams;

  /// Carbohydrates in grams
  final double carbsGrams;

  /// Dietary fiber in grams
  final double fiberGrams;

  /// Breakdown of calories per macronutrient
  /// Keys: 'protein', 'fat', 'carbs'
  final Map<String, double> calorieBreakdown;

  /// Macronutrient percentages
  /// Keys: 'protein', 'fat', 'carbs'
  final Map<String, double> macroPercentages;

  /// Timestamp of when the result was calculated
  final DateTime calculatedAt;

  /// Optional notes about the meal/ingredients
  final String? notes;

  /// Whether the result has been saved/bookmarked
  final bool isSaved;

  NutritionalResult({
    required this.id,
    required this.scanId,
    required this.userId,
    required this.ingredients,
    required this.totalCalories,
    required this.proteinGrams,
    required this.fatGrams,
    required this.carbsGrams,
    required this.fiberGrams,
    required this.calorieBreakdown,
    required this.macroPercentages,
    required this.calculatedAt,
    this.notes,
    this.isSaved = false,
  });

  /// Get formated string for total calories
  String get formattedCalories => '${totalCalories.toStringAsFixed(0)} kcal';

  /// Get formated string for protein
  String get formattedProtein => '${proteinGrams.toStringAsFixed(1)}g';

  /// Get formated string for fat
  String get formattedFat => '${fatGrams.toStringAsFixed(1)}g';

  /// Get formated string for carbs
  String get formattedCarbs => '${carbsGrams.toStringAsFixed(1)}g';

  /// Get formated string for fiber
  String get formattedFiber => '${fiberGrams.toStringAsFixed(1)}g';

  /// Verify that nutritional values are within acceptable ranges
  bool validateNutritionalData() {
    // Calories should be between 0 and reasonable maximum (8000 kcal)
    if (totalCalories < 0 || totalCalories > 8000) return false;

    // Macronutrients should be non-negative
    if (proteinGrams < 0 ||
        fatGrams < 0 ||
        carbsGrams < 0 ||
        fiberGrams < 0) {
      return false;
    }

    // Total weight of macronutrients should make sense
    // Protein and carbs have 4 cal/g, fat has 9 cal/g
    final calculatedCalories =
        (proteinGrams * 4) + (carbsGrams * 4) + (fatGrams * 9);

    // Allow 5% tolerance for rounding errors
    final tolerance = totalCalories * 0.05;
    if ((calculatedCalories - totalCalories).abs() > tolerance) {
      return false;
    }

    // Macronutrient percentages should sum to approximately 100
    final totalPercentage = macroPercentages.values.fold<double>(
      0,
      (sum, val) => sum + val,
    );

    if ((totalPercentage - 100).abs() > 1.0) {
      return false;
    }

    return true;
  }

  /// Create a copy with modified fields
  NutritionalResult copyWith({
    String? id,
    String? scanId,
    String? userId,
    List<String>? ingredients,
    double? totalCalories,
    double? proteinGrams,
    double? fatGrams,
    double? carbsGrams,
    double? fiberGrams,
    Map<String, double>? calorieBreakdown,
    Map<String, double>? macroPercentages,
    DateTime? calculatedAt,
    String? notes,
    bool? isSaved,
  }) {
    return NutritionalResult(
      id: id ?? this.id,
      scanId: scanId ?? this.scanId,
      userId: userId ?? this.userId,
      ingredients: ingredients ?? this.ingredients,
      totalCalories: totalCalories ?? this.totalCalories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fiberGrams: fiberGrams ?? this.fiberGrams,
      calorieBreakdown: calorieBreakdown ?? this.calorieBreakdown,
      macroPercentages: macroPercentages ?? this.macroPercentages,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      notes: notes ?? this.notes,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  factory NutritionalResult.fromJson(Map<String, dynamic> json) =>
      _$NutritionalResultFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionalResultToJson(this);
}
