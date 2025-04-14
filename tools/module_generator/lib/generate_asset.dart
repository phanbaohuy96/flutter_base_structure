import 'dart:async';
import 'dart:io';

import 'package:yaml/yaml.dart';

import 'generator/generate_assets.dart' as generate_assets;

Future<YamlMap?> readConfig() async {
  var filePath = 'assets.yaml';
  if (!File(filePath).existsSync()) {
    filePath = 'pubspec.yaml';
  }
  final yamlMap = loadYaml(await File(filePath).readAsString()) as Map;
  final config = yamlMap['flutter'];
  if (config['assets'] is! List ||
      (config['assets_generated'] != null &&
          config['assets_generated'] is! String)) {
    _showAssetYamlError();
    return null;
  }
  return config as YamlMap;
}

Future<void> generateAsset({required List<String> args}) async {
  final config = await readConfig();

  if (config != null) {
    final paths = (config['assets'] as List).map((e) => e.toString()).toList();
    final output = (config['assets_generated'] is String)
        ? config['assets_generated']
        : 'lib/generated/';

    await generate_assets.generateAsset(
      paths: paths,
      output: output as String,
      root: args.isNotEmpty ? args.first : null,
    );
  }
}

Future<void> removeUnusedAssets({required List<String> args}) async {
  final config = await readConfig();

  if (config != null) {
    final paths = (config['assets'] as List).map((e) => e.toString()).toList();
    final output = (config['assets_generated'] is String)
        ? config['assets_generated']
        : 'lib/generated/';

    await generate_assets.removeUnusedAssets(
      resPaths: paths,
      output: output as String,
      root: args.isNotEmpty ? args.first : null,
    );
  }
}

void _showAssetYamlError() {
  print('''Please provide assets.yaml file''');
  print('''##########################################
##### Example content of assets.yaml #####''');
  print('''flutter:
  assets:
    - assets/svg/
    - assets/images/
  assets_generated: lib/generated/''');
  print('##########################################');
}
