import '../../common/utils.dart';
import '../../envs.dart';

class Config {
  static final Config instance = Config._();

  Config._();

  AppConfig get appConfig => _appConfig;
  late AppConfig _appConfig;

  // ignore: use_setters_to_change_properties
  void fromConfig(AppConfig config) {
    _appConfig = config;
  }

  static bool get orgIsEmpty => instance.appConfig.graphqlApiKey.isNullOrEmpty;
}

class AppConfig {
  final String envName;
  final bool developmentMode;
  final String baseApiLayer;
  final String storageApiLayer;
  final String storageAssetLayer;
  final String baseGraphQLUrl;
  final String graphqlSocketUrl;
  final String graphqlApiKey;
  final String onesignalAppID;
  final String app;
  final String platformRole;

  AppConfig({
    required this.envName,
    required this.developmentMode,
    required this.baseApiLayer,
    required this.storageApiLayer,
    required this.storageAssetLayer,
    required this.baseGraphQLUrl,
    required this.onesignalAppID,
    required this.graphqlSocketUrl,
    required this.graphqlApiKey,
    required this.app,
    required this.platformRole,
  });

  bool get isDevBuild => envName == Env.devEnvName;

  bool get isStagBuild => envName == Env.stagingEnvName;

  bool get isProdBuild => envName == Env.prodEnvName;
}
