import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class AppEnv extends Env {
  static final AppConfig devEnv = AppConfig(
    envName: Env.devEnvName,
    developmentMode: kDebugMode,
    baseApiLayer: '',
    storageApiLayer: '',
    storageAssetLayer: '',
    baseGraphQLUrl: '',
    graphqlSocketUrl: '',
    graphqlApiKey: '',
    onesignalAppID: '',
    app: 'main',
    platformRole: '',
  );

  static final AppConfig stagingEnv = AppConfig(
    envName: Env.stagingEnvName,
    developmentMode: kDebugMode,
    baseApiLayer: '',
    storageApiLayer: '',
    storageAssetLayer: '',
    baseGraphQLUrl: '',
    graphqlSocketUrl: '',
    graphqlApiKey: '',
    onesignalAppID: '',
    app: 'main',
    platformRole: '',
  );

  static final AppConfig prodEnv = AppConfig(
    envName: Env.prodEnvName,
    developmentMode: kDebugMode,
    baseApiLayer: '',
    storageApiLayer: '',
    storageAssetLayer: '',
    baseGraphQLUrl: '',
    graphqlSocketUrl: '',
    graphqlApiKey: '',
    onesignalAppID: '',
    app: 'main',
    platformRole: '',
  );
}
