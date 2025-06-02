import 'dart:io';

import 'package:file_picker/file_picker.dart' as f_picker;
import 'package:fl_utils/fl_utils.dart';
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
    bool? withData,
    bool withReadStream = false,
    bool lockParentWindow = false,
  }) async {
    final result = await f_picker.FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      initialDirectory: initialDirectory,
      type: type.filePickerType,
      allowedExtensions: allowedExtensions,
      compressionQuality: compressionQuality,
      allowMultiple: allowMultiple,
      withData: withData ?? kIsWeb,
      withReadStream: withReadStream,
      lockParentWindow: lockParentWindow,
    );

    return [...?result?.files.map(FilePicked.fromPlatFormFile)];
  }

  Future<FilePicked?> takePicture([
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  ]) async {
    /// Do a cheat for [Platform.isIOS] on [kDebugMode]
    ///
    /// There are no camera service available.
    if (kDebugMode && !kIsWeb && Platform.isIOS) {
      return PickFileHelper()
          .pickFiles(
            allowMultiple: false,
            type: FileType.image,
          )
          .then(
            (value) => CoreListExtension(value).firstOrNull,
          );
    }

    final picker = ImagePicker();
    final result = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: preferredCameraDevice,
    );

    return result != null ? FilePicked.fromXFile(result) : null;
  }
}
