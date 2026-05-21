import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio hide ProgressCallback;

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
}
