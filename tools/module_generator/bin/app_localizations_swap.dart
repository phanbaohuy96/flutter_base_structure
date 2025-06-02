import 'package:args/args.dart';
import 'package:module_generator/generate_app_localizations.dart'
    as generate_app_localizations;

/// Usage:
/// dart run module_generator:app_localizations_swap
///
/// Arguments
///   -f | --first-col-index      => First column index  (default: 1)
///   -s | --second-col-index     => Second column index (default: 2)
void main(List<String> args) {
  var parser = ArgParser();
  int? firstColIdx;
  int? secondColIdx;
  parser.addOption(
    'first-col-index',
    abbr: 'f',
    defaultsTo: '1',
    callback: (value) {
      firstColIdx = int.parse(value!);
    },
  );

  parser.addOption(
    'second-col-index',
    abbr: 's',
    defaultsTo: '2',
    callback: (value) {
      secondColIdx = int.parse(value!);
    },
  );

  parser.addOption(
    'path',
    callback: (path) => generate_app_localizations.generateSwapColumn(
      firstColIdx: firstColIdx,
      secondColIdx: secondColIdx,
    ),
  );

  final argResult = parser.parse(args);
  print(argResult.arguments);
}
