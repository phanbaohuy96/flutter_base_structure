import 'dart:async';
import 'dart:io';

import 'package:yaml/yaml.dart';

import 'common/file_helper.dart';
import 'generator/generate_build_runner_config.dart'
    as generate_build_runner_config;

const _buildConfigTemplate = r'''targets:
  $default:
    builders:''';

const _filePath = 'build.yaml';
Future<YamlMap?> _readConfig() async {
  if (!File(_filePath).existsSync()) {
    await FilesHelper.writeFile(
      pathFile: _filePath,
      content: _buildConfigTemplate,
    );
  }
  return loadYaml(await File(_filePath).readAsString()) as YamlMap;
}

Future<void> generateBuildRunnerConfig({required List<String> args}) async {
  final config = await _readConfig();

  if (config != null) {
    await generate_build_runner_config.generateBuildRunnerConfig(
      configFilePath: _filePath,
      config: config,
    );
  }
}
