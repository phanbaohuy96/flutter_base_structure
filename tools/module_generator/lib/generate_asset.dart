import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'generator/generate_assets.dart' as generate_assets;
import 'generator/generate_assets.dart' show AssetStructure;

class AssetConfig {
  final List<String> assetPaths;
  final String outputPath;
  final AssetStructure structure;
  final bool recursive;
  final bool failOnDuplicates;

  const AssetConfig({
    required this.assetPaths,
    required this.outputPath,
    this.structure = AssetStructure.tree,
    this.recursive = true,
    this.failOnDuplicates = false,
  });

  factory AssetConfig.fromYaml(YamlMap config) {
    final assets = config['assets'] as List?;
    final assetsGenerated = config['assets_generated'] as String?;

    if (assets == null || assetsGenerated == null) {
      throw const ConfigException(
        'Invalid configuration: missing assets or assets_generated',
      );
    }

    final generationConfig = config['asset_generation'] as Map?;
    final structureName = generationConfig?['structure']?.toString() ?? 'tree';

    return AssetConfig(
      assetPaths: assets.map((e) => e.toString()).toList(),
      outputPath: assetsGenerated,
      structure: assetStructureFromName(structureName),
      recursive: _readBool(generationConfig, 'recursive', defaultValue: true),
      failOnDuplicates: _readBool(
        generationConfig,
        'fail_on_duplicates',
        defaultValue: structureName == 'flat',
      ),
    );
  }
}

class GenerateAssetOptions {
  final String projectDir;
  final String? root;
  final AssetStructure? structure;
  final bool? recursive;
  final bool? failOnDuplicates;
  final bool verbose;

  const GenerateAssetOptions({
    this.projectDir = '.',
    this.root,
    this.structure,
    this.recursive,
    this.failOnDuplicates,
    this.verbose = false,
  });
}

class RemoveUnusedAssetsOptions {
  final String projectDir;
  final String? root;
  final AssetStructure? structure;
  final bool recursive;
  final bool dryRun;
  final List<String> scanRoots;
  final bool verbose;

  const RemoveUnusedAssetsOptions({
    this.projectDir = '.',
    this.root,
    this.structure,
    this.recursive = true,
    this.dryRun = true,
    this.scanRoots = const ['lib'],
    this.verbose = false,
  });
}

class ConfigException implements Exception {
  final String message;
  const ConfigException(this.message);

  @override
  String toString() => 'ConfigException: $message';
}

Future<YamlMap?> readConfig({String projectDir = '.'}) async {
  try {
    final config = <String, dynamic>{};
    final projectPath = path.absolute(projectDir);

    await _mergeConfigFromFile(path.join(projectPath, 'pubspec.yaml'), config);
    await _mergeConfigFromFile(path.join(projectPath, 'assets.yaml'), config);

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

Future<void> _mergeConfigFromFile(
  String filePath,
  Map<String, dynamic> config,
) async {
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

bool _isValidConfig(Map<String, dynamic> config) {
  return config['assets'] is List && config['assets_generated'] is String;
}

Future<generate_assets.AssetGenerationResult> generateAssetWithOptions(
  GenerateAssetOptions options,
) async {
  final config = await readConfig(projectDir: options.projectDir);
  if (config == null) {
    throw const ConfigException('Asset configuration not found');
  }

  final assetConfig = AssetConfig.fromYaml(config);
  _logGenerationInfo(assetConfig, options.projectDir);

  return generate_assets.generateAsset(
    paths: assetConfig.assetPaths,
    output: assetConfig.outputPath,
    root: options.root,
    projectDir: options.projectDir,
    recursive: options.recursive ?? assetConfig.recursive,
    structure: options.structure ?? assetConfig.structure,
    failOnDuplicates: options.failOnDuplicates ?? assetConfig.failOnDuplicates,
    verbose: options.verbose,
  );
}

Future<generate_assets.RemoveUnusedAssetsResult> removeUnusedAssetsWithOptions(
  RemoveUnusedAssetsOptions options,
) async {
  final config = await readConfig(projectDir: options.projectDir);
  if (config == null) {
    throw const ConfigException('Asset configuration not found');
  }

  final assetConfig = AssetConfig.fromYaml(config);

  return generate_assets.removeUnusedAssets(
    resPaths: assetConfig.assetPaths,
    output: assetConfig.outputPath,
    root: options.root,
    projectDir: options.projectDir,
    recursive: options.recursive,
    structure: options.structure ?? assetConfig.structure,
    failOnDuplicates: assetConfig.failOnDuplicates,
    dryRun: options.dryRun,
    scanRoots: options.scanRoots,
    verbose: options.verbose,
  );
}

Future<void> generateAsset({required List<String> args}) async {
  try {
    final root = args.isNotEmpty ? args.first : null;
    await generateAssetWithOptions(GenerateAssetOptions(root: root));
  } catch (e) {
    print('Error generating assets: $e');
    rethrow;
  }
}

Future<void> removeUnusedAssets({required List<String> args}) async {
  try {
    final root = args.isNotEmpty ? args.first : null;
    await removeUnusedAssetsWithOptions(RemoveUnusedAssetsOptions(root: root));
  } catch (e) {
    print('Error removing unused assets: $e');
    rethrow;
  }
}

void _logGenerationInfo(AssetConfig config, String projectDir) {
  print('Generating assets for $projectDir to ${config.outputPath}');
  print('Generating assets from:');
  for (final assetPath in config.assetPaths) {
    print(' - $assetPath');
  }
}

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
  asset_generation:
    structure: flat
    recursive: true
##########################################''';

  print(errorMessage);
}

AssetStructure assetStructureFromName(String name) {
  switch (name) {
    case 'folder':
    case 'tree':
      return AssetStructure.tree;
    case 'flat':
      return AssetStructure.flat;
    default:
      throw ConfigException('Unsupported asset structure: $name');
  }
}

AssetStructure? optionalAssetStructureFromName(String? name) {
  return name == null ? null : assetStructureFromName(name);
}

bool _readBool(Map? config, String key, {required bool defaultValue}) {
  final value = config?[key];
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return defaultValue;
}
