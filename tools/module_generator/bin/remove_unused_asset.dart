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
    ..addOption(
      'root',
      help:
          'Preview root prefix used if assets are regenerated after deletion.',
    )
    ..addMultiOption(
      'scan-root',
      help:
          'Directory or file to scan for asset usages. Can be passed more than once.',
      defaultsTo: ['lib'],
    )
    ..addOption(
      'structure',
      allowed: ['flat', 'folder', 'tree'],
      help: 'Generated API structure. Defaults to config value or tree.',
    )
    ..addFlag(
      'recursive',
      help: 'Scan asset directories recursively.',
      defaultsTo: true,
    )
    ..addFlag(
      'dry-run',
      help: 'Report unused candidates without deleting files.',
      defaultsTo: true,
    )
    ..addFlag(
      'apply',
      help: 'Delete unused candidates and regenerate assets.',
      negatable: false,
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      help: 'Print used assets as well as unused candidates.',
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
  final apply = results['apply'] as bool;
  final dryRun = apply ? false : results['dry-run'] as bool;

  try {
    await generate_asset.removeUnusedAssetsWithOptions(
      generate_asset.RemoveUnusedAssetsOptions(
        projectDir: results['project-dir'] as String,
        root: root,
        structure: structure,
        recursive: results['recursive'] as bool,
        dryRun: dryRun,
        scanRoots: results['scan-root'] as List<String>,
        verbose: results['verbose'] as bool,
      ),
    );
  } catch (e, stackTrace) {
    print('Error removing unused assets: $e');
    print(stackTrace);
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  print('Report or remove unused generated assets.\n');
  print(
    'Usage: dart run module_generator:remove_unused_asset [options] [legacy-root]\n',
  );
  print('Options:');
  print(parser.usage);
  print('\nExamples:');
  print('  dart run module_generator:remove_unused_asset --project-dir .');
  print(
    '  dart run module_generator:remove_unused_asset --project-dir . --scan-root lib --scan-root test',
  );
  print(
    '  dart run module_generator:remove_unused_asset --project-dir . --apply',
  );
}
