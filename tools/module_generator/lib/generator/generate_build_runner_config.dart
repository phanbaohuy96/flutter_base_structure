import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import '../common/file_helper.dart';

Future<void> generateBuildRunnerConfig({
  required YamlMap config,
  required String configFilePath,
}) async {
  final startTime = DateTime.now();

  final _buildRunnerConfig = jsonDecode(jsonEncode(config));
  final allDartFiles = await _getAllDartFilePathsInDir('lib/');

  final builderConfigs = <List<String>, (RegExp, List<String>)>{
    [
      'injectable_generator:injectable_builder',
      'injectable_generator:injectable_config_builder'
    ]: (RegExp('\\b(package:injectable)\\b', caseSensitive: false), []),
    [
      'retrofit_generator',
    ]: (RegExp('\\b(package:retrofit)\\b', caseSensitive: false), []),
  };

  for (final f in allDartFiles) {
    final lines = await f.readAsLines();
    final posixPath = path.posix.joinAll(
      path.split(f.path),
    );
    for (final builder in builderConfigs.entries) {
      if (lines.any(
        (line) => builder.value.$1.hasMatch(line),
      )) {
        builderConfigs[builder.key] = (
          builder.value.$1,
          [
            ...builder.value.$2,
            posixPath,
          ]
        );
      }
    }
  }

  for (final builder in builderConfigs.entries) {
    for (final key in builder.key) {
      _updateBulders(
        _buildRunnerConfig,
        key,
        builder.value.$2
          ..sort(
            (a, b) => a.compareTo(b),
          ),
      );
    }
  }
  await FilesHelper.writeFile(
    pathFile: configFilePath,
    content: YamlWriter().write(_buildRunnerConfig),
  );
  final endTime = DateTime.now();
  final timeInMS = endTime.difference(startTime).inMilliseconds;

  print(
    'Scanned ${allDartFiles.length} dart files in ${timeInMS > 1000 ? '${timeInMS / 1000.0} s' : '$timeInMS ms'} ',
  );
}

Map _updateBulders(Map config, String id, List value) {
  if (config['targets'] == null) {
    config['targets'] = {};
  }
  if (config['targets']['\$default'] == null) {
    config['targets']['\$default'] = {};
  }
  if (config['targets']['\$default']['builders'] == null) {
    config['targets']['\$default']['builders'] = {};
  }
  return config['targets']['\$default']['builders'][id] = value.isEmpty
      ? {
          'enabled': false,
        }
      : {
          'generate_for': value,
        };
}

Future<List<File>> _getAllDartFilePathsInDir(String dir) async {
  final paths = <File>[];
  final _dir = Directory(dir);

  final entities = await _dir.list().toList();
  for (final e in entities) {
    if (e is File && e.path.contains('.dart')) {
      paths.add(e);
    } else if (e is Directory) {
      paths.addAll(await _getAllDartFilePathsInDir(e.path));
    }
  }
  return paths;
}
