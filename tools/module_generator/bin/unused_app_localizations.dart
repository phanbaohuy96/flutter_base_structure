import 'package:args/args.dart';
import 'package:module_generator/generate_app_localizations.dart' as generator;

/// Usage:
/// dart run module_generator:unused_app_localizations
void main(List<String> args) {
  var parser = ArgParser();

  var removeUnused = false;

  parser.addFlag(
    'remove',
    abbr: 'r',
    help: 'Remove unused localizations',
    callback: (value) {
      if (value) {
        removeUnused = true;
      }
    },
  );

  parser.addOption(
    'path',
    callback: (path) => generator.checkUnusedL10n(shouldRemove: removeUnused),
  );

  parser.parse(args);
}
