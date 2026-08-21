import 'dart:io';

import 'console.dart';
import 'file_helper.dart';
import 'package_scanner.dart';

/// Runs `dart format` over freshly generated files.
///
/// Templates are stored as hand-wrapped string literals, which drift from what
/// the analyzer wants (`lines_longer_than_80_chars`, `require_trailing_commas`)
/// as soon as a feature name is long enough to push a line over the limit.
/// Formatting the emitted output instead of hand-wrapping every template keeps
/// generated code inside `make check` no matter how long the names are.
///
/// Generated files have no hand-written layout to protect, so this is safe
/// under the repo's `formatter: trailing_commas: preserve` setting.
Future<void> formatGeneratedFiles(List<String> paths) async {
  final existing = paths.where((path) => File(path).existsSync()).toList();
  if (existing.isEmpty) {
    return;
  }

  final command = await _resolveDartCommand();
  try {
    final result = await Process.run(command.first, [
      ...command.skip(1),
      'format',
      ...existing,
    ]);
    if (result.exitCode != 0) {
      stdout.writeln(
        Console.warning('dart format exited ${result.exitCode}:'),
      );
      stdout.writeln(result.stderr);
    }
  } on ProcessException catch (error) {
    stdout.writeln(
      Console.warning('could not run dart format: ${error.message}'),
    );
    stdout.writeln(Console.warning('run `make format` before committing.'));
  }
}

/// Mirrors the makefile's FVM-aware `DART` wrapper: prefer `fvm dart` when the
/// repo is pinned to a Flutter version, otherwise fall back to the system SDK.
Future<List<String>> _resolveDartCommand() async {
  for (final root in ['.', '..', '../..', '../../..']) {
    final cache = await FilesHelper.readFile(pathFile: '$root/.fvm_cache');
    if (cache != null && cache.contains('USING_FVM=1')) {
      return ['fvm', 'dart'];
    }
  }
  return ['dart'];
}

/// Prints the follow-up commands a generated module needs before it compiles.
///
/// Freezed/injectable output and the route-provider registry are all produced
/// by build_runner, so a freshly generated module is red in the IDE until
/// `make gen_main` runs. Saying so at the end of generation removes the most
/// common "the generator is broken" false alarm.
void printNextSteps(List<String> emitted) {
  if (emitted.isEmpty) {
    return;
  }
  stdout.writeln();
  stdout.writeln(
    Console.success(Console.bold('Generated ${emitted.length} file(s)')),
  );
  for (final path in emitted) {
    stdout.writeln('  ${Console.dim('+')} $path');
  }
  // The codegen target follows the package the files landed in: telling
  // someone who just generated into `modules/data_source` to run `make
  // gen_main` sends them to build_runner in the wrong package, where their new
  // file is not an input at all.
  final target = _codegenTarget();
  // Sized from the longest command so the comments line up whichever package
  // the run landed in.
  final width = target.length > 10 ? target.length + 2 : 12;
  stdout.writeln('\n${Console.bold('Next steps')}');
  stdout.writeln(
    '  ${Console.green('1.')} ${target.padRight(width)}'
    '${Console.dim('# freezed + injectable + route provider registry')}',
  );
  stdout.writeln(
    '  ${Console.green('2.')} ${'make check'.padRight(width)}'
    '${Console.dim('# analyze + format_check + test')}\n',
  );
}

/// The `make` target that runs build_runner for the current package.
String _codegenTarget() {
  final package = currentPackage();
  return switch (package?.name) {
    'core' => 'make gen_core',
    'data_source' => 'make gen_data_source',
    _ => 'make gen_main',
  };
}
