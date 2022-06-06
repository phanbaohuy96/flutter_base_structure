import 'package:flutter/foundation.dart';

class Env {
  static const environment = 'environment';
  static const developmentMode = 'developmentMode';
  static const appName = 'appname';
  static const baseApiLayer = 'baseApiLayer';
  static const baseGraphQLUrl = 'baseGraphQLUrl';
  static const onesignalAppID = 'onesignalAppID';

  static const devEnvName = 'Development';
  static const stagingEnvName = 'Staging';
  static const prodEnvName = 'Production';

  static final Map<String, dynamic> devEnv = {
    environment: devEnvName,
    developmentMode: kDebugMode,
    appName: 'FBS_Dev',
    baseApiLayer: '',
    baseGraphQLUrl: '',
    onesignalAppID: '',
  };

  static final Map<String, dynamic> stagingEnv = {
    environment: stagingEnvName,
    developmentMode: kDebugMode,
    appName: 'FBS_Staging',
    baseApiLayer: '',
    baseGraphQLUrl: '',
    onesignalAppID: '',
  };

  static final Map<String, dynamic> prodEnv = {
    environment: prodEnvName,
    developmentMode: kDebugMode,
    appName: 'FBS',
    baseApiLayer: '',
    baseGraphQLUrl: '',
    onesignalAppID: '',
  };
}
