import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../core.dart';

/*
  * Usage: Configuration for dart define from file

## APP_DOMAIN
DART_ENV_NAME=''
DART_BASE_API_LAYER=''
DART_STORAGE_API_LAYER=''
DART_STORAGE_ASSET_LAYER=''

## FIREBASE
# ANDROID
DART_ANDROID_FIREBASE_API_KEY=''
DART_ANDROID_FIREBASE_APP_ID=''
DART_ANDROID_FIREBASE_MESSAGING_SENDER_ID=''
DART_ANDROID_FIREBASE_PROJECT_ID=''
DART_ANDROID_FIREBASE_STORAGE_BUCKET=''
DART_ANDROID_FIREBASE_MEASUREMENT_ID=''
DART_ANDROID_FIREBASE_AUTH_DOMAIN=''
DART_ANDROID_FIREBASE_DATABASE_URL=''
# IOS
DART_IOS_FIREBASE_API_KEY=''
DART_IOS_FIREBASE_APP_ID=''
DART_IOS_FIREBASE_MESSAGING_SENDER_ID=''
DART_IOS_FIREBASE_PROJECT_ID=''
DART_IOS_FIREBASE_STORAGE_BUCKET=''
DART_IOS_FIREBASE_MEASUREMENT_ID=''
DART_IOS_FIREBASE_AUTH_DOMAIN=''
DART_IOS_FIREBASE_DATABASE_URL=''
# WEB
DART_WEB_FIREBASE_API_KEY=''
DART_WEB_FIREBASE_APP_ID=''
DART_WEB_FIREBASE_MESSAGING_SENDER_ID=''
DART_WEB_FIREBASE_PROJECT_ID=''
DART_WEB_FIREBASE_STORAGE_BUCKET=''
DART_WEB_FIREBASE_MEASUREMENT_ID=''
DART_WEB_FIREBASE_AUTH_DOMAIN=''
DART_WEB_FIREBASE_DATABASE_URL=''
*/

class Config {
  static final Config instance = Config._();

  Config._();

  AppConfig get appConfig => _appConfig;
  late AppConfig _appConfig;

  // ignore: use_setters_to_change_properties
  void fromConfig(AppConfig config) {
    _appConfig = config;
  }
}

class AppConfig {
  final String envName;
  final String baseApiLayer;
  final String storageApiLayer;
  final String storageAssetLayer;
  final String baseGraphQLUrl;
  final String graphqlSocketUrl;
  final String graphqlApiKey;
  final String onesignalAppID;
  final String app;
  final String platformRole;
  final FirebaseEnv firebase;

  const AppConfig({
    this.envName = '',
    this.baseApiLayer = '',
    this.storageApiLayer = '',
    this.storageAssetLayer = '',
    this.baseGraphQLUrl = '',
    this.onesignalAppID = '',
    this.graphqlSocketUrl = '',
    this.graphqlApiKey = '',
    this.app = '',
    this.platformRole = '',
    this.firebase = const FirebaseEnv(),
  });

  bool get isDevBuild => envName == Env.devEnvName;

  bool get isStagBuild => envName == Env.stagingEnvName;

  bool get isSanboxBuild => envName == Env.stagingEnvName;

  bool get isProdBuild => envName == Env.prodEnvName;

  factory AppConfig.fromDart({
    String app = '',
    String envName = '',
    String baseApiLayer = '',
    String storageApiLayer = '',
    String storageAssetLayer = '',
    String baseGraphQLUrl = '',
    String graphqlSocketUrl = '',
    String graphqlApiKey = '',
    String onesignalAppID = '',
    String platformRole = '',
    FirebaseEnv firebase = const FirebaseEnv(),
  }) {
    const _app = String.fromEnvironment('DART_APP');
    const _envName = String.fromEnvironment('DART_EVN_NAME');
    const _baseApiLayer = String.fromEnvironment('DART_BASE_API_LAYER');
    const _storageApiLayer = String.fromEnvironment('DART_STORAGE_API_LAYER');
    const _storageAssetLayer = String.fromEnvironment(
      'DART_STORAGE_ASSET_LAYER',
    );
    const _baseGraphQLUrl = String.fromEnvironment('DART_BASE_GRAPHQL_URL');
    const _graphqlApiKey = String.fromEnvironment('DART_GRAPHQL_API_KEY');
    const _graphqlSocketUrl = String.fromEnvironment('DART_GRAPHQL_SOCKET_URL');
    const _onesignalAppID = String.fromEnvironment('DART_ONESIGNAL_APP_ID');
    const _platformRole = String.fromEnvironment('DART_PLATFORM_ROLE');
    return AppConfig(
      app: _app.byDefault(defaultValue: app),
      envName: _envName.byDefault(defaultValue: envName),
      baseApiLayer: _baseApiLayer.byDefault(defaultValue: baseApiLayer),
      storageApiLayer: _storageApiLayer.byDefault(
        defaultValue: storageApiLayer,
      ),
      storageAssetLayer: _storageAssetLayer.byDefault(
        defaultValue: storageAssetLayer,
      ),
      baseGraphQLUrl: _baseGraphQLUrl.byDefault(defaultValue: baseGraphQLUrl),
      graphqlApiKey: _graphqlApiKey.byDefault(defaultValue: graphqlApiKey),
      graphqlSocketUrl: _graphqlSocketUrl.byDefault(
        defaultValue: graphqlSocketUrl,
      ),
      onesignalAppID: _onesignalAppID.byDefault(defaultValue: onesignalAppID),
      platformRole: _platformRole.byDefault(defaultValue: platformRole),
      firebase: FirebaseEnv.fromDartPlatformSpecific(
        apiKey: firebase.apiKey,
        appId: firebase.appId,
        messageSenderId: firebase.messageSenderId,
        projectId: firebase.projectId,
        storageBucket: firebase.storageBucket,
        measurementId: firebase.measurementId,
        authDomain: firebase.authDomain,
        databaseUrl: firebase.databaseUrl,
      ),
    );
  }

  AppConfig copyWith({
    String? envName,
    String? baseApiLayer,
    String? storageApiLayer,
    String? storageAssetLayer,
    String? baseGraphQLUrl,
    String? graphqlSocketUrl,
    String? graphqlApiKey,
    String? onesignalAppID,
    String? app,
    String? platformRole,
  }) {
    return AppConfig(
      app: app ?? this.app,
      envName: envName ?? this.envName,
      baseApiLayer: baseApiLayer ?? this.baseApiLayer,
      storageApiLayer: storageApiLayer ?? this.storageApiLayer,
      storageAssetLayer: storageAssetLayer ?? this.storageAssetLayer,
      baseGraphQLUrl: baseGraphQLUrl ?? this.baseGraphQLUrl,
      graphqlSocketUrl: graphqlSocketUrl ?? this.graphqlSocketUrl,
      graphqlApiKey: graphqlApiKey ?? this.graphqlApiKey,
      onesignalAppID: onesignalAppID ?? this.onesignalAppID,
      platformRole: platformRole ?? this.platformRole,
    );
  }
}

class FirebaseEnv {
  final String apiKey;
  final String appId;
  final String messageSenderId;
  final String projectId;
  final String storageBucket;
  final String measurementId;
  final String authDomain;
  final String databaseUrl;

  const FirebaseEnv({
    this.apiKey = '',
    this.appId = '',
    this.messageSenderId = '',
    this.projectId = '',
    this.storageBucket = '',
    this.measurementId = '',
    this.authDomain = '',
    this.databaseUrl = '',
  });

  factory FirebaseEnv.fromDartPlatformSpecific({
    String apiKey = '',
    String appId = '',
    String messageSenderId = '',
    String projectId = '',
    String storageBucket = '',
    String measurementId = '',
    String authDomain = '',
    String databaseUrl = '',
  }) {
    if (kIsWeb) {
      return FirebaseEnv._web(
        apiKey: apiKey,
        appId: appId,
        messageSenderId: messageSenderId,
        projectId: projectId,
        storageBucket: storageBucket,
        measurementId: measurementId,
        authDomain: authDomain,
        databaseUrl: databaseUrl,
      );
    }
    if (Platform.isAndroid) {
      return FirebaseEnv._android(
        apiKey: apiKey,
        appId: appId,
        messageSenderId: messageSenderId,
        projectId: projectId,
        storageBucket: storageBucket,
        measurementId: measurementId,
        authDomain: authDomain,
        databaseUrl: databaseUrl,
      );
    }
    if (Platform.isIOS) {
      return FirebaseEnv._ios(
        apiKey: apiKey,
        appId: appId,
        messageSenderId: messageSenderId,
        projectId: projectId,
        storageBucket: storageBucket,
        measurementId: measurementId,
        authDomain: authDomain,
        databaseUrl: databaseUrl,
      );
    }

    return const FirebaseEnv();
  }

  factory FirebaseEnv._web({
    String apiKey = '',
    String appId = '',
    String messageSenderId = '',
    String projectId = '',
    String storageBucket = '',
    String measurementId = '',
    String authDomain = '',
    String databaseUrl = '',
  }) {
    const _apiKey = String.fromEnvironment('DART_WEB_API_KEY');
    const _appId = String.fromEnvironment('DART_WEB_APP_ID');
    const _messageSenderId = String.fromEnvironment(
      'DART_WEB_MESSAGING_SENDER_ID',
    );
    const _projectId = String.fromEnvironment('DART_WEB_PROJECT_ID');
    const _storageBucket = String.fromEnvironment('DART_WEB_STORAGE_BUCKET');
    const _measurementId = String.fromEnvironment('DART_WEB_MEASUREMENT_ID');
    const _authDomain = String.fromEnvironment('DART_WEB_AUTH_DOMAIN');
    const _databaseUrl = String.fromEnvironment('DART_WEB_DATABASE_URL');
    return FirebaseEnv(
      apiKey: _apiKey.byDefault(defaultValue: apiKey),
      appId: _appId.byDefault(defaultValue: appId),
      messageSenderId: _messageSenderId.byDefault(
        defaultValue: messageSenderId,
      ),
      projectId: _projectId.byDefault(defaultValue: projectId),
      storageBucket: _storageBucket.byDefault(defaultValue: storageBucket),
      measurementId: _measurementId.byDefault(defaultValue: measurementId),
      authDomain: _authDomain.byDefault(defaultValue: authDomain),
      databaseUrl: _databaseUrl.byDefault(defaultValue: databaseUrl),
    );
  }

  factory FirebaseEnv._android({
    String apiKey = '',
    String appId = '',
    String messageSenderId = '',
    String projectId = '',
    String storageBucket = '',
    String measurementId = '',
    String authDomain = '',
    String databaseUrl = '',
  }) {
    const _apiKey = String.fromEnvironment('DART_ANDROID_API_KEY');
    const _appId = String.fromEnvironment('DART_ANDROID_APP_ID');
    const _messageSenderId = String.fromEnvironment(
      'DART_ANDROID_MESSAGING_SENDER_ID',
    );
    const _projectId = String.fromEnvironment('DART_ANDROID_PROJECT_ID');
    const _storageBucket = String.fromEnvironment(
      'DART_ANDROID_STORAGE_BUCKET',
    );
    const _measurementId = String.fromEnvironment(
      'DART_ANDROID_MEASUREMENT_ID',
    );
    const _authDomain = String.fromEnvironment('DART_ANDROID_AUTH_DOMAIN');
    const _databaseUrl = String.fromEnvironment('DART_ANDROID_DATABASE_URL');
    return FirebaseEnv(
      apiKey: _apiKey.byDefault(defaultValue: apiKey),
      appId: _appId.byDefault(defaultValue: appId),
      messageSenderId: _messageSenderId.byDefault(
        defaultValue: messageSenderId,
      ),
      projectId: _projectId.byDefault(defaultValue: projectId),
      storageBucket: _storageBucket.byDefault(defaultValue: storageBucket),
      measurementId: _measurementId.byDefault(defaultValue: measurementId),
      authDomain: _authDomain.byDefault(defaultValue: authDomain),
      databaseUrl: _databaseUrl.byDefault(defaultValue: databaseUrl),
    );
  }

  factory FirebaseEnv._ios({
    String apiKey = '',
    String appId = '',
    String messageSenderId = '',
    String projectId = '',
    String storageBucket = '',
    String measurementId = '',
    String authDomain = '',
    String databaseUrl = '',
  }) {
    const _apiKey = String.fromEnvironment('DART_IOS_API_KEY');
    const _appId = String.fromEnvironment('DART_IOS_APP_ID');
    const _messageSenderId = String.fromEnvironment(
      'DART_IOS_MESSAGING_SENDER_ID',
    );
    const _projectId = String.fromEnvironment('DART_IOS_PROJECT_ID');
    const _storageBucket = String.fromEnvironment('DART_IOS_STORAGE_BUCKET');
    const _measurementId = String.fromEnvironment('DART_IOS_MEASUREMENT_ID');
    const _authDomain = String.fromEnvironment('DART_IOS_AUTH_DOMAIN');
    const _databaseUrl = String.fromEnvironment('DART_IOS_DATABASE_URL');
    return FirebaseEnv(
      apiKey: _apiKey.byDefault(defaultValue: apiKey),
      appId: _appId.byDefault(defaultValue: appId),
      messageSenderId: _messageSenderId.byDefault(
        defaultValue: messageSenderId,
      ),
      projectId: _projectId.byDefault(defaultValue: projectId),
      storageBucket: _storageBucket.byDefault(defaultValue: storageBucket),
      measurementId: _measurementId.byDefault(defaultValue: measurementId),
      authDomain: _authDomain.byDefault(defaultValue: authDomain),
      databaseUrl: _databaseUrl.byDefault(defaultValue: databaseUrl),
    );
  }
}

extension on String {
  String byDefault({String defaultValue = ''}) {
    return isNotEmpty ? this : defaultValue;
  }
}
