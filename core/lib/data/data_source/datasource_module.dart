import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/services/header/request_header_service.dart';
import '../../domain/entity/config.dart';
import 'local/local_data_manager.dart';
import 'remote/app_api_service.dart';
import 'remote/clients/dio_client_factory.dart';
import 'remote/repository/rest_api_repository/rest_api_repository.dart';
import 'remote/repository/storage_repository/storage_repository.dart';

@module
abstract class DatasourceModule {
  ///
  /// LOCAL
  ///
  @preResolve
  @singleton
  Future<SharedPreferences> get sharedPref => SharedPreferences.getInstance();

  @singleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(),
  );

  ///
  /// REMOTE
  ///
  @injectable
  Dio createDioClient(
    CoreLocalDataManager localDataManager,
    RequestHeaderService requestHeaderService,
  ) => DioClientFactory.build(
    localDataManager: localDataManager,
    requestHeaderService: requestHeaderService,
    baseUrl: Config.instance.appConfig.baseApiLayer,
  );

  @injectable
  RestApiRepository restApiRepo(Dio dio) => RestApiRepository(dio);

  @injectable
  AppApiService createAppApiService(
    RestApiRepository restApi,
    CoreLocalDataManager localDataManagert,
  ) => AppApiService(restApi, localDataManagert);

  @injectable
  StorageRepository storageRepo(Dio dio) => StorageRepository(
    dio,
    baseUrl: Config.instance.appConfig.storageApiLayer,
  );
}
