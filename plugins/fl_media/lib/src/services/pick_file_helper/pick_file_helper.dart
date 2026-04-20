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
  /// Maximum elapsed time (in milliseconds) for an exception to be considered
  /// a platform-version limitation (e.g. iOS < 14 not supporting PHPicker).
  ///
  /// If a picker method throws within this window it is almost certainly an
  /// "unsupported" error rather than a user-interaction failure, so we
  /// fall back to a compatible alternative.
  static const int _versionErrorThresholdMs = 500;

  /// Picks media files (images, videos, or both) using [ImagePicker].
  ///
  /// Some [ImagePicker] methods require iOS 14+ (e.g. [pickMultipleMedia],
  /// [pickMedia], [pickMultiImage], [pickMultiVideo]).
  /// On older iOS versions (the app supports iOS 13+), these methods throw
  /// [UnimplementedError] or [PlatformException]. When that happens, we fall
  /// back to compatible single-pick methods ([pickImage] / [pickVideo]) or
  /// to [file_picker] for multi-selection.
  Future<List<FilePicked>> pickMedia({
    FileType type = FileType.media,
    bool allowMultiple = false,
    int? limit,
  }) async {
    /// Picks media files (images/videos) from the device.
    ///
    /// Attempts to use the native ImagePicker API for a better user experience.
    /// Falls back to file_picker for devices running iOS versions below 14.
    ///
    /// Returns a [Future] that resolves to a list of [FilePicked] objects
    /// representing the selected media files.
    ///
    /// Throws an exception if the media selection is cancelled or fails.
    if (type == FileType.media) {
      final picker = ImagePicker();
      final stopwatch = Stopwatch()..start();
      try {
        final result = allowMultiple
            ? await picker.pickMultipleMedia(
                limit: limit,
              )
            : await picker.pickMedia().then<List<XFile>>(
                (file) => file != null ? [file] : [],
              );

        stopwatch.stop();
        return Future.wait([...result.map(FilePicked.fromXFile)]);
      } catch (e) {
        stopwatch.stop();
        // Only fallback when the error fires almost instantly, which
        // indicates a platform-version limitation (iOS < 14).
        if (stopwatch.elapsedMilliseconds > _versionErrorThresholdMs) {
          rethrow;
        }

        // Fallback: pickMultipleMedia / pickMedia require iOS 14+.
        // Use file_picker for broad compatibility.
        return pickFiles(
          allowMultiple: allowMultiple,
          type: FileType.media,
        );
      }
    }

    /// Picks image file(s) from the device's gallery.
    ///
    /// If [allowMultiple] is true, attempts to pick multiple images at once.
    /// Falls back to single image picking if [pickMultiImage] is not supported
    /// (requires iOS 14+).
    ///
    /// Returns a list of [FilePicked] objects containing the selected image(s).
    /// Returns an empty list if no image is selected.
    if (type == FileType.image) {
      final picker = ImagePicker();
      if (allowMultiple) {
        final stopwatch = Stopwatch()..start();
        try {
          final result = await picker.pickMultiImage(
            limit: limit,
          );

          stopwatch.stop();
          return Future.wait([...result.map(FilePicked.fromXFile)]);
        } catch (e) {
          stopwatch.stop();
          // Only fallback when the error fires almost instantly, which
          // indicates a platform-version limitation (iOS < 14).
          if (stopwatch.elapsedMilliseconds > _versionErrorThresholdMs) {
            rethrow;
          }
          // Fallback: pickMultiImage requires iOS 14+.
          // Fall through to single pickImage below.
        }
      }

      final file = await picker.pickImage(
        source: ImageSource.gallery,
      );
      return file != null ? [await FilePicked.fromXFile(file)] : [];
    }

    /// Picks video file(s) from the device's gallery.
    ///
    /// If [allowMultiple] is true, attempts to pick multiple videos with the
    /// specified [limit].
    /// Falls back to single video picking if [pickMultiVideo] is not supported
    /// (requires iOS 14+).
    ///
    /// Returns a list of [FilePicked] objects containing the selected video
    /// file(s).
    /// Returns an empty list if no video is selected.
    if (type == FileType.video) {
      final picker = ImagePicker();
      if (allowMultiple) {
        final stopwatch = Stopwatch()..start();
        try {
          final result = await picker.pickMultiVideo(
            limit: limit,
          );

          stopwatch.stop();
          return Future.wait([...result.map(FilePicked.fromXFile)]);
        } catch (e) {
          stopwatch.stop();
          // Only fallback when the error fires almost instantly, which
          // indicates a platform-version limitation (iOS < 14).
          if (stopwatch.elapsedMilliseconds > _versionErrorThresholdMs) {
            rethrow;
          }
          // Fallback: pickMultiVideo requires iOS 14+.
          // Fall through to single pickVideo below.
        }
      }
      final file = await picker.pickVideo(
        source: ImageSource.gallery,
      );
      return file != null ? [await FilePicked.fromXFile(file)] : [];
    }

    throw UnsupportedError(
      'PickFileHelper.pickMedia only supports media, image, and video types.\n'
      ' Requested type: [$type]',
    );
  }

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

  static List<FilePicked> limitMediaFiles(
    List<FilePicked> allFiles, {
    required int maxImages,
    required int maxVideos,
  }) {
    final limitedFiles = <FilePicked>[];
    var imageCount = 0;
    var videoCount = 0;

    for (final file in allFiles) {
      final mimeType = file.mimeType ?? lookupMimeType(file.path ?? '') ?? '';

      if (mimeType.startsWith('image/')) {
        if (imageCount < maxImages) {
          limitedFiles.add(file);
          imageCount++;
        }
      } else if (mimeType.startsWith('video/')) {
        if (videoCount < maxVideos) {
          limitedFiles.add(file);
          videoCount++;
        }
      }
    }

    return limitedFiles;
  }
}
