import 'dart:async';
import 'package:flutter/material.dart';

import 'common/config.dart';
import 'common/utils.dart';
import 'envs.dart';
import 'presentation/modules/app.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    Config.instance.setup(Env.devEnv);
    runApp(const App());
  }, (Object error, StackTrace stack) {
    LogUtils.e('Error from runZonedGuarded', error, stack);
  });
}
