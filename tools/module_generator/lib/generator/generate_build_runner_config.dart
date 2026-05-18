import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import '../common/file_helper.dart';

/// Configuration for a build runner target
class BuilderConfig {
  final List<String> builderNames;
  final RegExp importPattern;
  final List<String> matchingFiles;

  BuilderConfig({
    required this.builderNames,
    required this.importPattern,
    this.matchingFiles = const [],
  });

  BuilderConfig copyWith({List<String>? matchingFiles}) {
    return BuilderConfig(
      builderNames: builderNames,
      importPattern: importPattern,
      matchingFiles: matchingFiles ?? this.matchingFiles,
    );
  }
}

/// Generates build runner configuration based on detected imports in Dart files
Future<void> generateBuildRunnerConfig({
  required YamlMap config,
  required String configFilePath,
}) async {
  final stopwatch = Stopwatch()..start();

  final buildRunnerConfig = _convertYamlToMap(config);
  final dartFiles = await _scanDartFiles('lib/');

  final builderConfigs = _initializeBuilderConfigs();
  final updatedConfigs = await _scanFilesForImports(dartFiles, builderConfigs);

  _updateBuildRunnerConfig(buildRunnerConfig, updatedConfigs);

  await _writeConfigFile(configFilePath, buildRunnerConfig);

  stopwatch.stop();
  _logScanResults(dartFiles.length, stopwatch.elapsedMilliseconds);
}

/// Initialize builder configurations
Map<String, BuilderConfig> _initializeBuilderConfigs() {
  return {
    'injectable': BuilderConfig(
      builderNames: [
        'injectable_generator:injectable_builder',
        'injectable_generator:injectable_config_builder',
      ],
      importPattern: RegExp(r'\b(package:injectable)\b', caseSensitive: false),
    ),
    'retrofit': BuilderConfig(
      builderNames: ['retrofit_generator'],
      importPattern: RegExp(r'\b(package:retrofit)\b', caseSensitive: false),
    ),
  };
}

/// Convert YAML map to mutable Map
Map<String, dynamic> _convertYamlToMap(YamlMap config) {
  return Map<String, dynamic>.from(jsonDecode(jsonEncode(config)));
}

/// Scan all Dart files and check for matching imports
Future<Map<String, BuilderConfig>> _scanFilesForImports(
  List<File> dartFiles,
  Map<String, BuilderConfig> builderConfigs,
) async {
  final updatedConfigs = <String, BuilderConfig>{};

  for (final configEntry in builderConfigs.entries) {
    final matchingFiles = <String>[];

    for (final file in dartFiles) {
      if (await _fileContainsImport(file, configEntry.value.importPattern)) {
        final posixPath = _convertToPosixPath(file.path);
        matchingFiles.add(posixPath);
      }
    }

    matchingFiles.sort();
    updatedConfigs[configEntry.key] = configEntry.value.copyWith(
      matchingFiles: matchingFiles,
    );
  }

  return updatedConfigs;
}

/// Check if file contains the specified import pattern
Future<bool> _fileContainsImport(File file, RegExp pattern) async {
  try {
    final lines = await file.readAsLines();
    return lines.any((line) => pattern.hasMatch(line));
  } catch (e) {
    // Skip files that can't be read
    return false;
  }
}

/// Convert file path to POSIX format
String _convertToPosixPath(String filePath) {
  return path.posix.joinAll(path.split(filePath));
}

/// Update build runner configuration with detected files
void _updateBuildRunnerConfig(
  Map<String, dynamic> config,
  Map<String, BuilderConfig> builderConfigs,
) {
  for (final builderConfig in builderConfigs.values) {
    for (final builderName in builderConfig.builderNames) {
      _setBuildTarget(config, builderName, builderConfig.matchingFiles);
    }
  }
}

/// Set build target configuration for a specific builder
void _setBuildTarget(
  Map<String, dynamic> config,
  String builderId,
  List<String> targetFiles,
) {
  // Ensure nested structure exists
  config.putIfAbsent('targets', () => <String, dynamic>{});
  final targets = config['targets'] as Map<String, dynamic>;

  targets.putIfAbsent('\$default', () => <String, dynamic>{});
  final defaultTarget = targets['\$default'] as Map<String, dynamic>;

  defaultTarget.putIfAbsent('builders', () => <String, dynamic>{});
  final builders = defaultTarget['builders'] as Map<String, dynamic>;

  // Set builder configuration
  builders[builderId] = targetFiles.isEmpty
      ? {'enabled': false}
      : {'generate_for': targetFiles};
}

/// Write configuration to file
Future<void> _writeConfigFile(
  String configFilePath,
  Map<String, dynamic> config,
) async {
  await FilesHelper.writeFile(
    pathFile: configFilePath,
    content: YamlWriter().write(config),
  );
}

/// Recursively scan directory for Dart files
Future<List<File>> _scanDartFiles(String directoryPath) async {
  final dartFiles = <File>[];
  final directory = Directory(directoryPath);

  if (!await directory.exists()) {
    return dartFiles;
  }

  await for (final entity in directory.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      dartFiles.add(entity);
    }
  }

  return dartFiles;
}

/// Log scan results
void _logScanResults(int fileCount, int timeInMs) {
  final timeDisplay = timeInMs > 1000
      ? '${(timeInMs / 1000.0).toStringAsFixed(1)} s'
      : '$timeInMs ms';

  print('Scanned $fileCount dart files in $timeDisplay');
}
