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
    final res = autoCompressImage
        ? await _compressFileIfImage(
            await file.readAsBytes(),
            filePath: file.path,
            mimeType: _mimeType,
            option: compressImageOption,
          ).then(
            (bytes) => _storageRepository.uploadBytes(
              [
                dio.MultipartFile.fromBytes(
                  bytes.$1,
                  filename: file.path.split('/').last,
                  contentType: _mimeType?.let(
                    (it) {
                      return dio.DioMediaType.parse(it);
                    },
                  ),
                ),
              ],
              cancelToken: cancelToken,
              onSendProgress: onSendProgress,
            ),
          )
        : await _storageRepository.uploadFile(file);

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
        ? await _compressFileIfImage(
            bytes,
            filePath: filePath,
            mimeType: mimeType,
            option: compressImageOption,
          ).then(
            (bytes) => _storageRepository.uploadBytes(
              [
                dio.MultipartFile.fromBytes(
                  bytes.$1,
                  filename: name,
                  contentType: mimeType?.let(
                    (it) {
                      return dio.DioMediaType.parse(it);
                    },
                  ),
                ),
              ],
              cancelToken: cancelToken,
              onSendProgress: onSendProgress,
            ),
          )
        : await _storageRepository.uploadBytes(
            [
              dio.MultipartFile.fromBytes(
                bytes,
                filename: name,
                contentType: mimeType?.let(
                  (it) {
                    return dio.DioMediaType.parse(it);
                  },
                ),
              ),
            ],
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
          );

    return res.data;
  }

  @override
  Future<CloudFile?> uploadImageBytes(
    Uint8List bytes,
    String name, {
    String? mimeType,
    bool autoCompressImage = false,
    CompressImageOption compressImageOption = const CompressImageOption(),
    dio.CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    final res = autoCompressImage
        ? await _compressHelper
            .compressWithList(
              image: bytes,
              option: compressImageOption,
            )
            .then(
              (bytes) => _storageRepository.uploadBytes(
                [
                  dio.MultipartFile.fromBytes(
                    bytes.$1,
                    filename: name,
                    contentType: mimeType?.let(
                      (it) {
                        return dio.DioMediaType.parse(it);
                      },
                    ),
                  ),
                ],
                cancelToken: cancelToken,
                onSendProgress: onSendProgress,
              ),
            )
        : await _storageRepository.uploadBytes(
            [
              dio.MultipartFile.fromBytes(
                bytes,
                filename: name,
                contentType: mimeType?.let(
                  (it) {
                    return dio.DioMediaType.parse(it);
                  },
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

  Future<(Uint8List image, String? mimeType)> _compressFileIfImage(
    Uint8List bytes, {
    String? filePath,
    String? mimeType,
    CompressImageOption option = const CompressImageOption(),
  }) async {
    final mimeStr = mimeType ?? lookupMimeType(filePath ?? '');
    if (mimeStr?.startsWith('image/') == true) {
      try {
        return _compressHelper.compressWithList(
          image: bytes,
          option: option,
        );
      } catch (e, s) {
        logUtils.e(e, s);
        return (bytes, mimeStr);
      }
    } else {
      return (bytes, mimeStr);
    }
  }
}
