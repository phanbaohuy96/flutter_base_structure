import '../di/core_micro.dart';
import 'services/storage/storage_service.dart';

mixin StorageServiceMixin {
  StorageService get storageService => injector();

  StorageAssetProvider get storageAssetProvider => injector();
}
