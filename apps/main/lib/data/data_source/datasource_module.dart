import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

import 'local/local_data_manager.dart';

@module
abstract class AppDatasourceModule {
  /// Substitutes the app-scope [LocalDataManager] (which adds `userInfo` /
  /// `saveUserInfo`) wherever core code asks for [CoreLocalDataManager]. Both
  /// DI keys resolve to the same instance, so the user-info-aware seam is
  /// shared across `core` and `apps/main`.
  @injectable
  CoreLocalDataManager coreLocalDataManager(
    LocalDataManager localDataManager,
  ) => localDataManager;
}
