import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/data_source/local/local_data_manager.dart';
import 'di.config.dart';

GetIt injector = GetIt.instance;
@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<dynamic> configureDependencies() async {
  injector
    ..registerSingleton<SharedPreferences>(
      await SharedPreferences.getInstance(),
    )
    ..registerSingleton<LocalDataManager>(await LocalDataManager.init());
  return $initGetIt(injector);
}

@module
abstract class AppModule {}
