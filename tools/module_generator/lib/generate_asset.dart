import 'dart:async';
import 'dart:io';

import 'package:yaml/yaml.dart';

import 'common/utils.dart';
import 'generator/generate_assets.dart' as generate_assets;

Future<void> generateAsset() async {
  String filePath = 'assets.yaml';
  if (!File(filePath).existsSync()) {
    filePath = 'pubspec.yaml';
  }
  final yamlMap = loadYaml(File(filePath).readAsStringSync()) as Map;
  final config = yamlMap['flutter'];

  if (config['assets'] is! List ||
      (config['assets_generated'] != null &&
          config['assets_generated'] is! String)) {
    _showAssetYamlError();
  } else {
    final paths = (config['assets'] as List).map((e) => e.toString()).toList();
    final output = (config['assets_generated'] is String)
        ? config['assets_generated']
        : 'lib/generated/';

    generate_assets.generateAsset(paths: paths, output: output as String);
  }
}

void _showAssetYamlError() {
  printLog('''Please provide assets.yaml file''');
  printLog('''##########################################
##### Example content of assets.yaml #####''');
  printLog('''flutter:
  assets:
    - assets/svg/
    - assets/images/
  assets_generated: lib/generated/''');
  printLog('##########################################');
}
