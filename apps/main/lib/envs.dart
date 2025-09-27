import 'package:core/core.dart';

class AppEnv extends Env {
  static final AppConfig _fromDartWithDefaultDevEnv = AppConfig.fromDart(
    envName: Env.devEnvName,
    app: 'main',
  );

  static final AppConfig devEnv = _fromDartWithDefaultDevEnv;

  static final AppConfig stagingEnv = _fromDartWithDefaultDevEnv.copyWith(
    envName: Env.stagingEnvName,
  );

  static final AppConfig sanboxEnv = _fromDartWithDefaultDevEnv.copyWith(
    envName: Env.stagingEnvName,
  );

  static final AppConfig prodEnv = _fromDartWithDefaultDevEnv.copyWith(
    envName: Env.prodEnvName,
  );
}
