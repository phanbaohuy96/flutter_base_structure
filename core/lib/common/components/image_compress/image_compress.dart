import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart';

@injectable
class ImageCompressHelper {
  Future<(Uint8List, String)> compressWithList({
    required Uint8List image,
    CompressImageOption option = const CompressImageOption(),
  }) async {
    final receivePort = ReceivePort();
    final isolateToken = RootIsolateToken.instance!;

    // Spawn an isolate
    await Isolate.spawn(
      _compressIsolate,
      (receivePort.sendPort, image, option, isolateToken),
    );

    // Wait for the result from the isolate
    final result = await receivePort.first;
    if (result is (Uint8List, String)) {
      return result;
    }

    receivePort.close();

    throw result;
  }

  Future _compressIsolate(
    (
      SendPort sendPort,
      Uint8List image,
      CompressImageOption option,
      RootIsolateToken token,
    ) data,
  ) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(data.$4);
    final sendPort = data.$1;
    final image = data.$2;
    final option = data.$3;
    try {
      final imageSize = ImageCompressHelper().getImageDimensions(image)!;
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
        format: CompressFormat.jpeg,
      );

      // Send the result back to the main isolate
      sendPort.send((result, 'image/jpeg'));
    } catch (e) {
      sendPort.send(e);
    }
  }

  Size? getImageDimensions(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image != null) {
      return Size(image.width.toDouble(), image.height.toDouble());
    }
    return null;
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
}

enum ImageResolution {
  medium(480, 720),
  hd(720, 1280),
  fullHD(1080, 1920),
  ;

  const ImageResolution(this.width, this.height);

  final double width;
  final double height;
}

class CompressImageOption {
  final ImageResolution resolution;
  final int quality;

  const CompressImageOption({
    this.resolution = ImageResolution.hd,
    this.quality = 87,
  });
}
