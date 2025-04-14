part of 'image_cropper_screen.dart';

extension ImageCropperAction on _ImageCropperScreenState {
  void _close() {
    Navigator.of(context).pop(null);
  }

  Future<void> _cropImage() async {
    showLoading();
    final fileData = Uint8List.fromList(
      await cropImageDataWithNativeLibrary(
        editorKey.currentState!,
      ),
    );
    final imageFile = await _saveTempFile(fileData);
    hideLoading();
    Navigator.of(context).pop(imageFile);
  }

  Future<List<int>> cropImageDataWithNativeLibrary(
    ExtendedImageEditorState state,
  ) async {
    final cropRect = state.getCropRect();
    final action = state.editAction;

    final rotateAngle = action?.rotateAngle.toInt();
    final flipHorizontal = action?.flipY;
    final flipVertical = action?.flipX;
    final img = state.rawImageData;

    final option = ImageEditorOption();

    if (action!.needCrop) {
      option.addOption(ClipOption.fromRect(cropRect!));
    }

    if (action.needFlip) {
      option.addOption(
        FlipOption(horizontal: flipHorizontal!, vertical: flipVertical!),
      );
    }

    if (action.hasRotateAngle) {
      option.addOption(RotateOption(rotateAngle!));
    }

    final result = await ImageEditor.editImage(
      image: img,
      imageEditorOption: option,
    );

    return result!;
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
