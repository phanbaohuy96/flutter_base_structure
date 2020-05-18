import 'package:flutter/material.dart';

import '../envs.dart';
import '../presentation/modules/app.dart';

void main() {
  appConfig = Config.from(Env.prodEnv);
  runApp(const App());
}
