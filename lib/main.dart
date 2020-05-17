import 'package:flutter/material.dart';

import 'envs.dart';
import 'presentation/ui/app.dart';

void main() => runApp(App(config: Config.from(Env.devEnv)));
