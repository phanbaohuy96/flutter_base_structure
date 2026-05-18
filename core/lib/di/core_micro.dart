import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

export 'core_micro.module.dart';

GetIt get injector => GetIt.instance;

// short const => @microPackageInit
@InjectableInit.microPackage(
  externalPackageModulesBefore: [],
)
void initCoreMicroPackage() {} // will not be called

@module
abstract class DependenciesModule {}
