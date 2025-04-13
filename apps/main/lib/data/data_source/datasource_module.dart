import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

import 'local/local_data_manager.dart';

@module
abstract class AppDatasourceModule {
  // Reassign injectable
  @injectable
  CoreLocalDataManager coreLocalDataManager(
    LocalDataManager localDataManager,
  ) =>
      localDataManager;
}
