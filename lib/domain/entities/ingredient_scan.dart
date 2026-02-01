// ignore_for_file: public_member_api_docs

import 'dart:io';

import '../entities/user.dart';

/// Entidad que representa un resultado de escaneo de ingredientes
class IngredientScanResult {
  final String id;
  final String userId;
  final List<String> ingredients;
  final double confidenceScore;
  final String? description;
  final DateTime scannedAt;
  final String? imageUrl;

  IngredientScanResult({
    required this.id,
    required this.userId,
    required this.ingredients,
    required this.confidenceScore,
    this.description,
    required this.scannedAt,
    this.imageUrl,
  });

  factory IngredientScanResult.fromJson(Map<String, dynamic> json) {
    return IngredientScanResult(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      ingredients: List<String>.from(json['ingredients'] as List? ?? []),
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      scannedAt: json['scanned_at'] != null
          ? DateTime.parse(json['scanned_at'] as String)
          : DateTime.now(),
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'ingredients': ingredients,
    'confidence_score': confidenceScore,
    'description': description,
    'scanned_at': scannedAt.toIso8601String(),
    'image_url': imageUrl,
  };
}

/// Solicitud de escaneo de ingredientes
class IngredientScanRequest {
  final File imageFile;
  final String? userId;
  final String? description;

  IngredientScanRequest({
    required this.imageFile,
    this.userId,
    this.description,
  });
}
