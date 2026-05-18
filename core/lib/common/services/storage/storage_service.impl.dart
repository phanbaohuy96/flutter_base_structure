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
    bool autoCompressImage = true,
    CompressImageOption compressImageOption = const CompressImageOption(),
  }) async {
    final res = autoCompressImage
        ? await _compressFileIfImage(
            file,
            lookupMimeType(file.path),
            option: compressImageOption,
          ).then(
            (bytes) => _storageRepository.uploadBytes(
              [
                dio.MultipartFile.fromBytes(
                  bytes.$1,
                  filename: file.path.split('/').last,
                ),
              ],
            ),
          )
        : await _storageRepository.uploadFile(file);

    return res.data;
  }

  @override
  String getAssetUrl(String id) {
    return [
      assetLayer,
      id,
    ].join('');
  }

  Future<(Uint8List image, String? mimeType)> _compressFileIfImage(
    File file,
    String? mimeType, {
    CompressImageOption option = const CompressImageOption(),
  }) async {
    final mimeStr = mimeType ?? lookupMimeType(file.path);
    final bytes = await file.readAsBytes();
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
