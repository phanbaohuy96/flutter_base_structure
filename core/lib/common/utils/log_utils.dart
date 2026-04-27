import 'package:fl_utils/fl_utils.dart';
import 'package:injectable/injectable.dart';

import '../../di/core_micro.dart';
import '../../envs.dart';

final logUtils = injector<LogUtils>();

@module
abstract class LogUtilsModule {
  @Injectable(env: [Env.devEnvName, Env.stagingEnvName])
  LogUtils get devLogUtils => LogUtils();

  @Injectable(env: [Env.sanboxEnvName, Env.prodEnvName])
  LogUtils get prodLogUtils => LogUtils(cacheToView: false);
}
