#!/usr/bin/env dart

import 'dart:io';

import 'package:args/args.dart';
import 'package:module_generator/generator/generate_translation_csv.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'csv',
      abbr: 'c',
      help: 'Path to CSV file',
      defaultsTo: 'apps/main/lib/l10n/localizations.csv',
    )
    ..addOption(
      'old-file',
      abbr: 'o',
      help: 'Path to old CSV file for comparison',
      defaultsTo: 'translation_old.csv',
    )
    ..addOption(
      'output',
      abbr: 't',
      help: 'Path to output CSV file',
      defaultsTo: 'translation_new.csv',
    )
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

  final csvPath = argResults['csv'] as String;
  final oldFilePath = argResults['old-file'] as String;
  final outputPath = argResults['output'] as String;

  // Validate CSV file exists
  if (!File(csvPath).existsSync()) {
    print('❌ Error: CSV file not found: $csvPath');
    exit(1);
  }

  try {
    await generateTranslationCSV(
      csvPath: csvPath,
      oldFilePath: oldFilePath,
      outputPath: outputPath,
    );
  } catch (e, stackTrace) {
    print('❌ Error generating translation file: $e');
    print(stackTrace);
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  print('Generate translation CSV file with status column\n');
  print('Usage: dart bin/generate_translation_csv.dart [options]\n');
  print('Options:');
  print(parser.usage);
  print('\nStatus column values:');
  print('  NEW: New translation keys');
  print('  UPDATED: Keys with changed values');
  print('  (empty): Keys with no changes');
  print('\nYou can filter by status in Excel/Google Sheets!');
}
