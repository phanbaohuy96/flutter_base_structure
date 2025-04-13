import 'package:args/args.dart';
import 'package:module_generator/generate_export.dart' as generate_export;

void main(List<String> args) {
  var parser = ArgParser();
  parser.addOption(
    'path',
    callback: (path) => {generate_export.generateExport(args: args)},
  );
  parser.parse(args);
}
