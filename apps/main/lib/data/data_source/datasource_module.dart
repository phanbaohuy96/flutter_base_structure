import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/auth_session_store.dart';
import 'local/local_data_manager.dart';

@module
abstract class AppDatasourceModule {
  @lazySingleton
  AppPreferenceData appPreferenceData(LocalDataManager localDataManager) =>
      localDataManager;

  @lazySingleton
  AuthSessionStore authSessionStore(LocalDataManager localDataManager) =>
      localDataManager;

  /// Substitutes the app-scope [LocalDataManager] (which adds `userInfo` /
  /// `saveUserInfo`) wherever core code asks for [CoreLocalDataManager]. Both
  /// DI keys resolve to the same singleton, so the in-memory token cache and
  /// the user-info-aware seam are shared across `core` and `apps/main`.
  @lazySingleton
  CoreLocalDataManager coreLocalDataManager(
    LocalDataManager localDataManager,
  ) => localDataManager;
}
