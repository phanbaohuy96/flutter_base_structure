import 'dart:io';

import 'package:args/args.dart';
import 'package:module_generator/generate_asset.dart' as generate_asset;

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'project-dir',
      help: 'Directory containing pubspec.yaml and optional assets.yaml.',
      defaultsTo: '.',
    )
    ..addOption('root', help: 'Preview root prefix used in generated comments.')
    ..addOption(
      'structure',
      allowed: ['flat', 'folder', 'tree'],
      help: 'Generated API structure. Defaults to config value or flat.',
    )
    ..addFlag(
      'recursive',
      help: 'Scan asset directories recursively.',
      defaultsTo: true,
    )
    ..addFlag(
      'allow-duplicates',
      help: 'Do not fail when duplicate flat accessors are found.',
      negatable: false,
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      help: 'Print each generated accessor.',
      negatable: false,
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show usage information.',
      negatable: false,
    );

  ArgResults results;
  try {
    results = parser.parse(arguments);
  } catch (e) {
    print('Error parsing arguments: $e\n');
    _printUsage(parser);
    exit(1);
  }

  if (results['help'] as bool) {
    _printUsage(parser);
    return;
  }

  final legacyRoot = results.rest.isNotEmpty ? results.rest.first : null;
  final root = results['root'] as String? ?? legacyRoot;
  final structure = generate_asset.optionalAssetStructureFromName(
    results['structure'] as String?,
  );

  try {
    await generate_asset.generateAssetWithOptions(
      generate_asset.GenerateAssetOptions(
        projectDir: results['project-dir'] as String,
        root: root,
        structure: structure,
        recursive: results['recursive'] as bool,
        failOnDuplicates: results['allow-duplicates'] as bool ? false : null,
        verbose: results['verbose'] as bool,
      ),
    );
  } catch (e, stackTrace) {
    print('Error generating assets: $e');
    print(stackTrace);
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  print('Generate Dart asset accessors from Flutter asset declarations.\n');
  print(
    'Usage: dart run module_generator:generate_asset [options] [legacy-root]\n',
  );
  print('Options:');
  print(parser.usage);
  print('\nExamples:');
  print('  dart run module_generator:generate_asset apps/main');
  print(
    '  dart run module_generator:generate_asset --project-dir . --root apps/main',
  );
  print('  dart run module_generator:generate_asset --structure folder');
}
