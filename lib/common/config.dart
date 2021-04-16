import '../envs.dart';

class Config {
  static final Config instance = Config._();

  Config._();

  AppConfig? get appConfig => _appConfig;
  AppConfig? _appConfig;

  void setup(Map<String, dynamic> env) {
    _appConfig = AppConfig.from(env);
  }
}

class AppConfig {
  String? envName;
  bool? developmentMode;
  String? appName;
  String? baseApiLayer;
  String? baseGraphQLUrl;
  String? onesignalAppID;
  bool? subDealerEnabled;
  bool? guestRegiterEnabled;

  AppConfig(
    this.envName,
    this.developmentMode,
    this.appName,
    this.baseApiLayer,
    this.baseGraphQLUrl,
    this.onesignalAppID,
    this.subDealerEnabled,
    this.guestRegiterEnabled,
  );

  AppConfig.from(Map<String, dynamic> env) {
    envName = env[Env.environment];
    developmentMode = env[Env.developmentMode];
    appName = env[Env.appName];
    baseApiLayer = env[Env.baseApiLayer];
    baseGraphQLUrl = env[Env.baseGraphQLUrl];
    onesignalAppID = env[Env.onesignalAppID];
    subDealerEnabled = env[Env.subDealerEnabled];
    guestRegiterEnabled = env[Env.guestRegiterEnabled];
  }
}
