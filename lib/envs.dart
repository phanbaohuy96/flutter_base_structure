class Env {
  static const environmentKey = 'environment';
  static const cheatKey = 'cheat';
  static const appnameKey = 'appname';
  static const baseApiLayerKey = 'baseApiLayer';

  static final Map<String, dynamic> devEnv = {
    environmentKey: 'dev',
    cheatKey: true,
    appnameKey: 'App Dev',
    baseApiLayerKey: ''
  };

  static final Map<String, dynamic> prodEnv = {
    environmentKey: 'prod',
    cheatKey: false,
    appnameKey: 'App Prod',
    baseApiLayerKey: ''
  };
}

class Config {
  static Config get appConfig => _appConfig;
  static Config _appConfig;

  static void setup(Map<String, dynamic> env) {
    _appConfig = Config.from(env);
  }

  String envName;
  bool cheat;
  String appName;
  String baseApiLayer;

  Config(this.envName, this.cheat, this.appName, this.baseApiLayer);

  Config.from(Map<String, dynamic> env) {
    envName = env[Env.environmentKey];
    cheat = env[Env.cheatKey];
    appName = env[Env.appnameKey];
    baseApiLayer = env[Env.baseApiLayerKey];
  }
}
