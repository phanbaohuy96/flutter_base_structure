import 'package:get_it/get_it.dart';

import '../data/data_source/local/local_data_manager.dart';

GetIt injector = GetIt.instance;

class DI {
  static Future<void> inject() async {
    final localDataManager = LocalDataManager();
    await localDataManager.init();
    injector.registerLazySingleton<LocalDataManager>(() => localDataManager);
  }
}
