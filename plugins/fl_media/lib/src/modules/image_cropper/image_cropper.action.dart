part of 'image_cropper_screen.dart';

extension on _ImageCropperScreenState {
  void _close() {
    Navigator.of(context).pop(null);
  }

  Future<void> _cropImage() async {
    showLoading();
    final fileData = await cropImageDataWithNativeLibrary(
      _editorController,
    );
    if (fileData == null) {
      return;
    }
    final imageFile = await _saveTempFile(fileData);
    hideLoading();
    Navigator.of(context).pop(imageFile);
  }

  Future<Uint8List?> cropImageDataWithNativeLibrary(
    ImageEditorController imageEditorController,
  ) async {
    final action = imageEditorController.editActionDetails!;

    final img = imageEditorController.state!.rawImageData;

    final option = ImageEditorOption();

    if (action.hasRotateDegrees) {
      final rotateDegrees = action.rotateDegrees.toInt();
      option.addOption(RotateOption(rotateDegrees));
    }
    if (action.flipY) {
      option.addOption(const FlipOption(horizontal: true, vertical: false));
    }

    if (action.needCrop) {
      var cropRect = imageEditorController.getCropRect()!;
      if (imageEditorController.state!.widget.extendedImageState.imageProvider
          is ExtendedResizeImage) {
        final buffer = await ImmutableBuffer.fromUint8List(img);
        final descriptor = await ImageDescriptor.encoded(buffer);

        final widthRatio =
            descriptor.width / imageEditorController.state!.image!.width;
        final heightRatio =
            descriptor.height / imageEditorController.state!.image!.height;
        cropRect = Rect.fromLTRB(
          cropRect.left * widthRatio,
          cropRect.top * heightRatio,
          cropRect.right * widthRatio,
          cropRect.bottom * heightRatio,
        );
      }
      option.addOption(ClipOption.fromRect(cropRect));
    }

    final result = await ImageEditor.editImage(
      image: img,
      imageEditorOption: option,
    );

    return result;
  }

  Future<File> _saveTempFile(Uint8List data) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${UniqueKey()}.png';
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
    return file.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }
}
