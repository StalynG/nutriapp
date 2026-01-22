import 'dart:typed_data';

/// Servicio de procesamiento de imágenes.
/// Capa intermedia de transformación visual.
class ImageProcessingService {
  ImageProcessingService();

  /// Aplica un filtro de escala de grises sobre una imagen.
  Future<Uint8List> applyGrayScale(Uint8List imageBytes) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return imageBytes;
  }

  /// Aplica un suavizado básico (blur).
  Future<Uint8List> applyBlur(Uint8List imageBytes) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return imageBytes;
  }

  /// Realiza detección de bordes.
  Future<Uint8List> detectEdges(Uint8List imageBytes) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return imageBytes;
  }
}

/// Tipos de filtros soportados por el servicio de procesamiento.
enum ImageFilterType { grayscale, blur, edgeDetection }

/// Pipeline de procesamiento encadenado.
class ImageProcessingPipeline {
  final ImageProcessingService _service = ImageProcessingService();

  Future<Uint8List> process(
    Uint8List imageBytes,
    List<ImageFilterType> filters,
  ) async {
    Uint8List result = imageBytes;

    for (final filter in filters) {
      switch (filter) {
        case ImageFilterType.grayscale:
          result = await _service.applyGrayScale(result);
          break;
        case ImageFilterType.blur:
          result = await _service.applyBlur(result);
          break;
        case ImageFilterType.edgeDetection:
          result = await _service.detectEdges(result);
          break;
      }
    }

    return result;
  }
}
