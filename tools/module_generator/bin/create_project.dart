import 'dart:io';

import 'package:module_generator/create_project.dart';

Future<void> main(List<String> arguments) async {
  final exitCode = await runCreateProjectCommand(arguments);
  exit(exitCode);
}
