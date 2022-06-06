import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'common/config.dart';
import 'common/utils.dart';
import 'di/di.dart';
import 'presentation/modules/app.dart';

class AppDelegate {
  static Future<dynamic> run(Map<String, dynamic> env) async {
    WidgetsFlutterBinding.ensureInitialized();

    Config.instance.setup(env);

    await Future.wait([
      configureDependencies(),
    ]);

    return runZonedGuarded(() async {
      runApp(const App());
    }, (Object error, StackTrace stack) {
      LogUtils.e('Error from runZonedGuarded', error, stack);
    });
  }
}
