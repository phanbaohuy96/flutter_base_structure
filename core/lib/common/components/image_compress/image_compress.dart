import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart';
import 'package:mime/mime.dart';

/// Data class to pass compression parameters to isolate
class _CompressParams {
  final Uint8List image;
  final int quality;
  final double resolutionWidth;
  final double resolutionHeight;
  final CompressFormat format;

  const _CompressParams({
    required this.image,
    required this.quality,
    required this.resolutionWidth,
    required this.resolutionHeight,
    required this.format,
  });
}

typedef CompressResult = ({Uint8List image, String? mimeType});

Future<CompressResult> _compressInIsolate(_CompressParams params) async {
  final imageSize = _getImageDimensions(params.image);
  if (imageSize == null) {
    throw Exception('Failed to decode image dimensions');
  }

  final isPortrait = imageSize.width < imageSize.height;
  final minWidth = isPortrait
      ? params.resolutionWidth
      : params.resolutionHeight;
  final minHeight = isPortrait
      ? params.resolutionHeight
      : params.resolutionWidth;

  final scaleW = imageSize.width / minWidth;
  final scaleH = imageSize.height / minHeight;
  final scale = math.max(1.0, math.min(scaleW, scaleH));

  final result = await FlutterImageCompress.compressWithList(
    params.image,
    minHeight: imageSize.height ~/ scale,
    minWidth: imageSize.width ~/ scale,
    quality: params.quality,
    format: params.format,
  );

  return (image: result, mimeType: params.format.mimeType);
}

Size? _getImageDimensions(Uint8List imageBytes) {
  final image = img.decodeImage(imageBytes);
  if (image != null) {
    return Size(image.width.toDouble(), image.height.toDouble());
  }
  return null;
}

@injectable
class ImageCompressHelper {
  // Threshold for using isolate: 2MB
  static const int _isolateThresholdBytes = 2 * 1024 * 1024;

  Future<CompressResult> compressWithList({
    required Uint8List image,
    CompressImageOption option = const CompressImageOption(),
  }) async {
    // Web doesn't support isolates
    if (kIsWeb) {
      return _compress(image: image, option: option);
    }

    // Small images (< 2MB): run on main thread (faster, no overhead)
    // Large images (>= 2MB): use isolate (prevents UI freeze)
    if (image.lengthInBytes < _isolateThresholdBytes) {
      return _compress(image: image, option: option);
    }

    // Use isolate for large images to avoid blocking UI
    try {
      return await compute(
        _compressInIsolate,
        _CompressParams(
          image: image,
          quality: option.quality,
          resolutionWidth: option.resolution.width,
          resolutionHeight: option.resolution.height,
          format: option.format,
        ),
      );
    } catch (e) {
      // Fallback to main thread if isolate fails
      return _compress(image: image, option: option);
    }
  }

  Future<CompressResult> _compress({
    required Uint8List image,
    CompressImageOption option = const CompressImageOption(),
  }) async {
    final imageSize = getImageDimensions(image);
    if (imageSize == null) {
      final result = await FlutterImageCompress.compressWithList(
        image,
        minHeight: 720,
        minWidth: 720,
        quality: 90,
        format: option.format,
      );

      return (image: result, mimeType: option.format.mimeType);
    }

    final isPortrait = imageSize.width < imageSize.height;
    final resolution = option.resolution;
    final quality = option.quality;

    final scale = _calcScale(
      srcWidth: imageSize.width,
      srcHeight: imageSize.height,
      minWidth: isPortrait ? resolution.width : resolution.height,
      minHeight: isPortrait ? resolution.height : resolution.width,
    );

    final result = await FlutterImageCompress.compressWithList(
      image,
      minHeight: imageSize.height ~/ scale,
      minWidth: imageSize.width ~/ scale,
      quality: quality,
      format: option.format,
    );

    return (image: result, mimeType: option.format.mimeType);
  }

  Size? getImageDimensions(Uint8List imageBytes) {
    return _getImageDimensions(imageBytes);
  }

  double _calcScale({
    required double srcWidth,
    required double srcHeight,
    required double minWidth,
    required double minHeight,
  }) {
    final scaleW = srcWidth / minWidth;
    final scaleH = srcHeight / minHeight;
    final scale = math.max(1.0, math.min(scaleW, scaleH));
    return scale;
  }

  Future<CompressResult> compressFileIfImage(
    Uint8List bytes, {
    String? filePath,
    String? mimeType,
    CompressImageOption option = const CompressImageOption(),
  }) async {
    final mimeStr = mimeType ?? lookupMimeType(filePath ?? '');
    if (mimeStr?.startsWith('image/') == true) {
      try {
        return compressWithList(image: bytes, option: option);
      } catch (_) {
        return (image: bytes, mimeType: mimeStr);
      }
    } else {
      return (image: bytes, mimeType: mimeStr);
    }
  }
}

enum ImageResolution {
  medium(480, 720),
  hd(720, 1280),
  fullHD(1080, 1920);

  const ImageResolution(this.width, this.height);

  final double width;
  final double height;
}

class CompressImageOption {
  final ImageResolution resolution;
  final int quality;
  final CompressFormat format;

  const CompressImageOption({
    this.resolution = ImageResolution.hd,
    this.quality = 87,
    this.format = CompressFormat.webp,
  });
}

extension CompressFormatExtension on CompressFormat {
  String get mimeType {
    switch (this) {
      case CompressFormat.jpeg:
        return 'image/jpeg';
      case CompressFormat.png:
        return 'image/png';
      case CompressFormat.webp:
        return 'image/webp';
      case CompressFormat.heic:
        return 'image/heic';
    }
  }
}
