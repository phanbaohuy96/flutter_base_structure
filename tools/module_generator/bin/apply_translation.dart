#!/usr/bin/env dart

import 'dart:io';

import 'package:args/args.dart';
import 'package:module_generator/generator/apply_translation.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'translated',
      abbr: 't',
      help: 'Path to translated CSV file (completed translations)',
      defaultsTo: 'localization_latest.csv',
    )
    ..addOption(
      'current',
      abbr: 'c',
      help: 'Path to current localization CSV file',
      defaultsTo: 'apps/main/lib/l10n/localizations.csv',
    )
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Path to output CSV file (defaults to current file)',
    )
    ..addFlag('no-backup', help: 'Skip creating backup file', negatable: false)
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show usage information',
      negatable: false,
    );

  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } catch (e) {
    print('Error parsing arguments: $e\n');
    _printUsage(parser);
    exit(1);
  }

  if (argResults['help'] as bool) {
    _printUsage(parser);
    return;
  }

  final translatedPath = argResults['translated'] as String;
  final currentPath = argResults['current'] as String;
  final outputPath = (argResults['output'] as String?) ?? currentPath;
  final createBackup = !(argResults['no-backup'] as bool);

  // Validate files exist
  if (!File(translatedPath).existsSync()) {
    print('❌ Error: Translated CSV file not found: $translatedPath');
    exit(1);
  }

  if (!File(currentPath).existsSync()) {
    print('❌ Error: Current CSV file not found: $currentPath');
    exit(1);
  }

  try {
    await applyTranslation(
      translatedPath: translatedPath,
      currentPath: currentPath,
      outputPath: outputPath,
      createBackup: createBackup,
    );
  } catch (e, stackTrace) {
    print('❌ Error applying translation: $e');
    print(stackTrace);
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  print('Apply completed translations back to current localization file\n');
  print(
    'This merges translated values while preserving new keys added during development.\n',
  );
  print('Usage: dart bin/apply_translation.dart [options]\n');
  print('Options:');
  print(parser.usage);
  print('\nExample:');
  print(
    '  dart bin/apply_translation.dart --translated localization_latest.csv',
  );
  print('\nThe script will:');
  print('  1. Update existing keys with translated values');
  print('  2. Preserve new keys added to current file during translation');
  print('  3. Create timestamped backup (unless --no-backup is used)');
  print('  4. Overwrite current file with merged result');
}
