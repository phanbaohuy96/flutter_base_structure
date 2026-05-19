import 'dart:async';
import 'dart:developer';

import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_skill/flutter_skill.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart'
    if (dart.library.io) 'package:flutter_web_plugins/url_strategy.dart';

import 'di/di.dart';
import 'presentation/app.dart';

class AppDelegate {
  static Future<dynamic> run(AppConfig config) async {
    setUrlStrategy(PathUrlStrategy());

    Config.instance.fromConfig(config);
    return runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
        if (kDebugMode) {
          FlutterSkillBinding.ensureInitialized();
        }

        await configureDependencies(env: Config.instance.appConfig.envName);

        // Warm the storage seam's token cache so `AuthGateRouteInterceptor`
        // can read it synchronously inside `GoRoute.redirect`.
        await injector<CoreLocalDataManager>().token;

        setLocaleMessages(AppLocale.vi.languageCode, ViMessages());
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
      },
      (Object error, StackTrace stack) {
        try {
          logUtils.e('Error from runZonedGuarded', error, stack);
        } catch (e) {
          // Print first so a pre-DI fault isn't masked by logUtils throwing.
          log('runZonedGuarded caught', error: error, stackTrace: stack);
        }
      },
    );
  }
}
