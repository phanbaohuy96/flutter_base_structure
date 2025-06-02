import 'package:fl_utils/fl_utils.dart';
import 'package:injectable/injectable.dart';

import '../../di/core_micro.dart';
import '../../envs.dart';

final logUtils = injector<LogUtils>();

@module
abstract class LogUtilsModule {
  @Injectable(env: [Env.devEnvName])
  LogUtils get devLogUlils => LogUtils();

  @Injectable(env: [Env.stagingEnvName, Env.prodEnvName])
  LogUtils get prodLogUlils => LogUtils(
        cacheToView: false,
      );
}
