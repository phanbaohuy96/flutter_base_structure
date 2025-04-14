import 'package:args/args.dart';
import 'package:module_generator/generate_app_localizations.dart' as generator;

/// Usage:
/// dart run module_generator:check_unused_app_localizations
void main(List<String> args) {
  var parser = ArgParser();

  parser.addOption(
    'path',
    callback: (path) => {generator.checkUnusedL10n()},
  );

  parser.parse(args);
}
