import 'dart:io';

import 'package:args/args.dart';
import 'package:module_generator/common/generator_options.dart';
import 'package:module_generator/module_generator.dart' as module_generator;

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      'type',
      allowed: GeneratorType.values.map((type) => type.name),
      help: 'What to generate. Omit to use the interactive menu.',
    )
    ..addOption('name', help: 'Module / usecase / repository name.')
    ..addOption('dir', help: 'Output directory, package-relative.')
    ..addOption('entity', help: 'Domain entity the module is typed against.')
    ..addFlag(
      'entity-scaffold',
      defaultsTo: true,
      help: 'Scaffold the domain entity when it does not exist.',
    )
    ..addFlag('force', negatable: false, help: 'Overwrite an existing module.')
    ..addFlag(
      'non-interactive',
      negatable: false,
      help: 'Never prompt; fail instead when a required value is missing.',
    )
    ..addFlag('help', abbr: 'h', negatable: false);

  final ArgResults results;
  try {
    results = parser.parse(args);
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln(parser.usage);
    exit(64);
  }

  if (results.flag('help')) {
    stdout.writeln('Usage: dart run module_generator [options]\n');
    stdout.writeln(parser.usage);
    return;
  }

  final options = GeneratorOptions(
    type: GeneratorType.parse(results.option('type')),
    name: results.option('name'),
    dir: results.option('dir'),
    entity: results.option('entity'),
    scaffoldEntity: results.flag('entity-scaffold'),
    force: results.flag('force'),
    nonInteractive: results.flag('non-interactive'),
  );

  try {
    await module_generator.runModuleGenerator(options);
  } on GeneratorInputException catch (error) {
    stderr.writeln('Error: ${error.message}');
    exit(64);
  }
}
