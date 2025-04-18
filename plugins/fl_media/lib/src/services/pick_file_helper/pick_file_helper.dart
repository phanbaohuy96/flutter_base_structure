import 'package:file_picker/file_picker.dart' as f_picker;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

export 'package:image_picker/image_picker.dart' show CameraDevice;

part 'picked_file.dart';

enum FileType {
  any,
  media,
  image,
  video,
  audio,
  custom,
}

extension _FileTypeExt on FileType {
  f_picker.FileType get filePickerType {
    switch (this) {
      case FileType.any:
        return f_picker.FileType.any;
      case FileType.media:
        return f_picker.FileType.media;
      case FileType.image:
        return f_picker.FileType.image;
      case FileType.video:
        return f_picker.FileType.video;
      case FileType.audio:
        return f_picker.FileType.audio;
      case FileType.custom:
        return f_picker.FileType.custom;
    }
  }
}

class PickFileHelper {
  Future<List<FilePicked>> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
  }) async {
    if (kIsWeb) {
      /// This helper class addresses a limitation with the `file_picker`
      /// package, which currently does not support web platforms.
      /// As a temporary workaround, the [ImagePicker] package is used for
      /// file picking functionality on the web.
      ///
      /// For more details, refer to the related issue on GitHub:
      /// https://github.com/miguelpruivo/flutter_file_picker/issues/876
      final picker = ImagePicker();
      final result = await picker.pickImage(
        source: ImageSource.gallery,
      );

      return [
        if (result != null) await FilePicked.fromXFile(result),
      ];
    }

    final result = await f_picker.FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      initialDirectory: initialDirectory,
      type: type.filePickerType,
      allowedExtensions: allowedExtensions,
      compressionQuality: compressionQuality,
      allowMultiple: allowMultiple,
      withData: withData,
      withReadStream: withReadStream,
      lockParentWindow: lockParentWindow,
    );

    return [...?result?.files.map(FilePicked.fromPlatFormFile)];
  }

  Future<FilePicked?> takePicture([
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  ]) async {
    final picker = ImagePicker();
    final result = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: preferredCameraDevice,
    );

    return result != null ? FilePicked.fromXFile(result) : null;
  }
}
