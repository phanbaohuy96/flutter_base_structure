import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WidgetToImageController {
  final containerKey = GlobalKey();
  final constraintsKey = GlobalKey();

  /// to capture widget to image by GlobalKey in RenderRepaintBoundary
  Future<Uint8List?> capture({
    double pixelRatio = 6,
    bool exportByConstraints = false,
  }) async {
    try {
      final key = exportByConstraints ? constraintsKey : containerKey;

      /// boundary widget by GlobalKey
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      /// convert boundary to image
      final image = await boundary!.toImage(pixelRatio: pixelRatio);

      /// set ImageByteFormat
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      rethrow;
    }
  }
}

class WidgetToImage extends StatelessWidget {
  final Widget? child;
  final WidgetToImageController controller;
  final BoxConstraints? exportConstraints;
  final bool fittedInConstrainedBox;

  const WidgetToImage({
    Key? key,
    required this.child,
    required this.controller,
    this.exportConstraints,
    this.fittedInConstrainedBox = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (exportConstraints != null) {
      return Stack(
        children: [
          RepaintBoundary(key: controller.containerKey, child: child),
          RepaintBoundary(
            key: controller.constraintsKey,
            child: ConstrainedBox(
              constraints: exportConstraints!,
              child: FittedBox(
                fit: fittedInConstrainedBox ? BoxFit.cover : BoxFit.none,
                child: child,
              ),
            ),
          ),
        ],
      );
    }
    return RepaintBoundary(key: controller.containerKey, child: child);
  }
}
