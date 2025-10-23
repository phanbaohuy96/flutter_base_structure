import 'dart:async';
import 'dart:io';

import 'package:yaml/yaml.dart';

import 'generator/generate_assets.dart' as generate_assets;

/// Configuration model for asset generation
class AssetConfig {
  final List<String> assetPaths;
  final String outputPath;

  const AssetConfig({
    required this.assetPaths,
    required this.outputPath,
  });

  factory AssetConfig.fromYaml(YamlMap config) {
    final assets = config['assets'] as List?;
    final assetsGenerated = config['assets_generated'] as String?;

    if (assets == null || assetsGenerated == null) {
      throw const ConfigException(
          'Invalid configuration: missing assets or assets_generated');
    }

    return AssetConfig(
      assetPaths: assets.map((e) => e.toString()).toList(),
      outputPath: assetsGenerated,
    );
  }
}

/// Custom exception for configuration errors
class ConfigException implements Exception {
  final String message;
  const ConfigException(this.message);

  @override
  String toString() => 'ConfigException: $message';
}

/// Reads and merges configuration from pubspec.yaml and assets.yaml
Future<YamlMap?> readConfig() async {
  try {
    final config = <String, dynamic>{};

    // Read from pubspec.yaml first
    await _mergeConfigFromFile('pubspec.yaml', config);

    // Override with assets.yaml if exists
    await _mergeConfigFromFile('assets.yaml', config);

    // Validate required fields
    if (!_isValidConfig(config)) {
      _showAssetYamlError();
      return null;
    }

    return YamlMap.wrap(config);
  } catch (e) {
    print('Error reading configuration: $e');
    return null;
  }
}

/// Merges configuration from a YAML file into the existing config
Future<void> _mergeConfigFromFile(
    String filePath, Map<String, dynamic> config) async {
  final file = File(filePath);
  if (!file.existsSync()) return;

  try {
    final content = await file.readAsString();
    final yamlMap = loadYaml(content) as Map?;
    final flutterConfig = yamlMap?['flutter'] as Map?;

    if (flutterConfig != null) {
      config.addAll(Map<String, dynamic>.from(flutterConfig));
    }
  } catch (e) {
    print('Warning: Failed to read $filePath: $e');
  }
}

/// Validates the configuration structure
bool _isValidConfig(Map<String, dynamic> config) {
  return config['assets'] is List && config['assets_generated'] is String;
}

/// Generates assets based on configuration
Future<void> generateAsset({required List<String> args}) async {
  try {
    final config = await readConfig();
    if (config == null) return;

    final assetConfig = AssetConfig.fromYaml(config);
    final root = args.isNotEmpty ? args.first : null;

    _logGenerationInfo(assetConfig);

    await generate_assets.generateAsset(
      paths: assetConfig.assetPaths,
      output: assetConfig.outputPath,
      root: root,
    );
  } catch (e) {
    print('Error generating assets: $e');
  }
}

/// Removes unused assets based on configuration
Future<void> removeUnusedAssets({required List<String> args}) async {
  try {
    final config = await readConfig();
    if (config == null) return;

    final assetConfig = AssetConfig.fromYaml(config);
    final root = args.isNotEmpty ? args.first : null;

    await generate_assets.removeUnusedAssets(
      resPaths: assetConfig.assetPaths,
      output: assetConfig.outputPath,
      root: root,
    );
  } catch (e) {
    print('Error removing unused assets: $e');
  }
}

/// Logs information about the asset generation process
void _logGenerationInfo(AssetConfig config) {
  print('Generating assets to ${config.outputPath}');
  print('Generating assets from:');
  for (final path in config.assetPaths) {
    print(' - $path');
  }
}

/// Shows error message and example configuration
void _showAssetYamlError() {
  const errorMessage = '''
Please provide assets.yaml file

##########################################
##### Example content of assets.yaml #####
flutter:
  assets:
    - assets/svg/
    - assets/images/
  assets_generated: lib/generated/
##########################################''';

  print(errorMessage);
}
