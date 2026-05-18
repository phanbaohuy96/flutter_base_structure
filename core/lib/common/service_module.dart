import 'package:injectable/injectable.dart';

import '../data/data_source/remote/repository/storage_repository/storage_repository.dart';
import '../domain/entity/config.dart';
import 'components/image_compress/image_compress.dart';
import 'services/header/providers/auth_header_provider.dart';
import 'services/header/request_header_service.dart';
import 'services/location/location_service.dart';
import 'services/storage/storage_service.dart';

@module
abstract class ServiceModule {
  @lazySingleton
  RequestHeaderService requestHeaderService(
    AppConfigHeaderProvider appConfigHeaderProvider,
    LanguageHeaderProvider languageHeaderProvider,
    SystemHeaderProvider systemHeaderProvider,
    AuthHeaderProvider authHeaderProvider,
  ) =>
      RequestHeaderServiceImpl(
        providers: [
          appConfigHeaderProvider,
          languageHeaderProvider,
          systemHeaderProvider,
          authHeaderProvider,
        ],
      );

  @injectable
  StorageService storageService(
    StorageRepository _storageRepository,
    ImageCompressHelper _imageCompressHelper,
  ) =>
      StorageServiceImpl(
        _imageCompressHelper,
        _storageRepository,
        Config.instance.appConfig.storageAssetLayer,
      );

  @injectable
  StorageAssetProvider storageAssetProvider(StorageService _storageService) =>
      StorageAssetProvider(_storageService);

  @lazySingleton
  LocationService locationService() => LocationServiceImpl();
}
