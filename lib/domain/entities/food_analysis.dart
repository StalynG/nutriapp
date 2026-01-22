// ignore_for_file: public_member_api_docs

import 'dart:convert';

class FoodAnalysis {
  final String descripcionPlato;
  final int caloriasTotales;
  final double proteinasTotalesG;
  final double grasasTotalesG;
  final double carbsTotalesG;
  final List<String> ingredientes;

  FoodAnalysis({
    required this.descripcionPlato,
    required this.caloriasTotales,
    required this.proteinasTotalesG,
    required this.grasasTotalesG,
    required this.carbsTotalesG,
    required this.ingredientes,
  });

  factory FoodAnalysis.fromJson(Map<String, dynamic>? json) {
    json ??= <String, dynamic>{};

    String descripcion = '';
    if (json['descripcion_plato'] != null) {
      descripcion = json['descripcion_plato'].toString();
    }

    int calorias = 0;
    if (json['calorias_totales'] != null) {
      final val = json['calorias_totales'];
      if (val is int) {
        calorias = val;
      } else {
        calorias = int.tryParse(val.toString()) ?? 0;
      }
    }

    double proteinas = 0.0;
    if (json['proteinas_totales_g'] != null) {
      proteinas =
          double.tryParse(json['proteinas_totales_g'].toString()) ?? 0.0;
    }

    double grasas = 0.0;
    if (json['grasas_totales_g'] != null) {
      grasas = double.tryParse(json['grasas_totales_g'].toString()) ?? 0.0;
    }

    double carbs = 0.0;
    if (json['carbs_totales_g'] != null) {
      carbs = double.tryParse(json['carbs_totales_g'].toString()) ?? 0.0;
    }

    List<String> ingredientes = [];
    if (json['ingredientes'] != null) {
      final raw = json['ingredientes'];
      if (raw is List) {
        ingredientes = raw.map((e) => e.toString()).toList();
      } else if (raw is String) {
        try {
          final parsed = jsonDecode(raw);
          if (parsed is List) {
            ingredientes = parsed.map((e) => e.toString()).toList();
          }
        } catch (_) {
          // ignore, fallback to single string
          ingredientes = [raw];
        }
      }
    }

    return FoodAnalysis(
      descripcionPlato: descripcion,
      caloriasTotales: calorias,
      proteinasTotalesG: proteinas,
      grasasTotalesG: grasas,
      carbsTotalesG: carbs,
      ingredientes: ingredientes,
    );
  }

  Map<String, dynamic> toJson() => {
    'descripcion_plato': descripcionPlato,
    'calorias_totales': caloriasTotales,
    'proteinas_totales_g': proteinasTotalesG,
    'grasas_totales_g': grasasTotalesG,
    'carbs_totales_g': carbsTotalesG,
    'ingredientes': ingredientes,
  };
}
//////////////////////