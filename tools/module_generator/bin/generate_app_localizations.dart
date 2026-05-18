import 'package:args/args.dart';
import 'package:module_generator/generate_app_localizations.dart'
    as generate_app_localizations;

void main(List<String> args) {
  var parser = ArgParser();

  parser.addOption(
    'path',
    callback: (path) => {generate_app_localizations.generateAppLocalizations()},
  );

  parser.parse(args);
}
