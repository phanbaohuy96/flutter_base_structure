import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../models/api_response.dart';
import '../../../../models/cloud_file.dart';

part 'storage_repository.g.dart';

@RestApi()
abstract class StorageRepository {
  factory StorageRepository(Dio dio, {String baseUrl}) = _StorageRepository;

  @POST('files')
  @MultiPart()
  Future<ApiResponse<CloudFile>> uploadFile(
    @Part(name: 'file') File file, {
    @Header('Authorization') String? authorization,
    @SendProgress() ProgressCallback? onSendProgress,
    @CancelRequest() CancelToken? cancelToken,
  });

  @POST('files')
  @MultiPart()
  Future<ApiResponse<CloudFile>> uploadBytes(
    @Part(name: 'file') List<MultipartFile> files, {
    @Header('Authorization') String? authorization,
    @SendProgress() ProgressCallback? onSendProgress,
    @CancelRequest() CancelToken? cancelToken,
  });
}
