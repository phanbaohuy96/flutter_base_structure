// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import 'generator/generate_app_identifier.dart' as generate_app_identifier;

Future<YamlMap?> readConfig() async {
  var filePath = 'app_identifier.yaml';
  if (!File(filePath).existsSync()) {
    _showAssetYamlError();
    return null;
  }
  final config = loadYaml(await File(filePath).readAsString()) as Map;
  if (config['android'] == null && config['ios'] == null) {
    _showAssetYamlError();
    return null;
  }
  return config as YamlMap;
}

Future<void> generateAppIdentifier({required List<String> args}) async {
  final config = await readConfig();

  if (config != null) {
    final project = generate_app_identifier.ProjectConfigDocument([
      ...(jsonDecode(jsonEncode(config)) as Map<String, dynamic>)
          .entries
          .map(generate_app_identifier.PlatformConfigDocument.create),
    ]);
    await generate_app_identifier.generateAppIdentifier(
      project: project,
    );
  }
}

void _showAssetYamlError() {
  print('''Please provide app_identifier.yaml file''');
  print('''##########################################
##### Example content of assets.yaml #####''');
  print('''android:
  dev:
    package: com.abc.xyzDev
    name: App_D
  staging:
    package: com.abc.xyzStag
    name: App_S
  prod:
    package: com.abc.xyz
    name: App

ios:
  dev:
    package: com.abc.xyzDev
    name: App_D
  staging:
    package: com.abc.xyzStag
    name: App_S
  prod:
    package: com.abc.xyz
    name: App
''');
  print('##########################################');
}
