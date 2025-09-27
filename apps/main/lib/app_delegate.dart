import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart'
    if (dart.library.io) 'package:flutter_web_plugins/url_strategy.dart';

import 'di/di.dart';
import 'presentation/app.dart';

class AppDelegate {
  static Future<dynamic> run(AppConfig config) async {
    setUrlStrategy(PathUrlStrategy());

    Config.instance.fromConfig(config);
    return runZonedGuarded(() async {
      // final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
      // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      await Hive.initFlutter();

      await configureDependencies(env: Config.instance.appConfig.envName);

      setLocaleMessages(AppLocale.th.languageCode, ThMessages());
      setLocaleMessages(AppLocale.en.languageCode, EnMessages());

      setDefaultLocale(AppLocale.defaultLocale.languageCode);

      if (kIsWeb) {
      } else {
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );

        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }

      runApp(const MainApplication());
    }, (Object error, StackTrace stack) {
      logUtils.e('Error from runZonedGuarded', error, stack);
    });
  }
}
