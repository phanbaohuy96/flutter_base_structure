import 'dart:io';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:fl_ui/fl_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_editor/image_editor.dart';
import 'package:path_provider/path_provider.dart';

import '../../l10n/localization_ext.dart';

part 'image_cropper.action.dart';

class ImageCropperScreen extends StatefulWidget {
  static String routeName = '/image_cropper';

  const ImageCropperScreen({
    Key? key,
    required this.imagefile,
  }) : super(key: key);

  final File imagefile;
  @override
  _ImageCropperScreenState createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends State<ImageCropperScreen> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();

  late FlMeidaLocalizations localization;
  var _isLoadingShowing = false;
  void showLoading({bool dismissOnTap = false}) {
    if (!_isLoadingShowing) {
      _isLoadingShowing = true;
      EasyLoading.show(
        status: localization.loading,
        indicator: const Loading(),
        dismissOnTap: dismissOnTap,
      );
    }
  }

  void hideLoading() {
    if (_isLoadingShowing) {
      _isLoadingShowing = false;
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    localization = context.flMediaL10n;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _close();
        }
      },
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Builder(
          builder: (_) {
            final textTheme = Theme.of(context).textTheme;
            return Stack(
              children: [
                ExtendedImage.file(
                  widget.imagefile,
                  cacheRawData: true,
                  fit: BoxFit.contain,
                  mode: ExtendedImageMode.editor,
                  enableLoadState: true,
                  loadStateChanged: (state) {
                    if (state.extendedImageLoadState == LoadState.loading) {
                      return const Center(child: Loading());
                    } else {
                      return state.completedWidget;
                    }
                  },
                  extendedImageEditorKey: editorKey,
                  initEditorConfigHandler: (ExtendedImageState? state) {
                    return EditorConfig(
                      maxScale: 8.0,
                      cropRectPadding: const EdgeInsets.all(20.0),
                      hitTestSize: 20.0,
                      cropLayerPainter: const CustomEditorCropLayerPainter(),
                      initCropRectType: InitCropRectType.imageRect,
                      cropAspectRatio: CropAspectRatios.ratio1_1,
                    );
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.only(
                      right: 16,
                      left: 16,
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                    color: Colors.white12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _close,
                          child: Text(
                            localization.cancel,
                            style: textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _cropImage,
                          child: Text(
                            localization.confirm,
                            style: textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CustomEditorCropLayerPainter extends EditorCropLayerPainter {
  const CustomEditorCropLayerPainter();

  @override
  void paintMask(
    Canvas canvas,
    Size size,
    ExtendedImageCropLayerPainter painter,
  ) {
    final rect = Offset.zero & size;
    final cropRect = painter.cropRect;
    const maskColor = Colors.black12;

    canvas
      ..drawRect(
        Offset.zero & Size(cropRect.left, rect.height),
        Paint()
          ..style = PaintingStyle.fill
          ..color = maskColor,
      )
      ..drawRect(
        Offset(cropRect.left, 0.0) & Size(cropRect.width, cropRect.top),
        Paint()
          ..style = PaintingStyle.fill
          ..color = maskColor,
      )
      ..drawRect(
        Offset(cropRect.right, 0.0) &
            Size(rect.width - cropRect.right, rect.height),
        Paint()
          ..style = PaintingStyle.fill
          ..color = maskColor,
      )
      ..drawRect(
        Offset(cropRect.left, cropRect.bottom) &
            Size(cropRect.width, rect.height - cropRect.bottom),
        Paint()
          ..style = PaintingStyle.fill
          ..color = maskColor,
      );
  }
}
