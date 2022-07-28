import 'package:args/args.dart';
import 'package:module_generator/module_generator.dart' as module_generator;

void main(List<String> args) {
  var parser = ArgParser();
  parser.addOption(
    'path',
    callback: (path) => {module_generator.showModuleGeneratorMenu()},
  );
  parser.parse(args);
}
