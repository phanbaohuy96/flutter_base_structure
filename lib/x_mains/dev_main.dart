import 'package:flutter/material.dart';

import '../envs.dart';
import '../presentation/modules/app.dart';

void main() {
  appConfig = Config.from(Env.devEnv);
  runApp(const App());
}
