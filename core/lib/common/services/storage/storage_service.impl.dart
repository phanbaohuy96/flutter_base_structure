part of 'storage_service.dart';

class StorageServiceImpl extends StorageService {
  final StorageRepository _storageRepository;
  final ImageCompressHelper _compressHelper;

  final String assetLayer;

  StorageServiceImpl(
    this._compressHelper,
    this._storageRepository,
    this.assetLayer,
  );

  @override
  Future<CloudFile?> uploadFile(
    File file, {
    String? mimeType,
    bool autoCompressImage = false,
    CompressImageOption compressImageOption = const CompressImageOption(),
    dio.CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    final _mimeType = mimeType ?? lookupMimeType(file.path);
    // Only read the file into memory when we actually need to compress
    // an image. For non-images the repository uploads via a streamed
    // MultipartFile.fromFileSync, which avoids the OOM on large files.
    final _shouldCompress =
        autoCompressImage && _mimeType?.startsWith('image/') == true;
    final res = _shouldCompress
        ? await _compressHelper
              .compressFileIfImage(
                await file.readAsBytes(),
                filePath: file.path,
                mimeType: _mimeType,
                option: compressImageOption,
              )
              .then(
                (compressedResult) {
                  final originalName = file.path.split('/').last;
                  final isCompressed =
                      compressedResult.mimeType ==
                      compressImageOption.format.mimeType;

                  // Only change filename if actually compressed to webp
                  final fileName = isCompressed
                      ? _convertToWebPExtension(originalName)
                      : originalName;

                  return _storageRepository.uploadBytes(
                    [
                      dio.MultipartFile.fromBytes(
                        compressedResult.image,
                        filename: fileName,
                        contentType: compressedResult.mimeType?.let(
                          dio.DioMediaType.parse,
                        ),
                      ),
                    ],
                    cancelToken: cancelToken,
                    onSendProgress: onSendProgress,
                  );
                },
              )
        : await _storageRepository.uploadFile(
            file,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
          );

    return res.data;
  }

  @override
  Future<CloudFile?> uploadBytes(
    Uint8List bytes,
    String name, {
    String? filePath,
    String? mimeType,
    bool autoCompressImage = false,
    CompressImageOption compressImageOption = const CompressImageOption(),
    dio.CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    final res = autoCompressImage
        ? await _compressHelper
              .compressFileIfImage(
                bytes,
                filePath: filePath,
                mimeType: mimeType,
                option: compressImageOption,
              )
              .then((compressedResult) {
                final isCompressed =
                    compressedResult.mimeType ==
                    compressImageOption.format.mimeType;

                // Only change filename if actually compressed to webp
                final convertFileName = isCompressed
                    ? _convertToWebPExtension(name)
                    : name;

                return _storageRepository.uploadBytes(
                  [
                    dio.MultipartFile.fromBytes(
                      compressedResult.image,
                      filename: convertFileName,
                      contentType: compressedResult.mimeType?.let(
                        dio.DioMediaType.parse,
                      ),
                    ),
                  ],
                  cancelToken: cancelToken,
                  onSendProgress: onSendProgress,
                );
              })
        : await _storageRepository.uploadBytes(
            [
              dio.MultipartFile.fromBytes(
                bytes,
                filename: name,
                contentType: mimeType?.let(
                  dio.DioMediaType.parse,
                ),
              ),
            ],
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
          );

    return res.data;
  }

  @override
  String getAssetUrl(String reference) {
    final uri = Uri.parse(assetLayer);
    return uri.resolve(reference).toString();
  }

  String _convertToWebPExtension(String fileName) {
    if (!fileName.contains('.')) {
      return fileName;
    }
    final lastDot = fileName.lastIndexOf('.');
    return '${fileName.substring(0, lastDot)}.webp';
  }
}
