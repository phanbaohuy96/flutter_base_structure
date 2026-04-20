import 'dart:io'
    if (dart.library.html) 'package:extended_image_library/src/_platform_web.dart'
    if (dart.library.js_interop) 'package:extended_image_library/src/_platform_web.dart';

import 'package:extended_image/extended_image.dart';
import 'package:fl_ui/fl_ui.dart';
import 'package:fl_utils/fl_utils.dart';
import 'package:flutter/material.dart';

class ImageZoom extends StatefulWidget {
  final String url;

  const ImageZoom({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<ImageZoom> createState() => _ImageZoomState();
}

typedef DoubleClickAnimationListener = void Function();

class _ImageZoomState extends State<ImageZoom> with TickerProviderStateMixin {
  late final animationController = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );

  Animation? animation;

  Function() animationListener = () {};

  @override
  Widget build(BuildContext context) {
    if (widget.url.contains('http')) {
      return _buildNetworkImage(
        widget.url,
      );
    } else if (widget.url.isLocalUrl) {
      return _buildImageFile(
        widget.url,
      );
    } else {
      return _buildAssetImage(
        widget.url,
      );
    }
  }

  Widget? loadStateChanged(ExtendedImageState state) {
    if (state.extendedImageLoadState == LoadState.loading) {
      return const Loading();
    }
    return null;
  }

  GestureConfig initGestureConfigHandler(ExtendedImageState state) {
    return GestureConfig(
      minScale: 0.9,
      animationMinScale: 0.7,
      maxScale: 4.0,
      animationMaxScale: 4.5,
      speed: 1.0,
      inertialSpeed: 100.0,
      initialScale: 1.0,
      inPageView: false,
      initialAlignment: InitialAlignment.center,
      reverseMousePointerScrollDirection: true,
      gestureDetailsIsChanged: (GestureDetails? details) {
        //log(details?.totalScale);
      },
    );
  }

  void onDoubleTap(ExtendedImageGestureState state) {
    ///you can use define pointerDownPosition as you can,
    ///default value is double tap pointer down postion.
    final pointerDownPosition = state.pointerDownPosition;
    final begin = state.gestureDetails!.totalScale!;
    double end;

    animation?.removeListener(animationListener);
    animationController
      ..stop()
      ..reset();

    if (begin == 1) {
      end = 3.0;
    } else {
      end = 1;
    }
    animationListener = () {
      state.handleDoubleTap(
        scale: animation!.value,
        doubleTapPosition: pointerDownPosition,
      );
    };
    animation = animationController.drive(
      Tween<double>(begin: begin, end: end),
    );

    animation!.addListener(animationListener);

    animationController.forward();
  }

  Widget _buildNetworkImage(String url) {
    return ExtendedImage.network(
      url,
      enableSlideOutPage: true,
      mode: ExtendedImageMode.gesture,
      fit: BoxFit.fitWidth,
      cacheWidth: 1080,
      extendedImageGestureKey: GlobalKey<ExtendedImageGestureState>(),
      loadStateChanged: loadStateChanged,
      initGestureConfigHandler: initGestureConfigHandler,
      onDoubleTap: onDoubleTap,
    );
  }

  Widget _buildImageFile(String url) {
    return ExtendedImage.file(
      File(widget.url),
      enableSlideOutPage: true,
      mode: ExtendedImageMode.gesture,
      fit: BoxFit.fitWidth,
      cacheWidth: 1080,
      extendedImageGestureKey: GlobalKey<ExtendedImageGestureState>(),
      loadStateChanged: loadStateChanged,
      initGestureConfigHandler: initGestureConfigHandler,
      onDoubleTap: onDoubleTap,
    );
  }

  Widget _buildAssetImage(String url) {
    return ExtendedImage.asset(
      widget.url,
      enableSlideOutPage: true,
      mode: ExtendedImageMode.gesture,
      fit: BoxFit.fitWidth,
      cacheWidth: 1080,
      extendedImageGestureKey: GlobalKey<ExtendedImageGestureState>(),
      loadStateChanged: loadStateChanged,
      initGestureConfigHandler: initGestureConfigHandler,
      onDoubleTap: onDoubleTap,
    );
  }
}
