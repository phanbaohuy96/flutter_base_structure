import 'package:args/args.dart';
import 'package:module_generator/generate_app_identifier.dart'
    as generate_app_identifier;

void main(List<String> args) {
  var parser = ArgParser();
  parser.addOption(
    'path',
    callback: (path) =>
        {generate_app_identifier.generateAppIdentifier(args: args)},
  );
  parser.parse(args);
}
