import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio hide ProgressCallback;
import 'package:flutter/material.dart';

import '../../../core.dart';

part 'storage_service.impl.dart';

typedef ProgressCallback = void Function(int count, int total);

abstract class StorageService {
  Future<CloudFile?> uploadFile(
    File file, {
    String? mimeType,
    bool autoCompressImage = true,
    CompressImageOption compressImageOption = const CompressImageOption(),
    dio.CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  });

  Future<CloudFile?> uploadBytes(
    Uint8List bytes,
    String name, {
    String? filePath,
    String? mimeType,
    bool autoCompressImage = true,
    CompressImageOption compressImageOption = const CompressImageOption(),
    dio.CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  });

  String getAssetUrl(String reference);
}

class StorageAssetProvider {
  final StorageService storageService;

  StorageAssetProvider(this.storageService);

  /// Generates a URL for the given reference.
  ///
  /// If [shouldBeUUID] is true (default), the method checks if the reference
  /// is a UUID. If it is a UUID, it returns the asset URL using the
  /// `storageService.getAssetUrl` method. If the reference is not a UUID,
  /// it logs a debug message and returns the reference as is.
  ///
  /// If [shouldBeUUID] is false, the method directly returns the asset URL
  /// without checking if the reference is a UUID.
  ///
  /// Usage:
  /// ```dart
  /// String assetUrl = url('some-reference');
  /// String assetUrlWithoutUUIDCheck = url('some-reference', false);
  /// ```
  ///
  /// - [reference]: The reference string to generate the URL for.
  /// - [shouldBeUUID]: A boolean flag indicating whether
  /// the reference should be a UUID.
  ///
  /// Returns the generated URL or the original reference if it is not a UUID.
  String url(String reference, [bool shouldBeUUID = false]) {
    if (reference.isNotEmpty) {
      if (reference.isUrl) {
        return reference;
      }
      if (reference.isLocalUrl) {
        return reference;
      }
      if (!shouldBeUUID || reference.split('.').first.isUUID) {
        return storageService.getAssetUrl(reference);
      }
      debugPrint('''StorageAssetProvider.url action on reference isn't UUID''');
    }
    return reference;
  }
}
