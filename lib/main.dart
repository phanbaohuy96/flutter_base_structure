import 'package:flutter/material.dart';

import 'envs.dart';
import 'presentation/modules/app.dart';

void main() {
  Config.setup(Env.prodEnv);
  runApp(const App());
}
