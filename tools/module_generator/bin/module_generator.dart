import 'dart:io';

import 'package:args/args.dart';
import 'package:module_generator/common/console.dart';
import 'package:module_generator/common/generator_options.dart';
import 'package:module_generator/module_generator.dart' as module_generator;

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      'type',
      allowed: GeneratorType.values.map((type) => type.name),
      help: 'What to generate. Omit to use the interactive menu.',
    )
    ..addOption(
      'package',
      help:
          'Workspace package to generate into (eg. apps/main, '
          'modules/data_source). Omit to pick from a menu.',
    )
    ..addOption('name', help: 'Module / usecase / repository name.')
    ..addOption('dir', help: 'Output directory, package-relative.')
    ..addOption('entity', help: 'Domain entity the module is typed against.')
    ..addOption(
      'transport',
      allowed: RepositoryTransport.values.map((transport) => transport.name),
      allowedHelp: {
        for (final transport in RepositoryTransport.values)
          transport.name: transport.description,
      },
      help: 'Transport for --type repository. Defaults to rest.',
    )
    ..addOption(
      'model',
      allowed: ModelKind.values.map((kind) => kind.flagName),
      allowedHelp: {
        for (final kind in ModelKind.values) kind.flagName: kind.description,
      },
      help:
          'Model scaffolded alongside --type repository. '
          'Defaults to freezed.',
    )
    ..addOption(
      'model-name',
      help: 'Model class name. Defaults to <name>Model.',
    )
    ..addOption(
      'model-dir',
      help: 'Model output directory. Defaults to the package model folder.',
    )
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
    stdout.writeln(
      Console.banner(
        'Flutter module generator',
        subtitle: 'Scaffolds modules, repositories, usecases and models',
      ),
    );
    stdout.writeln('\n${Console.bold('Usage')}');
    stdout.writeln('  dart run module_generator [options]');
    stdout.writeln(
      '  dart run module_generator          '
      '${Console.dim('# interactive menu')}\n',
    );
    stdout.writeln(Console.bold('Options'));
    stdout.writeln(parser.usage);
    return;
  }

  final options = GeneratorOptions(
    type: GeneratorType.parse(results.option('type')),
    package: results.option('package'),
    name: results.option('name'),
    dir: results.option('dir'),
    entity: results.option('entity'),
    transport: RepositoryTransport.parse(results.option('transport')),
    modelKind: ModelKind.parse(results.option('model')),
    modelName: results.option('model-name'),
    modelDir: results.option('model-dir'),
    scaffoldEntity: results.flag('entity-scaffold'),
    force: results.flag('force'),
    nonInteractive: results.flag('non-interactive'),
  );

  try {
    await module_generator.runModuleGenerator(options);
  } on GeneratorInputException catch (error) {
    stderr.writeln(Console.failure(error.message));
    exit(64);
  }
}
